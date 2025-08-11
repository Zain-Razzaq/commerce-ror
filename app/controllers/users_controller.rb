class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_user, only: [:show, :update, :destroy]
  before_action :require_admin, only: [:index]

  def index
    begin
      @users = User.all.select(:id, :name, :email, :is_admin)
      render json: @users
    rescue => e
      is_server_error(e)
    end
  end

  def show
    begin
      if @user
        render json: @user.slice(:id, :name, :email, :is_admin)
      else
        render json: { error: "User not found" }, status: :not_found
      end
    rescue => e
      is_server_error(e)
    end
  end

  def create
    begin
      @user = User.new(user_params)
      if @user.save
        render json: @user.slice(:id, :name, :email, :is_admin), status: :created
      else
        render json: { error: @user.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
    rescue => e
      is_server_error(e)
    end
  end

  def update
    begin
      if is_admin?
        if @user.update(user_params)
          render json: @user.slice(:id, :name, :email, :is_admin)
        else
          render json: { error: @user.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      else
        render json: { error: "You are not authorized to update this user" }, status: :unauthorized
      end
    rescue => e
      is_server_error(e)
    end
  end

  def destroy
    begin
      if is_admin?
        @user.destroy
        render json: { message: "User deleted successfully" }, status: :ok
      else
        render json: { error: "You are not authorized to delete this user" }, status: :unauthorized
      end
    rescue => e
      is_server_error(e)
    end
  end

  private

  def user_params
    params.permit(:name, :email, :password)
  end

  def set_user
    begin
      @user = User.find(params[:id])
    rescue => e
      render json: { error: "User not found" }, status: :not_found
      return
    end
  end
end