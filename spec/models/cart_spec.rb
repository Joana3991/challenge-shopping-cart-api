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

  describe '#update_item_quantity' do
    let(:cart) { create(:cart, total_price: 10.0) }
    let(:product) { create(:product, price: 15.0) }
    let!(:cart_item) { create(:cart_item, quantity: 1, product:, cart:) }

    it 'updates the item quantity' do
      cart.update_item_quantity(product:, quantity: 2)

      expect(cart_item.reload.quantity).to eq(3)
    end

    it 'updates the cart total_price' do
      cart.update_item_quantity(product:, quantity: 2)

      expect(cart.reload.total_price).to eq(40.0)
    end
  end

  describe '#add_or_update_item' do
    let(:product) { create(:product) }
    let(:cart) { create(:cart) }

    context 'when product is not in the cart' do
      it 'adds the product to the cart' do
        expect { cart.add_or_update_item(product:, quantity: 2) }
          .to change { cart.cart_items.count }.by(1)
      end
    end

    context 'when product is already in the cart' do
      let!(:cart_item) { create(:cart_item, cart:, product:, quantity: 1) }

      it 'updates the item quantity' do
        cart.add_or_update_item(product:, quantity: 2)
        expect(cart_item.reload.quantity).to eq(3)
      end

      it 'does not create new cart_item' do
        expect { cart.add_or_update_item(product:, quantity: 2) }
          .not_to change { cart.cart_items.count }
      end
    end
  end

  describe '#remove_product!' do 
    let(:product) { create(:product, price: 10) }
    let(:cart) { create(:cart, total_price: 100) }
    let!(:cart_item) { create(:cart_item, cart:, product:, quantity: 2) }

    context 'when product is in the cart' do
      it 'removes product from cart' do 
        expect { cart.remove_product!(product.id) }
          .to change { cart.cart_items.count }.by(-1)
        expect(cart.products).not_to include(product)
      end
      
      it 'updates total price' do 
        expect { cart.remove_product!(product.id) }
          .to change { cart.total_price }.by(-20)
      end
    end

    context 'when product is not in the cart' do
      let(:unrelated_product) { create(:product) }

      it 'raises RecordNotFound and does not change cart state' do
        initial_items_count = cart.cart_items.count

        expect { cart.remove_product!(unrelated_product.id) }
          .to raise_error(ActiveRecord::RecordNotFound)

        expect(cart.total_price).to eq(100)
        expect(cart.cart_items.count).to eq(initial_items_count)
      end
    end
  end
end
