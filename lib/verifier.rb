require 'active_support'

class Verifier
  attr_reader :id, :token

  def initialize(hash)
    @id = hash.fetch(:id) { nil }
    @token = hash.fetch(:token) { nil }
  end

  def access_token
    generate_access_token
  end

  def verify(model)
    id = verifier.verify(token)
    model.find_by(id: id)
  end

  private

  def verifier
    @verifier ||= ActiveSupport::MessageVerifier.new(Planner::Application.config.secret_token)
  end

  def generate_access_token
    verifier.generate(id)
  end
end
