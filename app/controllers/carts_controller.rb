class CartsController < ApplicationController
  def create
    @cart = find_or_create_cart
    add_product_to_cart
    render json: CartSerializer.new(@cart).as_json
  end

  private

  def find_or_create_cart
    Cart.find_by(id: session[:cart_id]) || create_cart
  end

  def create_cart
    Cart.create!(total_price: 0).tap do |cart|
      session[:cart_id] = cart.id
    end
  end

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
