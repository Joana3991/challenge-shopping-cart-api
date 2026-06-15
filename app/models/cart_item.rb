class CartItem < ApplicationRecord
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  belongs_to :cart
  belongs_to :product
end
