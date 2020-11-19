if Gem.loaded_specs.key?('rubocop')
  require 'rubocop/rake_task'

  desc 'Run the rubocop static code analyzer'
  task rubocop: :environment do
    unless system 'rubocop'
      exit 1
    end
  end
end
