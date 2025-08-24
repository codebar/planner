# frozen_string_literal: true

module FalseResponder
  def method_missing(method_name, *args, &block)
    false
  end

  def respond_to_missing?(method_name, include_private = false)
    true
  end
end
