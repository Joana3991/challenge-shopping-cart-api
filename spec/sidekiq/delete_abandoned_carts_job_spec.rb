require 'rails_helper'

RSpec.describe DeleteAbandonedCartsJob, type: :job do
  describe '#perform' do
    it 'removes carts pending deletion' do
      cart = create(:cart, abandoned_at: (Cart::DELETION_THRESHOLD + 1.day).ago)

      described_class.new.perform

      expect(Cart.exists?(cart.id)).to be false
    end

    it 'does not remove carts not yet pending deletion' do
      cart = create(:cart, abandoned_at: (Cart::DELETION_THRESHOLD - 1.day).ago)

      described_class.new.perform

      expect(Cart.exists?(cart.id)).to be true
    end
  end
end
