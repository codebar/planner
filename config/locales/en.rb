{
  en: {
    time: {
      formats: {
        _humanize_date: ->(datetime, _) { "%a, #{datetime.day.ordinalize} %B" },
        _humanize_date_with_year: ->(datetime, _) { "%a, #{datetime.day.ordinalize} %B %Y" },
        _humanize_date_with_time: ->(datetime, _) { "%a, #{datetime.day.ordinalize} %B at %R" },
        _humanize_date_with_year_with_time: ->(datetime, _) { "%a, #{datetime.day.ordinalize} %B %Y at %R" }
      }
    }
  }
}
