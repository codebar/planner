module Invitable
  extend ActiveSupport::Concern

  included do
    include InstanceMethods
  end

  module InstanceMethods

    def attending_invitations
      invitations.accepted
    end

  end
end
