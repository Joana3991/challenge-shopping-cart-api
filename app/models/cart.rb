class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado

  def add_or_update_item(product:, quantity:)
    item = cart_items.find_by(product:)
    return add_product_to_cart(product:, quantity:) unless item

    update_item_quantity(product:, quantity:, item:)
  end

  def add_product_to_cart(product:, quantity:)
    ActiveRecord::Base.transaction do
      cart_items.create!(product:, quantity:)
      update_total_price(product:, quantity:)
    end
  end

  def remove_product!(product_id)
    item = cart_items.includes(:product).find_by!(product_id:)

    ActiveRecord::Base.transaction do
      update_total_price(
        product: item.product,
        quantity: -item.quantity
      )
      item.destroy
    end

  end

  private

  def update_item_quantity(product:, quantity:, item:)
    ActiveRecord::Base.transaction do
      item.increment!(:quantity, quantity)
      update_total_price(product:, quantity:)
    end
  end

  def update_total_price(product:, quantity:)
    update!(total_price: total_price + product.price * quantity)
  end
end
