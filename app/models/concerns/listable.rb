module Listable
  extend ActiveSupport::Concern

  included do

    scope :upcoming, -> { unscoped.where("date_and_time >= ?", DateTime.now-6.hours).order(:date_and_time) }
    scope :past, -> { where("date_and_time < ?", DateTime.now).order(:date_and_time) }
  end

  module ClassMethods
    def next
      upcoming.load.first
    end
  end
end
