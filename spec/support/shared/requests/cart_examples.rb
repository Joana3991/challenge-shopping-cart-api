# Expects `expected_cart_items` to be defined within example context
# format: hash of { product => quantity }
shared_examples 'returns cart with products' do
  it 'returns the cart JSON' do
    subject
    cart = Cart.find(session[:cart_id])
    products = expected_cart_items.map do |product, quantity|
      {
        "id" => product.id,
        "name" => product.name,
        "quantity" => quantity,
        "unit_price" => product.price.to_s,
        "total_price" => (product.price * quantity).to_s
      }
    end

    expect(response.parsed_body).to eq(
      "id" => cart.id,
      "products" => products,
      "total_price" => cart.total_price.to_s
    )
  end
end

shared_examples 'returns status 200' do
  it 'returns status ok' do
    subject
    expect(response).to have_http_status(:ok)
  end
end

shared_examples 'returns empty cart' do
  it 'returns empty cart json' do
    subject
    expect(response.parsed_body).to match(
      "id" => be_a(Integer),
      "products" => [],
      "total_price" => "0.0"
    )
  end
end

shared_examples 'adds new product to cart' do |quantity|
  it 'creates a cart item with the correct attributes' do
    expect { subject }.to change(CartItem, :count).by(1)

    cart_item = cart.reload.cart_items.find_by(product:)
    expect(cart_item).to be_present
    expect(cart_item.quantity).to eq(quantity)
  end
end

shared_examples 'updates cart total_price' do |quantity_delta|
  it 'updates cart total_price' do
    expect { subject }.to change { cart.reload.total_price }.by(product.price * quantity_delta)
  end
end

shared_examples 'cart not found' do
  context 'when session[:cart_id] is present but cart is not' do
    before do 
      get '/cart', as: :json
      Cart.destroy_all
      subject
    end

    it 'returns not_found status' do
      expect(response).to have_http_status(:not_found)
    end

    it 'returns error message' do
      expect(response.parsed_body['error']).to eq('Cart not found')
    end
  end


  context 'when session[:cart_id] is not present' do
    before { subject }

    it 'returns not_found status' do
      expect(response).to have_http_status(:not_found)
    end

    it 'returns error message' do
      expect(response.parsed_body['error']).to eq('Cart not found')
    end
  end
end
