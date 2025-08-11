class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    begin
      user = User.find_by(email: params[:email])
      if user&.authenticate(params[:password])
        session[:user_id] = user.id
      render json: user.slice(:id, :name, :email, :is_admin), status: :created
      else
        render json: {
          message: "Invalid email or password"
        }, status: :unprocessable_entity
      end
    rescue => e
      is_server_error(e)
    end
  end

  def destroy
    begin
      session[:user_id] = nil
      render json: { message: 'Logged out successfully' }, status: :ok
    rescue => e
      is_server_error(e)
    end
  end
end
