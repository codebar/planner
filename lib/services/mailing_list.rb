module Services
  class MailingList
    attr_reader :list_id

    def initialize(list_id)
      @list_id = list_id
    end

    def subscribe(email, first_name, last_name)
      return if client.disabled?

      client.subscribe(email:, first_name:, last_name:, segment_ids: [@list_id])
    rescue Flodesk::FlodeskError
      false
    end
    handle_asynchronously :subscribe

    def unsubscribe(email)
      return if client.disabled?

      client.unsubscribe(email:, segment_ids: [@list_id])
    rescue Flodesk::FlodeskError
      false
    end
    handle_asynchronously :unsubscribe

    def subscribed?(email)
      return if client.disabled?

      client.subscribed?(email:, segment_ids: [@list_id])
    rescue Flodesk::FlodeskError
      false
    end

    private

    def client
      @client ||= Flodesk::Client.new
    end
  end
end
