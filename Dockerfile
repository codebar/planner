FROM ruby:3.2.2

# Default node version on apt is old. This makes sure a recent version is installed
# This step also runs apt-get update
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get update
RUN apt-get install -y --force-yes build-essential libpq-dev nodejs chromium chromium-driver

WORKDIR /planner

COPY . ./

RUN bundle install --jobs 4
