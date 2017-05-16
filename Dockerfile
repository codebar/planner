FROM ruby:2.3.3
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /planner
WORKDIR /planner
ADD Gemfile /planner/Gemfile
ADD Gemfile.lock /planner/Gemfile.lock
RUN bundle install
ADD . /planner
