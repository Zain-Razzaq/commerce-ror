class CartItemsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_cart, only: [:create, :update, :destroy]

  def create
    begin
      @cart_item = @cart.cart_items.create(cart_item_params)
      render json: @cart_item
    rescue => e
      is_server_error(e)
    end
  end

  def update
    begin
      @cart_item = @cart.cart_items.find(params[:id])
      @cart_item.update(quantity: params[:quantity])
      render json: @cart_item
    rescue => e
      is_server_error(e)
    end
  end

  def destroy
    begin
      @cart_item = @cart.cart_items.find(params[:id])
      @cart_item.destroy
      render json: { message: "Cart item deleted successfully" }
    rescue => e
      is_server_error(e)
    end
  end

  private
  def cart_item_params
    params.permit(:product_id, :quantity)
  end

  def set_cart
    @cart = current_user.cart || current_user.create_cart
  end
end