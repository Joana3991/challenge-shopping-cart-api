require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  describe '.pending_abandonment' do
    it 'returns carts past the abandonment threshold and not yet abandoned' do
      pending_carts = create_list(:cart, 2, last_interaction_at: 4.hours.ago)
      create(:cart, last_interaction_at: 1.hour.ago)
      create(:cart, last_interaction_at: 4.hours.ago, abandoned_at: 1.hour.ago)

      expect(described_class.pending_abandonment).to match_array(pending_carts)
    end
  end

  describe '.pending_deletion' do
    it 'returns carts past the deletion threshold' do
      create(:cart, abandoned_at: 4.hours.ago)
      create(:cart, abandoned_at: nil)
      cart_01 = create(:cart, abandoned_at: 7.days.ago)
      cart_02 = create(:cart, abandoned_at: 8.days.ago)

      expect(Cart.pending_deletion).to match_array([cart_01, cart_02])
    end
  end

  describe '.abandon_pending_carts' do
    subject { described_class.abandon_pending_carts }
  
    it 'sets abandoned_at for all carts pending abandonment' do
      cart_01 = create(:cart, last_interaction_at: 5.hour.ago, abandoned_at: nil)
      cart_02 = create(:cart, last_interaction_at: 4.hours.ago, abandoned_at: nil)

      subject
      expect(cart_01.reload.abandoned_at).to eq(cart_01.last_interaction_at)
      expect(cart_02.reload.abandoned_at).to eq(cart_02.last_interaction_at)
    end

    it 'does not update carts that should not be abandoned' do
      cart = create(:cart, last_interaction_at: 1.hour.ago, abandoned_at: nil)

      subject
      expect(cart.reload.abandoned_at).to be_nil
    end
  end

  describe '.self.remove_pending_deletion_carts' do
    subject { described_class.remove_pending_deletion_carts }

    it 'deletes carts abandoned past the deletion threshold' do
      cart_01 = create(:cart, abandoned_at: 7.days.ago)
      cart_02 = create(:cart, abandoned_at: 8.days.ago)

      subject

      expect(Cart.exists?(cart_01.id)).to be false
      expect(Cart.exists?(cart_02.id)).to be false
    end

    it 'does not delete carts not abandoned' do
      active_cart = create(:cart, abandoned_at: nil)

      subject

      expect(Cart.exists?(active_cart.id)).to be true
    end

    it 'does not delete carts abandoned within the threshold' do
      recent_abandoned_cart = create(:cart, abandoned_at: 4.hours.ago)

      subject

      expect(Cart.exists?(recent_abandoned_cart.id)).to be true
    end
  end

  describe '#add_product_to_cart' do
    let!(:cart) { create(:cart, total_price: 10.0) }
    let(:product) { create(:product, price: 15.0) }

    subject { cart.add_product_to_cart(product:, quantity: 2) }

    it 'adds product to cart' do 
      expect { subject }.to change { cart.cart_items.count }.by(1)
      expect(CartItem.last.product).to eq(product)  
    end

    it 'updates the cart total_price' do
      subject
      expect(cart.reload.total_price).to eq(40.0)
    end

    include_examples 'updates last_interaction_at'
    include_examples 'sets abandoned_at to nil'
  end

  describe '#add_or_update_item' do
    let(:product) { create(:product) }
    let(:cart) { create(:cart) }

    subject { cart.add_or_update_item(product:, quantity: 2) }

    # TODO add specs for update total price
    context 'when product is not in the cart' do
      it 'adds the product to the cart' do
        expect { subject }.to change { cart.cart_items.count }.by(1)
      end

      include_examples 'updates last_interaction_at'
      include_examples 'sets abandoned_at to nil'
    end

    context 'when product is already in the cart' do
      let!(:cart_item) { create(:cart_item, cart:, product:, quantity: 1) }

      it 'updates the item quantity' do
        subject
        expect(cart_item.reload.quantity).to eq(3)
      end

      it 'does not create new cart_item' do
        expect { subject }.not_to change { cart.cart_items.count }
      end

      include_examples 'updates last_interaction_at'
      include_examples 'sets abandoned_at to nil'
    end
  end

  describe '#remove_product!' do 
    let(:product) { create(:product, price: 10) }
    let(:cart) { create(:cart, total_price: 100) }
    let!(:cart_item) { create(:cart_item, cart:, product:, quantity: 2) }

    subject { cart.remove_product!(product.id) }

    context 'when product is in the cart' do
      it 'removes product from cart' do 
        expect { subject }.to change { cart.cart_items.count }.by(-1)
        expect(cart.products).not_to include(product)
      end
      
      it 'updates total price' do 
        expect { subject }.to change { cart.total_price }.by(-20)
      end

      include_examples 'updates last_interaction_at'
      include_examples 'sets abandoned_at to nil'
    end

    # TODO add specs for total_price
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
