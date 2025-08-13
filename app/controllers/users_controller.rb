class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_user, only: [:show]

  def show
    begin
      render json: @user.slice(:id, :name, :email, :is_admin)
    rescue => e
      is_server_error(e)
    end
  end

  def create
    begin
      @user = User.new(user_params)
      if @user.save
        session[:user_id] = @user.id
        render json: @user.slice(:id, :name, :email, :is_admin), status: :created
      else
        render json: { error: @user.errors.full_messages.to_sentence }, status: :unprocessable_entity
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