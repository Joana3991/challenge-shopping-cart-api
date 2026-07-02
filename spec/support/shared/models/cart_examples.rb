shared_examples 'updates last_interaction_at' do
  it 'updates last_interaction_at' do
    freeze_time do
      expect { subject }
        .to change { cart.reload.last_interaction_at }
        .to(Time.current)
    end
  end
end

shared_examples 'sets abandoned_at to nil' do
  before { cart.update!(abandoned_at: 1.hour.ago) }

  it 'sets abandoned_at to nil' do
    subject
    expect(cart.reload.abandoned_at).to be_nil
  end
end

shared_examples 'updates the cart total_price' do |quantity_delta:|
  it 'updates total_price' do
    expect { subject }.to change { cart.reload.total_price }.by(product.price * quantity_delta)
  end
end
