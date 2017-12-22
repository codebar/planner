require 'spec_helper'

describe Tutorial do
  subject(:tutorial) { Fabricate.build(:tutorial) }

  it { should respond_to(:title) }
  it { should respond_to(:description) }
  it { should respond_to(:url) }
  it { should respond_to(:workshop) }

  context 'validations' do
    it '#title' do
      tutorial = Fabricate.build(:tutorial, title: nil)

      expect(tutorial).to_not be_valid
      expect(tutorial).to have(1).error_on(:title)
    end
  end

  it 'gets all titles' do
    tutorial_1 = Tutorial.create(title: 'title1')
    tutorial_2 = Tutorial.create(title: 'title2')

    expect(Tutorial.all_titles).to match_array(['title1', 'title2'])
  end
end
