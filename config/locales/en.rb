{
  en: {
    time: {
      formats: {
        humanize_date: ->(datetime, _) { "%a, #{datetime.day.ordinalize} %B" },
        humanize_date_with_year: ->(datetime, _) { "%a, #{datetime.day.ordinalize} %B %Y" },
        humanize_date_with_time: ->(datetime, _) { "%a, #{datetime.day.ordinalize} %B at %R" },
        humanize_date_with_year_with_time: ->(datetime, _) { "%a, #{datetime.day.ordinalize} %B %Y at %R" }
      }
    }
  }
}
