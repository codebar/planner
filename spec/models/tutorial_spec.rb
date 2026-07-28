RSpec.describe Tutorial do
  subject(:tutorial) { Fabricate.build(:tutorial) }

  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:url) }
  it { is_expected.to respond_to(:workshop) }

  context 'validations' do
    it '#title' do
      tutorial = Fabricate.build(:tutorial, title: nil)

      expect(tutorial).to_not be_valid
      expect(tutorial).to have(1).error_on(:title)
    end
  end

  it 'gets all titles' do
    tutorial_1 = described_class.create(title: 'title1')
    tutorial_2 = described_class.create(title: 'title2')

    expect(described_class.all_titles).to match_array(%w[title1 title2])
  end
end
