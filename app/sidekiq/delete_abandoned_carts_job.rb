class DeleteAbandonedCartsJob
  include Sidekiq::Job

  def perform
    Cart.remove_pending_deletion_carts
  end
end
