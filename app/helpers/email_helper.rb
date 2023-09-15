module EmailHelper
  private

  def email_full_url_for(path)
    "#{@host}#{path}"
  end
end
