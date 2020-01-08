class Ticket
  def initialize(request, params)
    authorise(request)
    @params = params
  end

  def email
    @email ||= params[:email]
  end

  private

  attr_reader :params

  def authorise(request)
    # TODO
    # verify referer
  end
end
