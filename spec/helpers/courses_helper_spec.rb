require 'spec_helper'

describe CoursesHelper do
  it '#twitter_url_for' do
    expect(twitter_url_for('Picard')).to eq('http://twitter.com/Picard')
  end
end
