class ProductsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_product, only: [:show, :update, :destroy]
  # before_action :require_admin, only: [:create, :update, :destroy]

  def index
    begin
      @products = Product.all
      per_page = (params[:per_page] || 4).to_i
      @products = @products.page(params[:page]).per(per_page)
      render json: {
        products: @products.map { |product| product_json(product) },
        pagination: {
          current_page: @products.current_page,
          total_pages: @products.total_pages
        }
      }, status: :ok
    rescue => e
      is_server_error(e)
    end
  end

  def show
    begin
      if @product
        render json: product_json(@product).merge(category_name: @product.category.name), status: :ok
      else
        render json: { error: "Product not found" }, status: :not_found
      end
    rescue => e
      is_server_error(e)
    end
  end

  def search
    begin
      @products = Product.all
      if params[:name].present?
        @products = @products.where("LOWER(name) LIKE ?", "%#{params[:name].downcase}%")
      end

      @products = @products.where(price: params[:min_price]..params[:max_price]) if params[:min_price].present? && params[:max_price].present?
      @products = @products.where(price: ..params[:max_price]) if params[:max_price].present? && params[:min_price].blank?
      @products = @products.where(price: params[:min_price]..) if params[:min_price].present? && params[:max_price].blank?
    
  
      # Filter by category
      if params[:category_id].present?
        @products = @products.where(category_id: params[:category_id])
      end
  
      # Pagination
      per_page = (params[:per_page] || 4).to_i
      @products = @products.page(params[:page]).per(per_page)
  
      render json: {
        products: @products.map { |product| product_json(product) },
        pagination: {
          current_page: @products.current_page,
          total_pages: @products.total_pages
        }
      }, status: :ok
  
    rescue => e
      is_server_error(e)
    end
  end
  
  def create
    begin
      product = Product.new(product_params.except(:images))
      if product.save
        if params[:images].present?
          params[:images].each do |image|
            product.images.attach(image)
          end
        end
        render json: product_json(product), status: :created
      else
        render json: { error: product.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
    rescue => e
      is_server_error(e)
    end
  end

  def update
    begin
      handle_image_updates

      if @product.update(product_params.except(:images, :existing_images))
        render json: product_json(@product), status: :ok
      else
        render json: { error: @product.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
    rescue => e
      is_server_error(e)
    end
  end

  def destroy
    begin
      @product.images.purge
      @product.destroy
      render json: { message: "Product deleted successfully" }, status: :ok
    rescue => e
      is_server_error(e)
    end
  end

  def by_ids
    begin
      @products = Product.where(id: params[:ids])
      render json: @products.map { |product| product_json(product) }, status: :ok
    rescue => e
      is_server_error(e)
    end
  end

  private

  def product_params
    params.permit(:name, :description, :price, :stock, :category_id, :is_active, images: [], existing_images: [])
  end

  def set_product
    begin
      @product = Product.find(params[:id])
    rescue => e
      render json: { error: "Product not found" }, status: :not_found
      return
    end
  end

  def handle_image_updates
    existing_image_urls = params[:existing_images] || []
    
    current_image_urls = @product.images.map { |img| url_for(img) }
    
    images_to_delete = @product.images.select do |img|
      current_url = url_for(img)
      !existing_image_urls.include?(current_url)
    end
    
    images_to_delete.each { |img| img.purge }
    
    if params[:images].present?
      params[:images].each do |image|
        @product.images.attach(image)
      end
    end
  end
  
end