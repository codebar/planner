require 'faraday'

module Flodesk
  # Subscriber status
  ACTIVE = 'active'.freeze

  class Client
    API_ENDPOINT = 'https://api.flodesk.com/v1/'.freeze
    DEFAULT_TIMEOUT = 60

    class_attribute :api_key
    class_attribute :complete_timeout
    class_attribute :open_timeout

    # Allows for setting these values in `config/initializers/flodesk.rb`
    class << self
      def api_key
        @@api_key
      end

      def complete_timeout
        @@complete_timeout
      end

      def open_timeout
        @@open_timeout
      end
    end

    attr_accessor :api_endpoint, :debug, :logger

    # We need 3 actions:
    #
    #   1. subscribe   --> params(list_id, email, first_name, last_name)
    #      Documentation:  https://developers.flodesk.com/#tag/subscriber/operation/createOrUpdateSubscriber
    #      Endpoint:       https://api.flodesk.com/v1/subscribers
    #
    #   2. unsubscribe --> params(list_id, email)
    #      Documentation:  https://developers.flodesk.com/#tag/subscriber/operation/removeSubscriberFromSegments
    #      Endpoint:       https://api.flodesk.com/v1/subscribers/{id_or_email}/segments
    #
    #   3. subscribed? --> params(list_id, email)
    #      Documentation:  https://developers.flodesk.com/#tag/subscriber/operation/retrieveSubscriber
    #      Endpoint:       https://api.flodesk.com/v1/subscribers/{id_or_email}

    def initialize(api_key: nil, complete_timeout: nil, open_timeout: nil)
      @api_key = api_key || self.class.api_key || ENV['FLODESK_KEY']
      @api_key = @api_key.strip if @api_key

      @complete_timeout = complete_timeout || self.class.complete_timeout || DEFAULT_TIMEOUT
      @open_timeout = open_timeout || self.class.open_timeout || DEFAULT_TIMEOUT
    end

    def disabled?
      !@api_key
    end

    def subscribe(email:, first_name:, last_name:, segment_ids:, double_optin: true)
      body = { email:, first_name:, last_name:, segment_ids:, double_optin: }

      request(:post, 'subscribers', body)
    end

    def unsubscribe(email:, segment_ids:)
      body = { segment_ids: }

      request(:delete, "subscribers/#{email}/segments", body)
    end

    def subscribed?(email:, segment_ids:)
      response = request(:get, "subscribers/#{email}")
      response => { status:, body: }

      return false if response.is_a?(FlodeskError) && status == 404

      body.symbolize_keys => { status:, segments: }

      # If not subscribed, stop here
      is_active = status.to_s.eql?(ACTIVE)
      return false unless is_active

      segment_ids.all? do |segment_id|
        segments.any? { |segment| segment_id.to_s.eql?(segment.symbolize_keys[:id]) }
      end
    end

    private

    def connection
      options = {
        headers: {
          user_agent: 'codebar (codebar.io)'
        },
        request: {
          timeout: @complete_timeout,
          open_timeout: @open_timeout
        }
      }

      # https://lostisland.github.io/faraday/#/customization/request-options
      @connection ||= Faraday.new(url: API_ENDPOINT, **options) do |config|
        config.request :json

        # Beware: the order of these lines matter. Examples:
        # - https://mattbrictson.com/blog/advanced-http-techniques-in-ruby#pitfall-raise_error-and-logger-in-the-wrong-order
        # - https://stackoverflow.com/a/67182791/590525
        config.response :raise_error
        config.response :logger, Rails.logger, headers: true, bodies: true, log_level: :debug
        config.response :json

        # https://developers.flodesk.com/#section/Authentication/api_key
        config.request :authorization, 'Basic', -> { @api_key }
      end
    end

    def request(http_method, endpoint, body = {})
      # Faraday's `delete` does not accept body at the time of writing
      response = if http_method == :delete
        connection.run_request(http_method, endpoint, body, nil)
      else
        connection.public_send(http_method, endpoint, body)
      end

      {
        status: response.status,
        body: response.body
      }
    rescue Faraday::Error => e
      FlodeskError.new(e.response_body['message'], {
                         raw_body: e.response_body,
                         status_code: e.response_status
                       })
    end
  end

  # Inspired by https://github.com/amro/gibbon/blob/master/lib/gibbon/mailchimp_error.rb
  class FlodeskError < StandardError
    attr_reader :status_code, :raw_body

    def initialize(message = '', params = {})
      @status_code = params[:status_code]
      @raw_body    = params[:raw_body]

      super(message)
    end

    def to_s
      "#{super} #{instance_variables_to_s}"
    end

    private

    def instance_variables_to_s
      %i[status_code raw_body].map do |attr|
        attr_value = send(attr)

        "@#{attr}=#{attr_value.inspect}"
      end.join(', ')
    end
  end
end
