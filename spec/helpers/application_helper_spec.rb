require 'spec_helper'

describe ApplicationHelper do

  context "#present" do
    let(:chapter) { Chapter.new }
    let(:sessions) { Sessions.new }

    it "presents a chapter with no class argument" do
      present(chapter) do |c|
        expect(c).to be_a(ChapterPresenter)
      end
    end

    it "presents a workshop with explicit class" do
      present(sessions, WorkshopPresenter) do |s|
        expect(s).to be_a(WorkshopPresenter)
      end
    end
  end

end
