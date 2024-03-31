class RemoveSubscriptionTimeAndDateFromSubscriptions < ActiveRecord::Migration[7.1]
  def change
    remove_column :subscriptions, :subscription_time, :time
    remove_column :subscriptions, :subscription_date, :date
  end
end
