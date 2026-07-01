class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    Cart.abandon_pending_carts
  end
end
