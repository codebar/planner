require 'redcarpet'

Rails.configuration.redcarpet = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new)
