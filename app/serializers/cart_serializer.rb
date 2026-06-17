class CartSerializer

  def initialize(cart)
    @cart = cart
  end

  def as_json
    {
      id: cart.id,
      products: serialized_cart_items,
      total_price: cart.total_price
    }
  end

  private

  attr_reader :cart

  def serialized_cart_items
    cart.cart_items.includes(:product).map do |cart_item|
      CartItemSerializer.new(cart_item).as_json
    end
  end
end
