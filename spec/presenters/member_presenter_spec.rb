require 'rails_helper'

RSpec.describe MemberPresenter do
  let(:member) { Fabricate(:member, skill_list: 'java, ruby') }
  let(:member_presenter) { described_class.new(member) }

  it '#subscribed_to_newsletter?' do
    allow(member).to receive(:opt_in_newsletter_at)

    member_presenter.subscribed_to_newsletter?

    expect(member).to have_received(:opt_in_newsletter_at)
  end

  describe '#pairing_details_array' do
    it 'returns student pairing information' do
      expect(member_presenter.pairing_details_array('Student', 'Tutorial', 'Note'))
        .to eq([member_presenter.newbie?, member.full_name, 'Student', 'Tutorial', 'Note', 'N/A'])
    end

    it 'returns coach pairing information' do
      expect(member_presenter.pairing_details_array('Coach', nil, 'A note'))
        .to eq([member_presenter.newbie?, member.full_name, 'Coach', 'N/A', 'A note', 'java, ruby'])
    end
  end
end
