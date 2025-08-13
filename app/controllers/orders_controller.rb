class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :require_admin, only: [:index, :update, :destroy]

  def index
    begin
      @orders = Order.all.includes(:order_items)
      render json: @orders.map { |order| {
        id: order.id,
        status: order.status,
        shipping_address: order.shipping_address,
        created_at: order.created_at,
        products: order.order_items.map { |item| {
          id: item.id,
          quantity: item.quantity,
          price: item.price,
        }.merge({
          product_id: item.product_id,
          product_name: item.product.name,
        }) }
      } }
    rescue => e
      is_server_error(e)
    end
  end

  def create
    begin
      Order.transaction do
        @order = current_user.orders.create!(order_params)
        params[:products].each do |product|
          @order.order_items.create(product_id: product[:product_id], quantity: product[:quantity], price: Product.find(product[:product_id]).price)
        end
        current_user.cart.cart_items.destroy_all
        render json: @order
      end
    rescue => e
      is_server_error(e)
    end
  end

  def update
    begin
      Order.transaction do
        @order = Order.find(params[:id])
        @order.order_items.each do |item|
          if item.product.stock >= item.quantity
            item.product.update!(stock: item.product.stock - item.quantity)
          else
            raise "Product stock is not enough"
          end
        end
        @order.update!(status: "approved")
      end
      render json: @order
    rescue => e
      if e.message == "Product stock is not enough"
        render json: { error: e.message }, status: :unprocessable_entity
      else
        is_server_error(e)
      end
    end
  end
  

  def destroy
    begin
      Order.find(params[:id]).destroy
      render json: { message: "Order deleted successfully" }, status: :ok
    rescue => e
      is_server_error(e)
    end
  end

  def user_orders
    begin
      @orders = current_user.orders.includes(:order_items)
      render json: @orders.map { |order| {
        id: order.id,
        status: order.status,
        shipping_address: order.shipping_address,
        created_at: order.created_at,
        products: order.order_items.map { |item| {
          id: item.id,
          quantity: item.quantity,
          price: item.price,
        }.merge({
          product_id: item.product_id,
          product_name: item.product.name,
        }) }
      } }
    rescue => e
      is_server_error(e)
    end
  end

  private

  def order_params
    params.permit(:shipping_address, :products)
  end
end