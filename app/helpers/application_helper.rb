module ApplicationHelper
    # Helper to format time
    def format_time(time)
        time.strftime('%H:%M')
    end

    #Helper to format date
    def format_date(date)
        date.strftime('%d-%m-%Y')
    end

    #Helper to format date time: dd-mm-yyyy hh:mm
    def format_datetime(date_time)
        date_time.strftime('%d-%m-%Y %H:%M')
    end

    #Helper to format date time
    def format_date_with_time(date, time)
        datetime = DateTime.parse("#{date} #{time.strftime('%T')}")
        datetime.strftime('%d-%m-%Y %H:%M') # Customize this format as needed
      end
end
