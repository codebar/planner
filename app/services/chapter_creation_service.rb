class ChapterCreationService
  Result = Data.define(:chapter, :success, :errors)

  def self.call(params)
    chapter = Chapter.new(params)

    ActiveRecord::Base.transaction do
      chapter.save!
      chapter.groups.create!(name: 'Students')
      chapter.groups.create!(name: 'Coaches')
    end

    Result.new(chapter: chapter, success: true, errors: nil)
  rescue ActiveRecord::RecordInvalid => e
    Result.new(chapter: chapter, success: false, errors: e.message)
  end
end
