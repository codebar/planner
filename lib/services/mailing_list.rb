module Services
  class MailingList
    attr_reader :list_id

    def initialize(list_id)
      @list_id = list_id
    end

    def subscribe(email, first_name, last_name)
      return if client.disabled?

      client.subscribe(email:, first_name:, last_name:, segment_ids: [@list_id])
    rescue Flodesk::FlodeskError => e
      Rollbar.error(e, list_id: @list_id, email:)
      false
    end
    handle_asynchronously :subscribe

    def unsubscribe(email)
      return if client.disabled?

      client.unsubscribe(email:, segment_ids: [@list_id])
    rescue Flodesk::FlodeskError => e
      Rollbar.error(e, list_id: @list_id, email:)
      false
    end
    handle_asynchronously :unsubscribe

    private

    def client
      @client ||= Flodesk::Client.new
    end
  end
end
