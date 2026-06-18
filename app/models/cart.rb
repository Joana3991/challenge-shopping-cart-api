class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado

  def add_product_to_cart(product:, quantity:)
    ActiveRecord::Base.transaction do
      cart_items.create!(product:, quantity:)
      update_total_price(product:, quantity:)
    end
  end

  private

  def update_total_price(product:, quantity:)
    update!(total_price: total_price + product.price * quantity)
  end
end
