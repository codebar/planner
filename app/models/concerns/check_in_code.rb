# frozen_string_literal: true

module CheckInCode
  extend ActiveSupport::Concern

  WORD_LIST_PATH = Rails.root.join("lib", "words", "check_in_words.txt")

  class_methods do
    def word_list
      @word_list ||= File.readlines(WORD_LIST_PATH).map(&:strip).freeze
    end
  end

  included do
    before_create :set_check_in_code
  end

  def generate_check_in_code!
    loop do
      code = self.class.word_list.sample(3).join("-")
      unless self.class.exists?(check_in_code: code)
        update_column(:check_in_code, code)
        return code
      end
    end
  end

  def check_in_url
    prefix = model_name.singular == "event" ? "e" : "w"
    route_name = :"check_in_#{prefix}_url"
    Rails.application.routes.url_helpers.public_send(
      route_name, check_in_code
    )
  end

  private

  def set_check_in_code
    loop do
      self.check_in_code = self.class.word_list.sample(3).join("-")
      break unless self.class.exists?(check_in_code: check_in_code)
    end
  end
end
