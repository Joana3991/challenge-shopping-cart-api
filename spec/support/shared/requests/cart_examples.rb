# Expects `product` to be defined within example context
# Creates cart with product quantity 2
RSpec.shared_context 'cart exists in session with product' do
  let(:cart) { Cart.find(session[:cart_id]) }
  
  before do
    post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json
  end
end

# Expects `expected_items` to be defined within example context
# format: hash of { product => quantity }
RSpec.shared_examples 'returns cart with products' do
  # TODO avaliate the following
  # it 'returns status 200' do
  #   subject
  #   expect(response).to have_http_status(:ok)
  # end

  it 'returns the cart JSON' do
    subject
    cart = Cart.find(session[:cart_id])
    products = expected_items.map do |product, quantity|
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

RSpec.shared_examples 'returns empty cart' do
    it 'returns empty cart json' do
      subject
      expect(response.parsed_body).to match(
        "id" => be_a(Integer),
        "products" => [],
        "total_price" => "0.0"
      )
    end
end
