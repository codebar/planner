class InvitationPresenter < SimpleDelegator
  def self.decorate_collection(collection)
    collection.map { |e| InvitationPresenter.new(e) }
  end

  def member
    @member ||= MemberPresenter.new(model.member)
  end

  def attendance_status
    model.attending ? 'Attending' : 'RSVP'
  end

  private

  def model
    __getobj__
  end
end
