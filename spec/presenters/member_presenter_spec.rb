require 'spec_helper'

RSpec.describe MemberPresenter do
  let(:member) { Fabricate(:member) }
  let(:member_presenter) { MemberPresenter.new(member) }

  it '#organiser?' do
    expect(member).to receive(:has_role?).with(:organiser, :any)

    member_presenter.organiser?
  end

  it '#subscribed_to_newsletter?' do
    expect(member).to receive(:opt_in_newsletter_at)

    member_presenter.subscribed_to_newsletter?
  end
end
