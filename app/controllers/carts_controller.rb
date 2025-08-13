class CartsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def show
    begin
      @cart = current_user.cart || current_user.create_cart
      @cart_items = @cart.cart_items.includes(:product)
      render json: @cart_items.map { |cart_item| {
        cart_item_id: cart_item.id,
        quantity: cart_item.quantity
      }.merge(product_json(cart_item.product))
}
    rescue => e
      is_server_error(e)
    end
  end

  def update
    begin
      @cart = current_user.cart || current_user.create_cart
      params[:cartItems].each do |product|
        @cart.cart_items.create(product_id: product[:productId], quantity: product[:quantity])
      end
      render json: @cart
    rescue => e
      is_server_error(e)
    end
  end

end