require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do
  let(:user) { create(:user_normal) }
  let(:notification) { create(:notification, user: user, read: false) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'assigns all notifications as @notifications' do
      get :index
      expect(assigns(:notifications)).to match_array(user.notifications.order(created_at: :desc).page(1).per(10))
      expect(assigns(:notifications_read)).to eq(user.notifications.where(read: true).count)
      expect(assigns(:notifications_unread)).to eq(user.notifications.where(read: false).count)
    end
  end

  describe 'GET #show' do
    it 'marks the notification as read' do
      get :show, params: { id: notification.id }, xhr: true
      notification.reload
      expect(notification.read).to be true
    end

    it 'renders the show template via AJAX' do
      get :show, params: { id: notification.id }, xhr: true
      expect(response).to render_template(:show)
    end
  end

  describe 'PUT #mark_as_read' do
    it 'marks the notification as read and redirects' do
      put :mark_as_read, params: { id: notification.id }
      notification.reload
      expect(notification.read).to be true
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'PUT #mark_all_as_read' do
    it 'marks all notifications as read' do
      create_list(:notification, 3, user: user, read: false)
      put :mark_all_as_read
      user.notifications.reload
      expect(user.notifications.where(read: false).count).to eq(0)
      expect(response).to redirect_to(notifications_path)
      expect(flash[:notice]).to eq("All notifications marked as read.")
    end
  end

  describe 'Private method set_notification' do
    it 'correctly sets the notification for the current user' do
      controller.params = { id: notification.id }
      controller.send(:set_notification)
      expect(assigns(:notification)).to eq(notification)
    end
  end
end
