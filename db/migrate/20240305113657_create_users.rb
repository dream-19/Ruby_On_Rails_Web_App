class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null:false
      t.string :surname, null:false
      t.string :role, null:false, default:'normal'
      t.string :email, null:false
      t.string :phone, null:true
      t.date :date_of_birth, null:false
      t.string :address, null:false
      t.string :cap, null:false
      t.string :province, null:false
      t.string :city, null:false
      t.string :state, null:false

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
