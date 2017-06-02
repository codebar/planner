require 'spec_helper'

feature 'Coaches By Chapter' do
  let!(:student) { Fabricate(:student) }
  let!(:coach) { Fabricate(:coach) }
  let(:chapters) { Chapter.all }
  let(:chapter) { coach.chapters.first }
  let(:chapter_without_coach) { Chapter.where.not(id: coach.chapters.select(:id)).first }

  scenario "Visitor can see list of each chapter and see coaches in that chapter" do
    visit coaches_path

    # Shows all the chapters
    within ".chapters-list" do
      chapters.each do |chapter|
        expect(page).to have_content chapter.name
      end

      click_on chapter.name
    end

    expect(current_path).to eq(coach_path(chapter_slug: chapter.slug))

    # Shows the coach within the chapter
    within ".coach-list" do
      expect(page).to have_content coach.name
    end

    # Does not show students in the coaches list
    visit coach_path(chapter_slug: student.chapters.first.slug)
    within ".coach-list" do
      expect(page).to_not have_content student.name
    end

    # Does not show coaches from other chapters in the list
    visit coach_path(chapter_slug: chapter_without_coach.slug)
    within ".coach-list" do
      expect(page).to_not have_content coach.name
    end
  end
end
