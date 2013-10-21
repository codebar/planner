class Sessions < ActiveRecord::Base

  scope :upcoming, ->  { where("date_and_time > ?",  DateTime.now) }
end
