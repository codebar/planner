require 'spec_helper'

describe Group, type: :model do
  subject(:group) { Fabricate.build(:group) }

  context 'validations' do
    it { should validate_presence_of(:name) }

    it do
      should validate_inclusion_of(:name).
        in_array(%w[Coaches Students]).
        with_message('Invalid name for Group')
    end
  end
end
