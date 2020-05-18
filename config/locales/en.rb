{
  en: {
    date: {
      formats: {
        humanised: lambda { |time, _| "%a, #{time.day.ordinalize} %B" },
      }
    },
    time: {
      formats: {
        humanised: lambda { |time, _| "%a, #{time.day.ordinalize} %B" },
        humanised_with_time: lambda { |time, _| "%a, #{time.day.ordinalize} %B | %H:%M" },
        humanised_with_year: lambda { |time, _| "%a, #{time.day.ordinalize} %B %Y | %H:%M" }
      }
    }
  }
}
