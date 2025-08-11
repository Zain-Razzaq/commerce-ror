class ProductsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_product, only: [:show, :update, :destroy]
  # before_action :require_admin, only: [:create, :update, :destroy]

  def index
    begin
      @products = Product.all.select(:id, :name, :price, :description, :is_active, :category_id)
      render json: @products
    rescue => e
      is_server_error(e)
    end
  end

  # def index
  #   begin
  #     # Sorting
  #     sort_column = params[:sort].presence_in(%w[name price created_at]) || "created_at"
  #     sort_order  = params[:order].to_s.downcase == "desc" ? "desc" : "asc"
  
  #     # Base query
  #     products = Product.select(:id, :name, :price, :description, :is_active, :category_id)
  
  #     # Filtering
  #     products = products.where(category_id: params[:category_id]) if params[:category_id].present?
  #     products = products.where(is_active: ActiveModel::Type::Boolean.new.cast(params[:is_active])) if params[:is_active].present?
  
  #     # Apply sorting
  #     products = products.order("#{sort_column} #{sort_order}")
  
  #     # Apply Kaminari pagination
  #     products = products.page(params[:page]).per(params[:per_page] || 10)
  
  #     render json: {
  #       products: products,
  #       meta: {
  #         current_page: products.current_page,
  #         per_page: products.limit_value,
  #         total_count: products.total_count,
  #         total_pages: products.total_pages,
  #         sort: sort_column,
  #         order: sort_order
  #       }
  #     }
  #   rescue => e
  #     is_server_error(e)
  #   end
  # end
  

  def show
    begin
      if @product
        render json: @product.slice(:id, :name, :description, :price, :stock, :is_active)
      else
        render json: { error: "Product not found" }, status: :not_found
      end
    rescue => e
      is_server_error(e)
    end
  end

  def create
    begin
      product = Product.new(product_params)
      if product.save
        render json: product, status: :created
      else
        render json: { error: product.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
    rescue => e
      is_server_error(e)
    end
  end

  def update
    begin
      if @product.update(product_params)
        render json: @product, status: :ok
      else
        render json: { error: @product.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
    rescue => e
      is_server_error(e)
    end
  end

  def destroy
    begin
      @product.destroy
      render json: { message: "Product deleted successfully" }, status: :ok
    rescue => e
      is_server_error(e)
    end
  end

  private

  def product_params
    params.permit(:name, :description, :price, :stock, :category_id, :is_active)
  end

  def set_product
    begin
      @product = Product.find(params[:id])
    rescue => e
      render json: { error: "Product not found" }, status: :not_found
      return
    end
  end

  
end