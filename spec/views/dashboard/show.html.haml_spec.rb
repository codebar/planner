require 'rails_helper'

RSpec.describe 'dashboard/show.html.haml', type: :view do
  let(:chapters) { Fabricate.times(2, :chapter) }
  let(:upcoming_workshops) { {} }
  let(:testimonials) { [] }

  before do
    assign(:chapters, chapters)
    assign(:upcoming_workshops, upcoming_workshops)
    assign(:has_more_events, false)
    assign(:testimonials, testimonials)
    render
  end

  it 'renders the chapters sidebar component' do
    expect(rendered).to have_selector('.col-lg-4.pl-lg-5')
    chapters.each do |chapter|
      expect(rendered).to have_link(chapter.name, href: chapter_path(chapter.slug))
    end
  end
end
