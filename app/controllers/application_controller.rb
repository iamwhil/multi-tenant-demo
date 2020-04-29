class ApplicationController < ActionController::Base

  around_action :scope_current_organization

  private 

    def current_organization
      Organization.find_by_subdomain!(request.subdomain)
    end
    helper_method :current_organization

    def scope_current_organization
      Organization.current_id = current_organization.id if current_organization
      yield
    ensure
      Organization.current_id = nil
    end
  
end
