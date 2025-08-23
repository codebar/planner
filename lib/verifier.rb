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
    @verifier ||= begin
      # This is a Rails 7.1 MessageVerifier, which is Rails 7.0-compatible verifier - as a fallback.
      #
      # Read more:
      # https://api.rubyonrails.org/v7.0/classes/ActiveSupport/MessageVerifier.html
      # https://api.rubyonrails.org/v7.1/classes/ActiveSupport/MessageVerifier.html
      # https://api.rubyonrails.org/v8.0.2.1/classes/ActiveSupport/MessageVerifier.html

      verifier = ActiveSupport::MessageVerifier.new(Rails.application.config.secret_key_base)
      # Rails 7.0 default: Marshal. Rails 7.1 (the default) is :json_allow_marshal.
      verifier.rotate(serializer: Marshal)
      # Rails 7.0 default: "SHA1". Rails 7.1 (the default) is "SHA256".
      verifier.rotate(digest: 'SHA1')
      verifier
    end
  end

  def generate_access_token
    verifier.generate(id)
  end
end
