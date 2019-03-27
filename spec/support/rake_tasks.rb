require 'rake'

module TaskExampleGroup
  extend ActiveSupport::Concern

  included do
    let(:task_name) { self.class.top_level_description.sub(/\Arake /, '') }
    let(:tasks) { Rake::Task }

    subject(:task) { tasks[task_name] }
  end
end

RSpec.configure do |config|
  config.define_derived_metadata(file_path: %r{/spec/tasks/}) do |metadata|
    metadata[:type] = :task
  end

  config.include TaskExampleGroup, type: :task

  config.before(:suite) do
    Rails.application.load_tasks
  end
end
