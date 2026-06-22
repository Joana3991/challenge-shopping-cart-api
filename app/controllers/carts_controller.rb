class CartsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  before_action :set_cart

  def create
    @cart.add_product_to_cart(**resolved_cart_item_params)

    render json: CartSerializer.new(@cart).as_json
  end

  def show
    render json: CartSerializer.new(@cart).as_json
  end

  def add_item
    @cart.add_or_update_item(**resolved_cart_item_params)

    render json: CartSerializer.new(@cart).as_json
  end

  def destroy
    @cart.remove_product!(params[:product_id])

    render json: CartSerializer.new(@cart).as_json
  end

  private

  def set_cart
    @cart = find_or_create_cart
  end

  def find_or_create_cart
    Cart.find_by(id: session[:cart_id]) || create_cart
  end

  def create_cart
    Cart.create!.tap do |cart|
      session[:cart_id] = cart.id
    end
  end

  def resolved_cart_item_params
    { 
      product: Product.find(cart_item_params[:product_id]),
      quantity: cart_item_params[:quantity]
    }
  end

  def cart_item_params
    params.permit(:product_id, :quantity)
  end

  def record_not_found(exception)
    render json: { error: "#{exception.model} not found" }, status: :not_found
  end
end
