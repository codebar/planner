FROM ruby:2.3.3
# Default node version on apt is old. This makes sure a recent version is installed
# This step also runs apt-get update
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y build-essential libpq-dev nodejs
# Install PhantomJS for tests - see https://blog.codeship.com/testing-rails-application-docker/
ENV PHANTOMJS_VERSION=2.1.1
RUN \
  cd /usr/local/share && \
  wget -nv https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-${PHANTOMJS_VERSION}-linux-x86_64.tar.bz2 && \
  tar xvf phantomjs-${PHANTOMJS_VERSION}-linux-x86_64.tar.bz2 && \
  rm phantomjs-${PHANTOMJS_VERSION}-linux-x86_64.tar.bz2 && \
  ln -s /usr/local/share/phantomjs-${PHANTOMJS_VERSION}-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs
RUN mkdir /planner
WORKDIR /planner
ADD Gemfile /planner/Gemfile
ADD Gemfile.lock /planner/Gemfile.lock
RUN bundle install
ADD . /planner
