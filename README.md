# Shopping Cart API — Technical Challenge

🌎 Language:
- [🇧🇷 Português](README.pt-BR.md)
- 🇺🇸 English (current)

## About the project

REST API for managing e-commerce shopping carts, developed in Ruby on Rails as a solution to a technical challenge.

The application uses sessions to identify the active shopping cart and Sidekiq for asynchronous processing of abandoned carts.

## Features

- Automatic creation of a shopping cart associated with the user's session.
- Add and remove products from the shopping cart.
- Update the quantity of existing products.
- List cart items and automatically calculate the total price.
- Automatically identify and remove abandoned shopping carts through background jobs.

## Design patterns and practices

- **Fat Model / Skinny Controller** architecture.
- **Serializers** to standardize API responses.
- Test suite built with **RSpec**, using shared examples and shared contexts to reduce code duplication.
- Organized Git history following **Conventional Commits**.

## API

Required endpoints:

### `POST /cart`

Adds a product to the shopping cart. If there is no active cart in the current session, a new one is created automatically.

**Payload**

```json
{
  "product_id": 345,
  "quantity": 2
}
```

### `GET /cart`

Returns the shopping cart associated with the current session. If no cart exists, a new empty cart is created and returned.

### `POST /cart/add_item`

Updates the quantity of an existing product in the shopping cart.

Returns **404** if the cart does not exist in the current session or the product cannot be found.

**Payload**

```json
{
  "product_id": 1230,
  "quantity": 1
}
```

### `DELETE /cart/:product_id`

Removes a product from the shopping cart.

Returns **404** if the cart does not exist in the current session or the product cannot be found.

### Response format

All endpoints return the shopping cart with products in the following format:

```json
{
  "id": 789,
  "products": [
    {
      "id": 645,
      "name": "Product name",
      "quantity": 2,
      "unit_price": 1.99,
      "total_price": 3.98
    },
    {
      "id": 646,
      "name": "Product name 2",
      "quantity": 2,
      "unit_price": 1.99,
      "total_price": 3.98
    }
  ],
  "total_price": 7.96
}
```

### Abandoned cart management

Abandoned shopping carts are managed through background jobs using Sidekiq.

- Shopping carts with no activity for more than **3 hours** are marked as abandoned.
- Shopping carts abandoned for more than **7 days** are automatically removed.

## Technologies

- Ruby 3.3.1
- Rails 7.1.3.2
- PostgreSQL 16
- Redis 7.0.15
- Sidekiq
- RSpec

## Running the project

Install the dependencies:

```bash
bundle install
```

Start Sidekiq:

```bash
bundle exec sidekiq
```

Start the application:

```bash
bundle exec rails server
```

Run the test suite:

```bash
bundle exec rspec
````
