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

    it 'carries the note exactly once on each destructive-operation message' do
      counts = preboot_keys.index_with do |key|
        StrongMigrations.error_messages.fetch(key).scan('disable preboot for this deploy').size
      end

      expect(counts.values).to all(eq(1))
    end

    it 'leaves messages for other checks unchanged' do
      expect(StrongMigrations.error_messages[:add_index]).not_to include('Heroku preboot')
    end
  end
end
