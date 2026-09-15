# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Prefer Data.define over Struct.new for immutable value objects.
      #
      # Data defines immutable value objects with keyword-aware equality;
      # Struct instances are mutable, so the rewrite is not safely mechanical.
      class PreferDataDefine < Base
        MSG = 'Prefer `Data.define` over `Struct.new` for immutable value objects.'

        def on_send(node)
          return unless node.receiver&.const_type? && node.receiver.const_name == 'Struct'
          return unless node.method?(:new)

          add_offense(node)
        end
      end
    end
  end
end
