# frozen_string_literal: true

# Pagy options
Pagy.options[:size] = [1, 3, 3, 1]
Pagy.options[:overflow] = :empty_page

# Freeze options so they don't get changed accidentally
Pagy.options.freeze
