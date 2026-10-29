# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'StrongMigrations configuration' do # rubocop:disable RSpec/DescribeClass
  describe 'destructive-operation messages' do
    preboot_keys = %i[change_column change_column_with_not_null change_column_default
                      change_column_null rename_column rename_table rename_schema
                      rename_enum_value execute]

    it 'appends the Heroku preboot note after the gem default' do
      message = StrongMigrations.error_messages[:rename_column]

      expect(message).to start_with("Renaming a column that's in use will cause errors")
      expect(message).to end_with("disable preboot for this deploy.\n")
    end

    it 'carries the note exactly once, after the gem text, on each destructive-operation message' do
      preboot_keys.each do |key|
        message = StrongMigrations.error_messages.fetch(key)

        expect(message.scan('disable preboot for this deploy').size).to eq(1)
        expect(message).not_to start_with('Heroku preboot')
      end
    end

    it 'leaves messages for other checks unchanged' do
      untouched_keys = StrongMigrations.error_messages.keys.map(&:to_sym) - preboot_keys

      expect(untouched_keys).not_to be_empty
      untouched_keys.each do |key|
        expect(StrongMigrations.error_messages.fetch(key)).not_to include('Heroku preboot')
      end
    end

    it 'fails loudly when a future gem version drops a listed key' do
      allow(StrongMigrations).to receive(:error_messages)
        .and_return(StrongMigrations.error_messages.except(:rename_column))

      expect { load Rails.root.join('config/initializers/strong_migrations.rb').to_s }
        .to raise_error(KeyError, /rename_column/)
    end
  end
end
