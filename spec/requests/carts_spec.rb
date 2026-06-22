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

    context 'when cart does not exist in the session' do
      let(:cart) { Cart.find(session[:cart_id]) }
      let(:expected_cart_items) { { product => 2 } }

      subject do
        post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json
      end

      it 'creates a new cart' do
        expect { subject }.to change(Cart, :count).by(1)
      end

      it 'saves the cart id in the session' do
        subject
        expect(session[:cart_id]).to eq(Cart.last.id)
      end

      it 'updates cart total_price' do
        subject
        expect(cart.total_price).to eq(product.price * 2)
      end

      include_examples 'adds new product to cart', 2
      include_examples 'returns cart with products'
    end

    context 'when cart already exists in the session' do
      let(:existing_product) { create(:product) }
      let(:expected_cart_items) { { existing_product => 2, product => 1 } }
      include_context 'cart exists in session with product'

      subject do
        post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'does not create a new cart' do
        expect { subject }.not_to change(Cart, :count)
      end

      include_examples 'adds new product to cart', 1
      include_examples 'updates cart total_price', 1
      include_examples 'returns status 200'
    end

    context 'when product is not found' do
      it 'returns not_found status' do
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

      include_examples 'returns empty cart'
    end

    context 'when cart exists in the session' do
      let(:existing_product) { create(:product) }
      let(:expected_cart_items) { { existing_product => 2 } }
      include_context 'cart exists in session with product'

      include_examples 'returns cart with products'
      include_examples 'returns status 200'
    end
  end

  describe 'PATCH /cart/add_item' do
    let(:existing_product) { create(:product) }
    include_context 'cart exists in session with product'
    subject do
      patch '/cart/add_item', params: { product_id: product.id, quantity: 3 }, as: :json
    end
    
    context 'when product already in the cart' do
      let(:product) { existing_product }
      let(:expected_cart_items) { { product => 5 } }


      it 'updates product quantity in cart' do 
        cart_item = CartItem.find_by(cart:, product:)
  
        expect { subject }.to change { cart_item.reload.quantity }.by(3)
      end

      include_examples 'updates cart total_price', 3
      include_examples 'returns cart with products'
      include_examples 'returns status 200'
    end

    context 'when product is not in the cart' do
      let(:product) { create(:product) }
      let(:expected_cart_items) { { existing_product => 2, product => 3 } }

      include_examples 'adds new product to cart', 3
      include_examples 'updates cart total_price', 3
      include_examples 'returns cart with products'
      include_examples 'returns status 200'
    end
  end

  describe 'DELETE /cart/:product_id' do
    let(:existing_product) { create(:product) }
    include_context 'cart exists in session with product'
    
    context 'when product is in the cart' do
      let(:product) { existing_product }
      subject do
        delete "/cart/#{product.id}", as: :json
      end

      it 'removes the product from cart' do
        expect { subject }.to change{cart.reload.cart_items.count }.by(-1)
        expect(CartItem.find_by(cart:, product:)).to be_nil
      end

      context 'when product was the last item in cart' do
        it 'updates total_price' do
          subject
          expect(cart.total_price).to eq(0)
        end

        include_examples 'returns empty cart'
        include_examples 'returns status 200'
      end

      context 'when there were other products in cart' do
        let(:other_product) { create(:product) }
        let(:expected_cart_items) {{ other_product => 1 }}
        before do 
          create(:cart_item, cart:, product: other_product, quantity: 1) 
        end

        include_examples 'updates cart total_price', -2
        include_examples 'returns cart with products'
        include_examples 'returns status 200'
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
