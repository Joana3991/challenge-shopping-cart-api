require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  describe '#perform' do
    it 'marks carts inactive beyond the threshold as abandoned' do
      last_interaction_at = (Cart::ABANDONMENT_THRESHOLD + 1.hour).ago
      cart = create(:cart, last_interaction_at:, abandoned_at: nil)

      described_class.new.perform

      expect(cart.reload.abandoned_at).not_to be_nil
    end

    it 'does not change active carts' do
      cart = create(:cart, last_interaction_at: 1.hour.ago)

      described_class.new.perform

      expect(cart.reload.abandoned_at).to be_nil
    end
  end
end
