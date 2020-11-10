module Haml::Filters
  remove_filter("Markdown") #remove the existing Markdown filter

  module Markdown
    include Haml::Filters::Base

    def render(text)
      CommonMarker.render_html(text, :DEFAULT).html_safe
    end
  end
end
