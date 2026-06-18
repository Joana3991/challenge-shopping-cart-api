class CartsController < ApplicationController
  before_action :set_cart

  def create
    add_product_to_cart
    render json: CartSerializer.new(@cart).as_json
  end

  def show
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

  # TODO move logic to Cart model
  # TODO add error handling for RecordNotFound
  def add_product_to_cart
    product_id, quantity = cart_item_params.values_at(:product_id, :quantity)
  
    ActiveRecord::Base.transaction do
      product = Product.find(product_id)
      CartItem.create!(product:, cart: @cart, quantity:)
      @cart.update_total_price(product, quantity)
    end
  end

  def cart_item_params
    params.permit(:product_id, :quantity)
  end
end
