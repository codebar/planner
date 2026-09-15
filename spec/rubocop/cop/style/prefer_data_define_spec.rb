# frozen_string_literal: true

require 'rails_helper'
require 'rubocop'
require 'rubocop/rspec/expect_offense'
require 'rubocop/rspec/support'
require_relative '../../../../lib/rubocop/cop/style/prefer_data_define'

RSpec.describe RuboCop::Cop::Style::PreferDataDefine, :config, :ruby40 do
  include RuboCop::RSpec::ExpectOffense

  it 'registers an offense for Struct.new' do
    expect_offense(<<~RUBY)
      Struct.new(:id, :email)
      ^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Data.define` over `Struct.new` for immutable value objects.
    RUBY
  end

  it 'registers an offense for ::Struct.new' do
    expect_offense(<<~RUBY)
      ::Struct.new(:id, :email)
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Data.define` over `Struct.new` for immutable value objects.
    RUBY
  end

  it 'does not register an offense for Data.define' do
    expect_no_offenses(<<~RUBY)
      Data.define(:id, :email)
    RUBY
  end

  it 'does not register an offense for namespaced receivers' do
    expect_no_offenses(<<~RUBY)
      Other::Struct.new(:id, :email)
    RUBY
  end

  it 'does not register an offense for other Struct methods' do
    expect_no_offenses(<<~RUBY)
      Struct.members
    RUBY
  end

  it 'does not register an offense for OtherClass.new' do
    expect_no_offenses(<<~RUBY)
      Member.new(:id, :email)
    RUBY
  end
end
