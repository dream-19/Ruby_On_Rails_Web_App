require 'rails_helper'

RSpec.describe NotificationService do
  let(:user) { create(:user_normal) }
  
  let(:user_organizer) { create(:user_organizer) }
  let(:event) { create(:event, user: user_organizer) }

  describe '.create_notification_subscribe' do
    it 'creates notifications for both the subscriber and the event organizer' do
      expect {
        NotificationService.create_notification_subscribe(user: user, event: event, user_organizer: user_organizer)
      }.to change { Notification.count }.by(3)
    end
  end

  describe '.create_notification_unsubscribe' do
    it 'creates notifications for both the unsubscriber and the event organizer' do
      expect {
        NotificationService.create_notification_unsubscribe(user: user, event: event, user_organizer: user_organizer)
      }.to change { Notification.count }.by(3)
    end
  end

  describe '.create_notification_unsubscribe_delete' do
    it 'creates a notification for the event organizer about the unsubscribe due to account deletion' do
      expect {
        NotificationService.create_notification_unsubscribe_delete(user: user, event: event, user_organizer: user_organizer)
      }.to change { Notification.count }.by(2)
    end
  end

  describe '.create_notification_remove_user' do
    it 'creates notifications for both the removed user and the event organizer' do
      expect {
        NotificationService.create_notification_remove_user(user: user, event: event, user_organizer: user_organizer)
      }.to change { Notification.count }.by(3)
    end
  end

  describe '.create_notification_create_event' do
    it 'creates a notification for the event organizer about event creation' do
      expect {
        NotificationService.create_notification_create_event(user_organizer: user_organizer, event: event)
      }.to change { Notification.count }.by(2)
    end
  end

  describe '.create_notification_update_event' do
    let(:update_message) { "Important changes" }

    it 'creates notifications for the event organizer and all subscribers' do
      create(:subscription, user: user, event: event)  # Assuming a Subscription model exists
      expect {
        NotificationService.create_notification_update_event(user_organizer: user_organizer, event: event, update: update_message)
      }.to change { Notification.count }.by(2)
    end
  end

  describe '.create_notification_delete_event' do
    it 'creates notifications for the event organizer and all subscribers about event deletion' do
      create(:subscription, user: user, event: event)  # Assuming a Subscription model exists
      expect {
        NotificationService.create_notification_delete_event(user_organizer: user_organizer, event: event)
      }.to change { Notification.count }.by(2)
    end
  end

  describe '.create_notification_full_capacity' do
    it 'creates a notification for the event organizer about reaching full capacity' do
      expect {
        NotificationService.create_notification_full_capacity(user_organizer: user_organizer, event: event)
      }.to change { Notification.count }.by(2)
    end
  end
end
