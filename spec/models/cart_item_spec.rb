require 'rails_helper'

RSpec.describe CartItem, type: :model do
  let(:cart) { Cart.create!(total_price: 0) }
  let(:product) { Product.create!(name: 'Produto Teste', price: 9.99) }

  context 'when validating quantity' do
    it 'validates presence of quantity' do
      cart_item = described_class.new(cart:, product:)

      expect(cart_item.valid?).to be_falsey
      expect(cart_item.errors[:quantity]).to include("can't be blank")
    end

    it 'validates numericality of quantity' do
      cart_item = described_class.new(cart:, product:, quantity: 0)

      expect(cart_item.valid?).to be_falsey
      expect(cart_item.errors[:quantity]).to include("must be greater than 0")
    end
  end

  context 'when validating associations' do 
    it 'is invalid without a cart' do
      cart_item = described_class.new(product:, quantity: 1)

      expect(cart_item.valid?).to be_falsey
      expect(cart_item.errors[:cart]).to include("must exist")
    end

    it 'is invalid without a product' do
      cart_item = described_class.new(cart:, quantity: 1)

      expect(cart_item.valid?).to be_falsey
      expect(cart_item.errors[:product]).to include("must exist")
    end
  end
end
