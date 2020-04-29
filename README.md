# Rails Multi Tenant Demo

This README would normally document whatever steps are necessary to get the
application up and running. It does not.

This is a demo for a multi tenant system utilizing Ruby on Rails utilizing scopes to implement multi tenant functionality. It has 2 example models - Organizations and Users.  Users will belong to an Organization, and each Organization should be able to login via their own subdomain.

This is a demo which also explains to PAIRIN users why we will pursue a scope based multi-tenant system over a schema based system.  While both have there benefits, our circumstances and existing system mesh better with the scopes.

## Multi Tenants

Multi Tenant systems need to do 4 things.

* Host multiple tenants on one instance.  This allows you to run the same app for multiple clients.  In this example we will have multiple organizations.
* Provide for Data Separation.  You should not be able to guess URLS and get back valid information.  If you're in organization 1 - you should only see information from organization 1. In this example that will be users.
* Customization.  If one organization wants things with a pretty blue background they should be able to have it, if another wants a stupid green background - sure why not. Use your imagination and extrapolate the subdomain to other attributes - color scheme, time zone, etc.
* Shared Data Apps.  If the tenants need to share some sort of data app - such as authentication or signup they should be able to do so.

## Scopes Justification

There are 3 main ways to separate data.

1) Separate databases - the most secure - the most wasteful - the most costly - shares nothing by design.  Basically every tenant has thier own database for information.  This is widly costly and everytime a new tenant is onboarded they must be completely setup.  It is tedious.  Every tenant will need their own default data.

2) Schema separation - Basically this is namespacing at the database level.  This allows for strong segregation, allows sharing of data, almost transparent and allows for independent tenant schema migrations.  However, to do this we would have to adopt the multiple schema paradigms - and then be aware that any data in the public schema would be shared.  This requires us to figure out what data should be be in the public schema and which should be migrated into tenant's schemas.  While this would be possible it would require quite a bit of adaptation - think having all information from join tables have to be segregated into tenants.  This also requires migrations for each tenant to be ran to build their schema.  Lastly this has had some problems with data backups taking >24 hours for databases with >50 tenants on PostgresQL.  That just won't do.

3) Scope based separation.  This has the lowest overhead, is natural to rails, its easy to create new accounts, and is very simple when it comes to data aggregation.  However, we have to be concious of what is shared and what is not.  What belongs to organizations, and what is shared. 

## Tenant Namespacing

Tentant namespacing can be done via url pathing -> `something.com/my_tenant/users` or subdomains `my_tenant.something.com.`  We will use subdomains because A. they objectively look better and B. if someone wants a custom domain it will be easier to accomodate.

Rails servers do not like to work with subdomains out of the box.  If you're running locally you'll notice that tenant.localhost:3000 does not point to our localhost.  So we need to have something that does allow us to work with tenants.  Some sort of external domain that will point to our localhost and work with subdomains.

`tenant.lvh.me:3000` does just this.  Note the tenant and the port - make sure they reflect your tenant and port.

MacOS can work with the pow server. `www.pow.cx` This is actually a bit cleaner and friendlier than `lvh.me`.

## Making it work.

The ApplicationController (which all controllers inherit from) is where we enforce our multi tenancy.

The first thing you will notice is:

```
def current_organization
  Organization.find_by_subdomain(request.subdomain)
end
helper_method :current_organization
```

This method allows us to call current_organization in any of our controllers.  What it does is looks at the request's subdomain and attempts to find an organization based on the subdomain.
The `helper_method :current_organization` creates a helper method for views.  We don't need to worry much about that.

Next we see:
```
  around_action :scope_current_organization

  private 

...

    def scope_current_organization
      Organization.current_id = current_organization.id if current_organization
      yield
    ensure
      Organization.current_id = nil
    end
```

This around action occurs before and after the controller performs its actions.  Basically it calls the `Organization.current_id = current_organization.id if current_organization`  This sets the current_id on the Organization model.  On the Organization model we see:

```
  def self.current_id=(id)
    Thread.current[:organization_id] = id
  end

  def self.current_id
    Thread.current[:organization_id]
  end
```

This allows us to have a class level accessor that is thread safe.  (We could do `cattr_accessor :current_id` but this is not thread safe and we could see weird bugs by trying to save a few lines.)

Once the `Organization.current_id` is set - the controller can operate within the scope of the current_organization.

Speaking of 'scope' - on any model we want to have scoped we can now add a default scope as seen on the User model.

```
class User < ApplicationRecord

  belongs_to :organization
  default_scope { where(organization_id: Organization.current_id) }

end
```

This ties everything together.  Now when we try to look up a User or an Organization's users the default scope will look for the `Organization.current_id` which has been set by the controller during the around_action.

## Bear witness!

Give it a shot

`bundle exec rake db:drop;bundle exec rake db:create;bundle exec rake db:migrate;bundle exec rake db:seed`

`rails s`

This should start the server up on port `3000` by default.

Visit lvh.me:3000 - Yay you're on rails.

Now visit `lvh.me:3000/organizations`

You can see a full list of organizations.  

But this is not scoped to an organization!

Exactly.  On our organizations model we have not defined a default scope.  So we can see all of them.  Which means if we have any data we want siloed to a given tenant - we need to make sure we define our scope!

Okay.

Now visit 'lvh.me:3000/users'

There are no users?!  Thats right - we have a default scope on the User model - because we do not have an organization in scope - no subdomain - we do not have any users!

So lets see them!

Previously on our organizations index we saw that we have 2 organizations - pirates and robots.

lets visit `pirates.lvh.me:3000/users` 2 users!
Lets visit `robots.lvh.me:3000/users` 2 ... different users!

Huzzah.

Now its good to know that the default scope is pretty dang global!

Lets check out our console `rails c`

Lets see how many users we have!

```
User.count
=> 0
```

Q: Where has our life gone wrong?! A: probably highschool. Better A: default scope!

Remember the `Organization.current_id`? lets set that and try again.
```
Organization.current_id = 1
User.count
=> 2
```

Glorious! But only 2?  I thought we had 4 users?  We do.

However we're still scoped.  To see all the users lets remove the scope!

```
User.unscoped.count
=> 4
```

There they are.

We can see this on the server too!

`pirates.lvh.me:3000/all_users`

Here in the Users controller we're set the users to `users=User.unscoped.all`

