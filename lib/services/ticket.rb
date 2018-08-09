class Ticket
  attr_reader :params

  def initialize(request, params)
    authorise(request)
    @params = params
  end

  def email
    @email ||= params[:email]
  end

  private

  def authorise(request)
    # TODO
    # verify referer
  end
end
