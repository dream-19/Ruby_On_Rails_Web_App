class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.time :subscription_time, null:false
      t.date :subscription_date, null:false

      t.timestamps
    end
  end
end
