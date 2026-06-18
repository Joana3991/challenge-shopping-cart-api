require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  # describe 'mark_as_abandoned' do
  #   let(:shopping_cart) { create(:shopping_cart) }

  #   it 'marks the shopping cart as abandoned if inactive for a certain time' do
  #     shopping_cart.update(last_interaction_at: 3.hours.ago)
  #     expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned? }.from(false).to(true)
  #   end
  # end

  # describe 'remove_if_abandoned' do
  #   let(:shopping_cart) { create(:shopping_cart, last_interaction_at: 7.days.ago) }

  #   it 'removes the shopping cart if abandoned for a certain time' do
  #     shopping_cart.mark_as_abandoned
  #     expect { shopping_cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
  #   end
  # end

  describe '#add_product_to_cart' do
    let!(:cart) { create(:cart, total_price: 10.0) }
    let(:product) { create(:product, price: 15.0) }

    it 'adds product to cart' do 
      expect { cart.add_product_to_cart(product:, quantity: 1) }
        .to change { cart.cart_items.count }.by(1)
      expect(CartItem.last.product).to eq(product)  
    end

    it 'updates the cart total_price' do
      cart.add_product_to_cart(product:, quantity: 2)

      expect(cart.reload.total_price).to eq(40.0)
    end
  end
end
