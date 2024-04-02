class ChangeMessageToTextInNotifications < ActiveRecord::Migration[7.1]
  def change
    change_column :notifications, :message, :text
  end
end
