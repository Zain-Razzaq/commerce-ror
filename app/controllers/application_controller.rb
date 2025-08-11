class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern


  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def user_logged_in?
    current_user.present?
  end
  
  def is_admin?
    current_user.is_admin? if current_user
  end

  def require_admin
    unless is_admin?
      render json: { error: "You are not authorized to access this resource" }, status: :unauthorized
      return
    end
  end

  def is_server_error(e)
    render json: { error: e.message }, status: :internal_server_error
  end
end
