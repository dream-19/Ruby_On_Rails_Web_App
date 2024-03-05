class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :surname
      t.string :email
      t.string :phone
      t.date :date_of_birth
      t.string :address
      t.string :cap
      t.string :province
      t.string :state
      t.string :password

      t.timestamps
    end
  end
end
