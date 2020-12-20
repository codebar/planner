class Sponsorship < ActiveRecord::Base
  belongs_to :event
  belongs_to :sponsor

  before_validation :set_empty_to_nil
  validates :level, inclusion: { in: ['gold', 'silver', 'bronze', nil] }

  protected

  def set_empty_to_nil
    self.level = nil if level == ''
  end
end
