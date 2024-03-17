class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null:false
      t.string :surname, null:true # Surname is not mandatory (company don't have them)
      t.string :type, null:false
      t.string :email, null:false
      t.string :phone, null:true
      t.date :date_of_birth, null:true
      t.string :address, null:true
      t.string :cap, null:true
      t.string :province, null:true
      t.string :city, null:true
      t.string :country, null:true

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
