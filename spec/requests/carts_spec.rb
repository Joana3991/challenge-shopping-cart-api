require 'rails_helper'

RSpec.describe "/carts", type: :request do
  # pending "TODO: Escreva os testes de comportamento do controller de carrinho necessários para cobrir a sua implmentação #{__FILE__}"
  # describe "POST /add_items" do
  #   let(:cart) { Cart.create }
  #   let(:product) { Product.create(name: "Test Product", price: 10.0) }
  #   let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

  #   context 'when the product already is in the cart' do
  #     subject do
  #       post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
  #       post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
  #     end

  #     it 'updates the quantity of the existing item in the cart' do
  #       expect { subject }.to change { cart_item.reload.quantity }.by(2)
  #     end
  #   end
  # end

  describe 'POST /cart' do
    let(:product) { create(:product) }
    let(:expected_items) { { product => 2 } }

    subject do
      post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json
    end

    it 'adds the product to the cart' do
      expect { subject }.to change(CartItem, :count).by(1)

      cart_item = CartItem.last
      expect(cart_item.product).to eq(product)
      expect(cart_item.cart).to eq(Cart.last)
      expect(cart_item.quantity).to eq(2)
    end

    include_examples 'returns cart with products'

    context 'when cart does not exist in the session' do
      it 'creates a new cart' do
        expect { subject }.to change(Cart, :count).by(1)
      end

      it 'saves the cart id in the session' do
        subject
        expect(session[:cart_id]).to eq(Cart.last.id)
      end

      it 'updates cart total_price' do
        subject
        expect(Cart.last.total_price).to eq(product.price * 2)
      end
    end

    context 'when cart already exists in the session' do
      include_context 'cart exists in session with product'

      it 'does not create a new cart' do
        expect { subject }.not_to change(Cart, :count)
      end

      it 'updates cart total_price correctly' do
        expect { subject }.to change { cart.reload.total_price }.by(product.price * 2)
      end

      it 'adds product to existing cart' do
        subject
        expect(CartItem.last.cart).to eq(cart)
      end
    end

    context 'when product is not found' do
      it 'returns not found status' do
        post '/cart', params: { product_id: 999999, quantity: 1 }
        expect(response).to have_http_status(:not_found)
      end

      it 'returns error message' do
        post '/cart', params: { product_id: 999999, quantity: 1 }
        expect(response.parsed_body['error']).to eq('Product not found')
      end
    end
  end

  describe 'GET /cart' do
    subject { get '/cart', as: :json }

    context 'when cart does not exist in the session' do
      it 'creates new cart' do
        expect { subject }.to change(Cart, :count).by(1)
      end

      it 'returns empty cart' do
        subject
        expect(response.parsed_body).to match(
          "id" => be_a(Integer),
          "products" => [],
          "total_price" => "0.0"
        )
      end
    end

    context 'when cart exists in the session' do
      include_context 'cart exists in session with product'

      let(:product) { create(:product) }
      let(:product_02) { create(:product) }
      let(:expected_items) { { product => 2, product_02 => 1 } }

      before do
        post '/cart', params: { product_id: product_02.id, quantity: 1 }, as: :json
      end

      include_examples 'returns cart with products'
    end
  end

  describe 'PATCH /cart/add_item' do
    let(:product) { create(:product) }
    include_context 'cart exists in session with product'

    context 'when product already in the cart' do
      let(:expected_items) { { product => 5 } } # 2 from shared_context POST + 3 from this PATCH
      subject do
        patch '/cart/add_item', params: { product_id: product.id, quantity: 3 }, as: :json
      end

      it 'updates product quantity in cart' do 
        cart_item = CartItem.find_by(cart:, product:)
  
        expect { subject }.to change { cart_item.reload.quantity }.by(3)
      end

      include_examples 'returns cart with products'
    end

    context 'when product is not in the cart' do
      let(:product_02) { create(:product) }
      let(:expected_items) { { product => 2, product_02 => 3 } }

      subject do
        patch '/cart/add_item', params: { product_id: product_02.id, quantity: 3 }, as: :json
      end

      it 'adds product to the cart' do
        expect { subject }.to change(CartItem, :count).by(1)

        cart_item = CartItem.last
        expect(cart_item.product).to eq(product_02)
        expect(cart_item.cart).to eq(cart)
        expect(cart_item.quantity).to eq(3)
      end

      include_examples 'returns cart with products'
    end
  end

  describe 'DELETE /cart/:product_id' do
    let(:product) { create(:product) }
    include_context 'cart exists in session with product'
    
    context 'when product is in the cart' do
      subject do
        delete "/cart/#{product.id}", as: :json
      end

      it 'removes product from cart' do
        expect { subject }.to change{cart.reload.cart_items.count }.by(-1)
      end

      it 'updates cart total_price correctly' do
        expect { subject }.to change { cart.reload.total_price }.by(product.price * -2)
      end

      context 'when product was the last item in cart' do
        include_examples 'returns empty cart'
      end

      context 'when there were other products in cart' do
        let(:other_product) { create(:product) }
        let(:expected_items) {{ other_product => 1 }}
        before do 
          create(:cart_item, cart:, product: other_product, quantity: 1) 
        end
        include_examples 'returns cart with products'
      end
    end

    context 'when product is not in the cart' do
      let(:other_product) { create(:product) }

      subject do
        delete "/cart/#{other_product.id}", as: :json
      end

      it 'returns error message' do
        subject
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body['error']).to eq('CartItem not found')
      end

      it 'does not change cart total_price' do
        expect { subject }.not_to change { cart.reload.total_price }
      end
    end
  end

end
