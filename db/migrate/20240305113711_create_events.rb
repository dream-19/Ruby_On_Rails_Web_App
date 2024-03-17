class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :name, null:false
      t.time :beginning_time, null:false
      t.date :beginning_date, null:false
      t.time :ending_time, null:false
      t.date :ending_date, null:false
      t.integer :max_participants, null:false
      t.string :address, null:false
      t.string :cap, null:false
      t.string :province, null:false
      t.string :country, null:false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
