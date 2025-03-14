class UsersController < ApplicationController
  def index
    @users = User.all
    authorize @users
  end

  def show
    
  end
end
