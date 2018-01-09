class Ticket
  def initialize(request, params)
    authorise(request)
    @params = params
  end

  def email
    @email ||= params[:email]
  end

  private

  def params
    @params
  end

  def authorise(request)
    # TODO
    # verify referer
  end
end
