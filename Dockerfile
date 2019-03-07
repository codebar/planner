FROM ruby:2.4.2

# Default node version on apt is old. This makes sure a recent version is installed
# This step also runs apt-get update
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y build-essential libpq-dev nodejs

WORKDIR /planner

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . ./
