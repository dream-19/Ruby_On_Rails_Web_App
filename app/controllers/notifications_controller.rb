class NotificationsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_notification, only: [:show, :mark_as_read]
  
    def index
      @notifications = current_user.notifications.order(created_at: :desc).page(params[:page]).per(10)
      @notifications_read = current_user.notifications.where(read: true).count
      @notifications_unread = current_user.notifications.where(read: false).count
    end
  
    def show
      @notification = Notification.find(params[:id])
      @notification.update(read: true) 
      @notifications = current_user.first_n_unread(10)
      @n_not = current_user.count_unread
      respond_to do |format|
        format.js # for AJAX
      end
    end
  
    def mark_as_read
      @notification.update(read: true)
      redirect_back(fallback_location: root_path)
    end
    
    def mark_all_as_read
        current_user.notifications.where(read: false).update_all(read: true)
        @notifications = current_user.first_n_unread(10)
        @n_not = current_user.count_unread
        @notifications_read = current_user.notifications.where(read: true).count
        @notifications_unread = current_user.notifications.where(read: false).count
        respond_to do |format|
            format.html { redirect_to notifications_path, notice: 'All notifications marked as read.' }
            format.js #ajax requests (menù)
        end
    end
  
    private
  
    def set_notification
      @notification = current_user.notifications.find(params[:id])
    end
  end
  