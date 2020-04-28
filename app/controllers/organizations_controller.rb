class OrganizationsController < ApplicationController

  def index
    @organizations = Organization.all
  end

  def new
  end

  def create
  end
end
