# frozen_string_literal: true

module CheckInCode
  extend ActiveSupport::Concern

  # Check-in codes are built from the EFF long wordlist for random passphrases.
  # Source: https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt
  # More info: https://www.eff.org/deeplinks/2016/07/new-wordlists-random-passphrases
  WORD_LIST_PATH = Rails.root.join('lib/words/check_in_words.txt')
  MAX_ATTEMPTS = 100
  CHECK_IN_WINDOW_START_OFFSET = 1.hour
  CHECK_IN_WINDOW_END_FALLBACK = 2.hours

  class_methods do
    def word_list
      @word_list ||= File.readlines(WORD_LIST_PATH)
                         .map(&:strip)
                         .reject { |line| line.empty? || line.start_with?('#') }
                         .freeze
    end
  end

  included do
    before_create :set_check_in_code
  end

  def generate_check_in_code!
    attempts = 0
    loop do
      update!(check_in_code: unique_check_in_code)
      return check_in_code
    rescue ActiveRecord::RecordNotUnique
      attempts += 1
      raise if attempts >= MAX_ATTEMPTS
    end
  end

  def check_in_open?
    now = Time.zone.now
    return false unless date_and_time

    window_start = date_and_time - CHECK_IN_WINDOW_START_OFFSET
    window_end = ends_at || date_and_time + CHECK_IN_WINDOW_END_FALLBACK
    now >= window_start && now <= window_end
  end

  def spaces_available_for?(role)
    spaces = role == 'Student' ? student_spaces : coach_spaces
    attending = role == 'Student' ? attending_students.count : attending_coaches.count
    attending < spaces
  end

  def check_in_url
    prefix = model_name.singular == 'event' ? 'e' : 'w'
    route_name = :"check_in_#{prefix}_url"
    Rails.application.routes.url_helpers.public_send(
      route_name, check_in_code
    )
  end

  private

  def unique_check_in_code
    MAX_ATTEMPTS.times do
      code = self.class.word_list.sample(3).join('-')
      return code unless self.class.exists?(check_in_code: code)
    end

    raise 'Unable to generate a unique check-in code'
  end

  def set_check_in_code
    self.check_in_code = unique_check_in_code
  end
end
