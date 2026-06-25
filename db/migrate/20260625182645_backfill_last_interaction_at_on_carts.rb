class BackfillLastInteractionAtOnCarts < ActiveRecord::Migration[7.1]
  def up
    Cart.where(last_interaction_at: nil).in_batches do |batch|
      batch.update_all(last_interaction_at: Time.current)
    end
  end

  def down
    # no-op
  end
end
