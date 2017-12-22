require 'spec_helper'

describe MemberPresenter do
  let(:member) { Fabricate(:member) }
  let(:member_presenter) { MemberPresenter.new(member) }

  it '#organiser?' do
    expect(member).to receive(:has_role?).with(:organiser, :any)

    member_presenter.organiser?
  end
end
