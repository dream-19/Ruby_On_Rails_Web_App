module ApplicationHelper
    # Helper to format time
    def format_time(time)
        time.strftime('%H:%M')
    end

    #Helper to format date
    def format_date(date)
        date.strftime('%d-%m-%Y')
    end
end
