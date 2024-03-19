class AddCityToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :city, :string
  end
end
