require 'rails_helper'
require 'view_component/test_helpers'

RSpec.describe ChapterPickerComponent do
  include ViewComponent::TestHelpers

  let(:chapters) { Fabricate.times(3, :chapter) }

  it 'renders a text input with datalist attributes' do
    render_inline described_class.new(name: 'sponsors_search[chapter]', chapters: chapters, placeholder: 'Filter by chapter')

    expect(page).to have_field('sponsors_search[chapter]')
    input = page.find('input')
    expect(input['placeholder']).to eq('Filter by chapter')
    expect(input['autocomplete']).to eq('off')
    expect(input['class']).to include('form-control')
  end

  it 'renders a datalist with chapter names' do
    render_inline described_class.new(name: 'sponsors_search[chapter]', chapters: chapters)

    expect(page).to have_css('datalist#sponsors_search-chapter-options')
    chapters.each do |chapter|
      expect(page).to have_css("option[value='#{chapter.name}']")
    end
  end

  it 'sanitises bracket characters in the datalist id' do
    render_inline described_class.new(name: 'workshop[chapter_id]', chapters: chapters)

    expect(page).to have_css('datalist#workshop-chapter_id-options')
  end

  it 'pre-fills the input when selected value is provided' do
    render_inline described_class.new(name: 'sponsors_search[chapter]', chapters: chapters, selected: 'London')

    input = page.find('input')
    expect(input['value']).to eq('London')
  end
end
