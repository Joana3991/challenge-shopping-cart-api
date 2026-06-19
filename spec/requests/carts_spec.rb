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

  describe "POST /cart" do
    let(:product) { create(:product) }
    subject do
      post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json
    end

    it "adds the product to the cart" do
      expect { subject }.to change(CartItem, :count).by(1)

      cart_item = CartItem.last
      expect(cart_item.product).to eq(product)
      expect(cart_item.cart).to eq(Cart.last)
      expect(cart_item.quantity).to eq(2)
    end

    it "returns the cart with products" do
      subject
      cart = Cart.last
      expect(response.parsed_body).to eq(
        "id" => cart.id,
        "products" => [
          {
            "id" => product.id,
            "name" => product.name,
            "quantity" => 2,
            "unit_price" => product.price.to_s,
            "total_price" => (product.price * 2).to_s
          }
        ],
        "total_price" => (product.price * 2).to_s
      )
    end

    it "returns status 200" do
      subject
      expect(response).to have_http_status(:ok)
    end

    context "when cart does not exist in the session" do
      it "creates a new cart" do
        expect { subject }.to change(Cart, :count).by(1)
      end

      it "saves the cart id in the session" do
        subject
        expect(session[:cart_id]).to eq(Cart.last.id)
      end

      it "updates cart total_price" do
        subject
        expect(Cart.last.total_price).to eq(product.price * 2)
      end
    end

    context "when cart already exists in the session" do
      before do
        post "/cart", params: { product_id: product.id, quantity: 2 }, as: :json
      end

      it "does not create a new cart" do
        expect { subject }.not_to change(Cart, :count)
      end

      it "updates cart total_price correctly" do
        expect { subject }.to change { Cart.last.total_price }.by(product.price * 2)
      end

      it "adds product to existing cart" do
        cart = Cart.find(response.parsed_body["id"])
        subject
        expect(CartItem.last.cart).to eq(cart)
      end
    end

    context "when product is not found" do
      it "returns not found status" do
        post '/cart', params: { product_id: 999999, quantity: 1 }
        expect(response).to have_http_status(:not_found)
      end

      it "returns error message" do
        post '/cart', params: { product_id: 999999, quantity: 1 }
        expect(response.parsed_body["error"]).to eq("Product not found")
      end
    end
  end

  describe "GET /cart" do
    subject { get '/cart', as: :json }

    context "when cart does not exist in the session" do
      it "creates new cart" do
        expect { subject }.to change(Cart, :count).by(1)
      end

      it "returns empty cart" do
        subject
        expect(response.parsed_body).to match(
          "id" => be_a(Integer),
          "products" => [],
          "total_price" => "0.0"
        )
      end
    end

    context "when cart exists in the session" do
      let(:product_01) { create(:product, name: "shampoo", price: 10.0) }
      let(:product_02) { create(:product, name: "soap", price: 3.2) }

      before do
        post '/cart', params: { product_id: product_01.id, quantity: 2 }, as: :json
        post '/cart', params: { product_id: product_02.id, quantity: 1 }, as: :json
      end

      it "returns the cart with products" do
        subject
        cart = Cart.last
        expect(response.parsed_body).to match(
          "id" => cart.id,
          "products" => [
            {
              "id" => be_a(Integer),
              "name" => "shampoo",
              "quantity" => 2,
              "unit_price" => "10.0",
              "total_price" => "20.0"
            },
            {
              "id" => be_a(Integer),
              "name" => "soap",
              "quantity" => 1,
              "unit_price" => "3.2",
              "total_price" => "3.2"
            }
          ],
          "total_price" => "23.2"
        )
      end
    end
  end

  # TODO add tests for response
  describe "PATCH /cart/add_item" do
    context "when product already in the cart" do
      let(:product) { create(:product) }
      subject do
        patch "/cart/add_item", params: { product_id: product.id, quantity: 2 }, as: :json
      end

      before do 
        post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json
      end

      it "updates product quantity in cart" do 
        cart = Cart.find(session[:cart_id])
        cart_item = CartItem.find_by(cart:, product:)
  
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end

    context "when product is not in the cart" do
      let(:product_01) { create(:product) }
      let(:product_02) { create(:product) }

      subject do
        patch "/cart/add_item", params: { product_id: product_01.id, quantity: 2 }, as: :json
      end

      before do 
        post '/cart', params: { product_id: product_02.id, quantity: 2 }, as: :json
      end

      it "adds product to the cart" do
        expect { subject }.to change(CartItem, :count).by(1)

        cart_item = CartItem.last
        expect(cart_item.product).to eq(product_01)
        expect(cart_item.cart).to eq(Cart.find(session[:cart_id]))
        expect(cart_item.quantity).to eq(2)
      end
    end
  end
end
