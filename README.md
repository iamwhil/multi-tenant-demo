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

## Subdomains

Data separation could be done via url pathing -> `something.com/my_tenant/users` or subdomains `my_tenant.something.com.`  We will use subdomains because A. they objectively look better and B. if someone wants a custom domain it will be easier to accomodate.

Rails servers do not like to work with subdomains out of the box.  If you're running locally you'll notice that tenant.localhost:3000 does not point to our localhost.  So we need to have something that does allow us to work with tenants.  Some sort of external domain that will point to our localhost and work with subdomains.

`tenant.lvh.me:3000` does just this.  Note the tenant and the port.

MacOS can work with the pow server. `www.pow.cx` This is actually a bit cleaner and friendlier than `lvh.me`.

