# frozen_string_literal: true

class ChapterPickerComponent < ViewComponent::Base
  def initialize(name:, chapters:, selected: nil, placeholder: 'Select a chapter')
    super()
    @name = name
    @chapters = chapters
    @selected = selected
    @placeholder = placeholder
  end

  def datalist_id
    "#{@name.parameterize}-options"
  end
end
