# Carrinho de Compras API — Desafio Técnico

🌎 Idioma:
- 🇧🇷 Português (atual)
- [🇺🇸 English](README.md)

## Sobre o projeto

API REST para gerenciamento de carrinhos de compras de e-commerce, desenvolvida em Ruby on Rails como solução para um desafio técnico. 

A aplicação utiliza sessões para identificar o carrinho ativo e Sidekiq para processamento assíncrono do gerenciamento de carrinhos abandonados.

## Funcionalidades

- Criação automática de um carrinho associado à sessão do usuário.
- Adição e remoção de produtos do carrinho.
- Atualização da quantidade de produtos já existentes no carrinho.
- Listagem dos produtos e cálculo automático do valor total.
- Identificação e remoção automáticas de carrinhos abandonados por meio de background jobs.

## Padrões adotados

- Arquitetura seguindo o padrão **Fat Model / Skinny Controller**.
- **Serializers** para padronização das respostas da API.
- Suíte de testes desenvolvida com **RSpec**, utilizando shared examples e shared contexts para reduzir duplicação de código.
- Histórico de commits organizado utilizando **Conventional Commits**.

## API

Endpoints solicitados:

### `POST /cart`

Adiciona um produto ao carrinho. Caso não exista um carrinho ativo na sessão, um novo carrinho é criado automaticamente.

**Payload**

```json
{
  "product_id": 345,
  "quantity": 2
}
```

### `GET /cart`

Retorna o carrinho associado à sessão atual. Caso não exista, um novo carrinho vazio é criado e retornado.

### `POST /cart/add_item`

Atualiza a quantidade de um produto já existente no carrinho.

Caso o carrinho não exista na sessão ou o produto não seja encontrado, retorna **404**.

**Payload**

```json
{
  "product_id": 1230,
  "quantity": 1
}
```

### `DELETE /cart/:product_id`

Remove um produto do carrinho.

Caso o carrinho não exista na sessão ou o produto não seja encontrado, retorna **404**.

### Formato das respostas

Todos os endpoints retornam o carrinho com produtos no seguinte formato:

```json
{
  "id": 789,
  "products": [
    {
      "id": 645,
      "name": "Nome do produto",
      "quantity": 2,
      "unit_price": 1.99,
      "total_price": 3.98
    },
    {
      "id": 646,
      "name": "Nome do produto 2",
      "quantity": 2,
      "unit_price": 1.99,
      "total_price": 3.98
    }
  ],
  "total_price": 7.96
}
```

### Gerenciamento de carrinhos abandonados

O gerenciamento de carrinhos abandonados é realizado por background jobs utilizando Sidekiq.

- Carrinhos sem interação por mais de **3 horas** são marcados como abandonados.
- Carrinhos abandonados há mais de **7 dias** são removidos automaticamente.

## Tecnologias

- Ruby 3.3.1
- Rails 7.1.3.2
- PostgreSQL 16
- Redis 7.0.15
- Sidekiq
- RSpec

## Como executar o projeto

Instalar as dependências:
```bash
bundle install
```

Executar o Sidekiq:
```bash
bundle exec sidekiq
```

Executar o projeto:
```bash
bundle exec rails server
```

Executar os testes:
```bash
bundle exec rspec
```


