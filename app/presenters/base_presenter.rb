class BasePresenter < SimpleDelegator
  private

  def model
    __getobj__
  end
end
