class ChapterCreationService
  Result = Struct.new(:chapter, :success, :errors, keyword_init: true)

  def self.call(params)
    chapter = Chapter.new(params)

    ActiveRecord::Base.transaction do
      chapter.save!
      chapter.groups.create!(name: 'Students')
      chapter.groups.create!(name: 'Coaches')
    end

    Result.new(chapter: chapter, success: true)
  rescue ActiveRecord::RecordInvalid => e
    Result.new(chapter: chapter, success: false, errors: e.message)
  end
end
