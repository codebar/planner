require 'rails_helper'

RSpec.describe WorkshopOrganiserAssigner, type: :service do
  let(:workshop) { Fabricate(:workshop) }
  let(:chapter) { workshop.chapter }

  describe '#call' do
    context 'when organiser_ids are provided' do
      let(:organiser) { Fabricate(:member) }

      it 'grants organiser role to members in the list' do
        expect do
          described_class.new(workshop, [organiser.id.to_s], default_to_chapter: false).call
          workshop.reload
        end.to change { workshop.organisers.include?(organiser) }.from(false).to(true)
      end

      it 'revokes organiser role from members not in the list' do
        existing_organiser = Fabricate(:member)
        existing_organiser.add_role(:organiser, workshop)
        workshop.reload
        described_class.new(workshop, [organiser.id.to_s], default_to_chapter: false).call
        workshop.reload
        expect(workshop.organisers).not_to include(existing_organiser)
      end
    end

    context 'when organiser_ids are blank with default_to_chapter' do
      it 'defaults to the chapter organisers' do
        chapter_organiser = Fabricate(:member)
        chapter_organiser.add_role(:organiser, chapter)
        described_class.new(workshop, [], default_to_chapter: true).call
        workshop.reload
        expect(workshop.organisers).to include(chapter_organiser)
      end
    end

    context 'when organiser_ids contain only blank values (update path)' do
      it 'revokes all and does not fall back to chapter' do
        chapter_organiser = Fabricate(:member)
        chapter_organiser.add_role(:organiser, chapter)
        existing_organiser = Fabricate(:member)
        existing_organiser.add_role(:organiser, workshop)
        described_class.new(workshop, [''], default_to_chapter: false).call
        workshop.reload
        expect(workshop.organisers).not_to include(existing_organiser)
        expect(workshop.organisers).to eq([])
      end
    end
  end
end
