require 'spec_helper'

RSpec.describe Member, type: :model do
  let(:member) { Fabricate(:member) }

  describe 'mandatory attributes' do
    describe 'validations' do
      it { is_expected.to validate_presence_of(:auth_services) }
      it { is_expected.to validate_length_of(:about_you).is_at_most(255) }
      it { is_expected.to validate_uniqueness_of(:email) }

      describe 'can_log_in' do
        let(:member) { Fabricate.build(:member, can_log_in: true) }

        it { expect(member).to validate_presence_of(:name) }
        it { expect(member).to validate_presence_of(:surname) }
        it { expect(member).to validate_presence_of(:email) }
        it { expect(member).to validate_presence_of(:about_you) }
      end
    end

    describe 'properties' do
      it '#full_name' do
        expect(member.full_name).to eq("#{member.name} #{member.surname} (#{member.pronouns})")
      end

      it '#avatar' do
        encrypted_email = Digest::MD5.hexdigest(member.email.strip.downcase)
        expect(member.avatar).to eq("https://secure.gravatar.com/avatar/#{encrypted_email}?size=100&default=identicon")
      end
    end
  end

  describe '.with_skill' do
    it 'returns members with the specified skill' do
      member_with_specified_skills = Fabricate(:coach, skill_list: 'ruby, rails')
      Fabricate(:coach, skill_list: 'html, jQuery')

      expect(described_class.with_skill('ruby')).to eq([member_with_specified_skills])
    end
  end

  describe 'scopes' do
    describe '#attending_meeting' do
      it 'includes attending members' do
        invitation = Fabricate(:attending_meeting_invitation)

        expect(described_class.attending_meeting(invitation.meeting)).to include(invitation.member)
      end

      it 'excludes banned attending members' do
        invitation = Fabricate(:banned_attending_meeting_invitation)

        expect(described_class.attending_meeting(invitation.meeting)).not_to include(invitation.member)
      end
    end

    describe '#in_group' do
      it 'includes members in group' do
        chapter = Fabricate(:chapter)
        group = Fabricate(:group, chapter: chapter, members: [Fabricate(:member)])

        expect(described_class.in_group(chapter.groups)).to eq(group.members)
      end

      it 'excludes members outside group' do
        chapter = Fabricate(:chapter)
        other_chapter = Fabricate(:chapter)
        group = Fabricate(:group, chapter: other_chapter, members: [Fabricate(:member)])

        expect(described_class.in_group(chapter.groups)).not_to eq(group.members)
      end

      it 'excludes banned members in group' do
        chapter = Fabricate(:chapter)
        group = Fabricate(:group, chapter: chapter, members: [Fabricate(:banned_member)])

        expect(described_class.in_group(chapter.groups)).not_to eq(group.members)
      end
    end
  end

  describe '.multiple_no_shows?' do
    it 'returns true when a member has missed more than three workshop in the last six months' do
      Fabricate.times(6, :past_attending_workshop_invitation, member: member)

      expect(member.multiple_no_shows?).to be true
    end

    it 'returns false when a member has not missed more than three workshop in the last six months' do
      Fabricate.times(3, :past_attending_workshop_invitation, attended: true, member: member)

      expect(member.multiple_no_shows?).to be false
    end
  end

  describe '.flag_to_organisers' do
    it 'returns false when a member does not have multiple_no_shows?' do
      Fabricate.times(2, :attendance_warning, member: member)

      expect(member.flag_to_organisers?).to be false
    end

    it 'returns false when a member does not have at least two two attendance warnings' do
      Fabricate.times(6, :past_attending_workshop_invitation, member: member)
      Fabricate(:attendance_warning, member: member)

      expect(member.flag_to_organisers?).to be false
    end

    it 'returns true when a member has multiple_no_shows? and has received at least two attendance warning emails' do
      Fabricate.times(6, :past_attending_workshop_invitation, member: member)
      Fabricate.times(2, :attendance_warning, member: member)

      expect(member.flag_to_organisers?).to be true
    end
  end
end
