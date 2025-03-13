Integrating Pundit and Rolify Gems for Role-Based Access Control in Rails
This guide explains how to integrate the Pundit and Rolify gems in a Rails application to manage user roles and authorization. Pundit provides a simple way to handle permissions through policies, while Rolify simplifies the management of user roles.

Table of Contents
Prerequisites
Installation
Setting Up Rolify
Install Rolify
Migrate the Database
Add Roles to Users
Defining Roles
Setting Up Pundit
Install Pundit
Creating Policies
Using Pundit in Controllers
Using Pundit and Rolify Together
Handling Authorization Errors
Conclusion
Prerequisites
Before you start, make sure you have the following:

A Rails application (Rails 6 or later recommended).
A user model (typically generated via Devise or a custom authentication system).
Installation
Add the following gems to your Gemfile:

ruby
Copy
# Gemfile
gem 'pundit'
gem 'rolify'
Run the command to install the gems:

bash
Copy
bundle install
Setting Up Rolify
Install Rolify
Generate the necessary files for Rolify by running:

bash
Copy
rails generate rolify Role User
This command will generate a Role model and a migration file for the roles table, and associate it with the User model.

Migrate the Database
Run the migration to create the roles table:

bash
Copy
rails db:migrate
Add Roles to Users
In the User model (app/models/user.rb), include rolify to add role functionality:

ruby
Copy
class User < ApplicationRecord
  rolify
  # other user-related logic, e.g., Devise authentication
end
Defining Roles
To define and assign roles, you can use the following code:

ruby
Copy
# Assigning a role to a user
user = User.find(1)
user.add_role :admin

# Checking if a user has a specific role
user.has_role?(:admin)  # Returns true if the user has the 'admin' role
You can define roles such as :admin, :moderator, or :user, and assign these roles to users as needed.

Setting Up Pundit
Install Pundit
To install Pundit, run:

bash
Copy
rails generate pundit:install
This will create a base application_policy.rb file under app/policies/ and set up Pundit for your application.

Creating Policies
For each model you wish to authorize actions for, create a policy. For example, for the Post model:

bash
Copy
rails generate pundit:policy post
This will generate app/policies/post_policy.rb.

Define Authorization Logic
In the PostPolicy, define authorization logic for actions like show, edit, update, destroy:

ruby
Copy
class PostPolicy < ApplicationPolicy
  def show?
    user.has_role?(:admin) || user == record.user
  end

  def update?
    user.has_role?(:admin) || user == record.user
  end

  def destroy?
    user.has_role?(:admin)
  end
end
In this example:

Admins can perform any action.
Users can only view, update, or delete their own posts.
Using Pundit in Controllers
To enforce authorization in your controllers, use the authorize method. For example, in the PostsController:

ruby
Copy
class PostsController < ApplicationController
  before_action :set_post, only: %i[show edit update destroy]

  def show
    authorize @post  # Ensures the user has permission to view the post
  end

  def update
    authorize @post  # Ensures the user has permission to update the post
    if @post.update(post_params)
      redirect_to @post, notice: 'Post was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize @post  # Ensures the user has permission to destroy the post
    @post.destroy
    redirect_to posts_url, notice: 'Post was successfully destroyed.'
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content)
  end
end
The authorize method will automatically use the PostPolicy for each action.

Using Pundit and Rolify Together
With Rolify, you can easily check roles in Pundit policies. For example, in a PostPolicy:

ruby
Copy
class PostPolicy < ApplicationPolicy
  def show?
    user.has_role?(:admin) || user == record.user
  end

  def create?
    user.has_role?(:admin) || user.has_role?(:moderator)
  end

  def update?
    user.has_role?(:admin) || user == record.user
  end

  def destroy?
    user.has_role?(:admin)
  end
end
In this example:

Admins can perform any action.
Moderators can create posts.
Users can only edit and delete their own posts.
This integration allows for fine-grained control over which roles can access or modify specific resources.

Handling Authorization Errors
If a user tries to access or perform an action they are not authorized to, Pundit will raise a Pundit::NotAuthorizedError. You can handle this error globally in your ApplicationController:

ruby
Copy
class ApplicationController < ActionController::Base
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referer || root_path)
  end
end
This will redirect unauthorized users back to the previous page (or the root path) with an alert message.

Conclusion
By combining Pundit and Rolify, you can easily manage role-based access control and authorization in your Rails application. Rolify allows you to assign and check roles, while Pundit provides a clean and simple way to authorize actions based on policies.

You can extend this implementation to support more complex role structures, define policies for additional models, and handle authorization errors gracefully.

