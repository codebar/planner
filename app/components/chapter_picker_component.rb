# frozen_string_literal: true

class ChapterPickerComponent < ViewComponent::Base
  def initialize(name:, chapters:, selected: nil, placeholder: 'Select a chapter', required: false)
    super()
    @name = name
    @chapters = chapters
    @selected = selected
    @placeholder = placeholder
    @required = required
  end

  def datalist_id
    "#{@name.parameterize}-options"
  end
end
