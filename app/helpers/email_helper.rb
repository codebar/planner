module EmailHelper
  private

  def full_url_for(path)
    "#{@host}#{path}"
  end
end
