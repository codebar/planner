require 'rails_helper'

# Canary for the 'with forgery protection enforced' shared context. All
# no-CSRF regression specs depend on its before hook actually enabling
# protection; if that hook stops applying, they pass vacuously. This
# example fails loudly if the toggle breaks.
# rubocop:disable RSpec/DescribeClass -- the subject is a shared context, not a class
RSpec.describe 'with forgery protection enforced' do
  include_context 'with forgery protection enforced'

  it 'enables forgery protection for examples that include it' do
    expect(ActionController::Base.allow_forgery_protection).to be true
  end
end
# rubocop:enable RSpec/DescribeClass
