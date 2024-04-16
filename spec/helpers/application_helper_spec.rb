# spec/helpers/application_helper_spec.rb
require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#format_time' do
    it 'formats the time as HH:MM' do
      time = Time.new(2023, 4, 15, 16, 30)
      expect(helper.format_time(time)).to eq('16:30')
    end
  end

  describe '#format_date' do
    it 'formats the date as DD-MM-YYYY' do
      date = Date.new(2023, 4, 15)
      expect(helper.format_date(date)).to eq('15-04-2023')
    end
  end

  describe '#format_datetime' do
    it 'formats the datetime as DD-MM-YYYY HH:MM' do
      datetime = DateTime.new(2023, 4, 15, 16, 30)
      expect(helper.format_datetime(datetime)).to eq('15-04-2023 16:30')
    end
  end

  describe '#format_date_with_time' do
    it 'combines the date and time and formats it as DD-MM-YYYY HH:MM' do
      date = Date.new(2023, 4, 15)
      time = Time.new(2023, 4, 15, 16, 30)
      expect(helper.format_date_with_time(date, time)).to eq('15-04-2023 16:30')
    end
  end
end
