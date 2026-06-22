# Expects `existing_product` to be defined within example context
shared_context 'cart exists in session with product' do
  let(:cart) { Cart.find(session[:cart_id]) }
  before do
    post '/cart', params: { product_id: existing_product.id, quantity: 2 }, as: :json
  end
end


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
