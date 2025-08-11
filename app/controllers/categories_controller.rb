class CategoriesController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_category, only: [ :update, :destroy]
  # before_action :require_admin, only: [:create, :update, :destroy]

  def index
    begin
      @categories = Category.all.select(:id, :name)
      render json: @categories
    rescue => e
      is_server_error(e)
    end
  end

  # def show
  #   begin
  #     if @category
  #       render json: @category.slice(:id, :name)
  #     else
  #       render json: { error: "Category not found" }, status: :not_found
  #     end
  #   rescue => e
  #     is_server_error(e)
  #   end
  # end

  def create
    begin
      @category = Category.create(category_params)
      render json: @category
    rescue => e
      is_server_error(e)
    end
  end

  def update
    begin
      @category.update(category_params)
      render json: @category
    rescue => e
      is_server_error(e)
    end
  end

  def destroy
    begin
      @category.destroy
      render json: { message: "Category deleted successfully" }, status: :ok
    rescue => e
      is_server_error(e)
    end
  end

  private

  def category_params
    params.permit(:name)
  end

  def set_category
    begin
      @category = Category.find(params[:id])
    rescue => e
      render json: { error: "Category not found" }, status: :not_found
      return
    end
  end
end