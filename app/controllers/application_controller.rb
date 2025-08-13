class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern


  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def user_logged_in?
    current_user.present?
  end

  def require_admin
    unless current_user&.is_admin
      render json: { error: "You are not authorized for this action" }, status: :unauthorized
      return
    end
  end

  def is_server_error(e)
    render json: { error: e.message }, status: :internal_server_error
  end

  def product_json(product)
    {
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      stock: product.stock,
      is_active: product.is_active,
      category_id: product.category_id,
      images: product.images.map { |img| url_for(img) }
    }
  end
end
