module Auditor
  class Audit
    attr_reader :model, :key, :user, :recipient

    def initialize(model, key, user, recipient = nil)
      @model = model
      @key = key
      @user = user
      @recipient = recipient
    end

    def log(&block)
      changes = model.changes
      result = yield block if block

      create(changes)

      result
    end

    def log_with_note(note)
      create(note: note)
    end

    private

    def create(changes)
      PublicActivity::Activity.create(trackable: model,
                                      key: key,
                                      owner: user,
                                      recipient: recipient,
                                      parameters: changes)
    end
  end

  module Model
    def activities
      PublicActivity::Activity.where(trackable: self).order(created_at: :desc)
    end
  end
end
