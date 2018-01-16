namespace :skills do
  desc 'Create initial list of commonly used skills'

  task seed_tag_table: :environment do
    list = %w(html css javascript jQuery rails ruby php python c++ wordpress)

    list.each do |tag|
      ActsAsTaggableOn::Tag.new(name: tag).save
    end
  end
end
