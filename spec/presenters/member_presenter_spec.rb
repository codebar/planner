require 'spec_helper'

RSpec.describe MemberPresenter do
  let(:member) { Fabricate(:member, skill_list: 'java, ruby') }
  let(:member_presenter) { MemberPresenter.new(member) }

  it '#organiser?' do
    expect(member).to receive(:has_role?).with(:organiser, :any)

    member_presenter.organiser?
  end

  it '#subscribed_to_newsletter?' do
    expect(member).to receive(:opt_in_newsletter_at)

    member_presenter.subscribed_to_newsletter?
  end

  context '#pairing_details_array' do
    it 'returns student pairing information' do
      expect(member_presenter.pairing_details_array('Student', 'Study note'))
        .to eq([member_presenter.newbie?, member.full_name, 'Student', 'Study note', 'N/A'])
    end

    it 'returns coach pairing information' do
      expect(member_presenter.pairing_details_array('Coach', nil))
        .to eq([member_presenter.newbie?, member.full_name, 'Coach', 'N/A', 'java, ruby'])
    end
  end
end
