RSpec.describe ChapterCreationService do
  let(:valid_params) do
    {
      name: 'codebar Brighton',
      email: 'brighton@codebar.io',
      city: 'Brighton',
      time_zone: 'London'
    }
  end

  describe '.call' do
    it 'creates chapter with Students and Coaches groups' do
      result = described_class.call(valid_params)

      expect(result.success).to be true
      expect(result.chapter.persisted?).to be true
      expect(result.chapter.groups.pluck(:name)).to match_array(%w[Students Coaches])
    end

    it 'fails when chapter params are invalid' do
      invalid_params = valid_params.merge(name: '')
      result = described_class.call(invalid_params)

      expect(result.success).to be false
      expect(result.errors).to be_present
      expect(Chapter.where(name: '')).not_to exist
    end

    it 'rolls back chapter if groups fail' do
      # 'bogus' is not in Group::NAMES, so the group fails its real
      # inclusion validation and save! raises RecordInvalid inside the
      # service's transaction.
      invalid_group = Group.new(name: 'bogus')
      allow(Group).to receive(:new).and_return(invalid_group)

      result = described_class.call(valid_params)

      expect(result.success).to be false
      expect(result.errors).to be_present
      expect(Chapter.where(name: valid_params[:name])).not_to exist
    end
  end
end
