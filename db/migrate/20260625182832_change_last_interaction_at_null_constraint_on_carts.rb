class ChangeLastInteractionAtNullConstraintOnCarts < ActiveRecord::Migration[7.1]
  def change
    change_column_null :carts, :last_interaction_at, false
  end
end
