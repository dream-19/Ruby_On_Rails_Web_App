class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :name
      t.time :beginning_time
      t.date :beginning_date
      t.time :ending_time
      t.date :ending_date
      t.integer :max_participants
      t.string :address
      t.string :cap
      t.string :province
      t.string :state
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
