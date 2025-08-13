# Remove the haml_markdown initaliser. The internals changed so the monkey-patching to implement a custom render method
# no longer works, but is also not necessary since the markdown filter uses Commonmarker anyway.

# module Haml::Filters
#   remove_filter("Markdown") #remove the existing Markdown filter

#   module Markdown
#     include Haml::Filters::Base

#     def render(text)
#       Commonmarker.to_html(text).html_safe
#     end
#   end
# end
