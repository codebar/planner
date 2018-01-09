require 'spec_helper'

describe MeetingTalk do
  context 'validations' do
    subject { MeetingTalk.new }

    it '#title' do
      expect(subject).to have(1).error_on(:title)
    end

    it '#abstract' do
      expect(subject).to have(1).error_on(:abstract)
    end

    it '#speaker' do
      expect(subject).to have(1).error_on(:speaker)
    end

    it '#meeting' do
      expect(subject).to have(1).error_on(:meeting)
    end
  end
end
