class UsersController < ApplicationController

  def index
    @request = request
    @organization = current_organization
    @users = @organization ? @organization.users : []
  end

  def show
    @request = request
    @organization = current_organization

    user = User.find(params[:id])
    if user 
      @user = user
    else  
      @user = nil
    end
  end

  def all_users 
    @request = request
    @organization = current_organization
    @users = User.unscoped.all
  end

  def new
  end

  def create
  end
end
