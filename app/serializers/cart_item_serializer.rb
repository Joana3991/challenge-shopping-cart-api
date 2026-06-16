class CartItemSerializer
  def initialize(cart_item)
    @cart_item = cart_item
  end

  def as_json
    {
      id: product.id,
      name: product.name,
      quantity: cart_item.quantity,
      unit_price: product.price,
      total_price: cart_item.total_price
    }
  end

  private

  attr_reader :cart_item
  delegate :product, to: :cart_item
end
