class TermsAndConditionsForm
  include ActiveModel::Model

  attr_accessor :terms

  validates :terms, acceptance: true
end
