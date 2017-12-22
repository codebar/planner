module MeetingsHelper
  def all_speakers(meeting)
    meeting.meeting_talks.map { |talk| talk.speaker.full_name }.to_sentence
  end
end
