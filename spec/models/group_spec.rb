require 'spec_helper'

describe Group, type: :model do
  subject(:group) { Fabricate.build(:group) }

  it { should belong_to(:chapter) }
  it { should have_many(:subscriptions) }
  it { should have_many(:members) }
  it { should have_many(:group_announcements) }
  it { should have_many(:announcements) }

  it { should respond_to(:name) }
  it { should respond_to(:description) }

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_inclusion_of(:name).in_array(Group::NAMES) }
  end
end
