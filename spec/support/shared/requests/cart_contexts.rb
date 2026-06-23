shared_context 'cart exists in session empty' do
  before do
    get '/cart', as: :json
  end

  let(:cart) { Cart.find(session[:cart_id]) }
end

# Expects `existing_product` to be defined within example context
shared_context 'cart exists in session with product' do |quantity: 2|
  before do
    post '/cart', params: { product_id: product.id, quantity: }, as: :json
  end

  let(:cart) { Cart.find(session[:cart_id]) }
end