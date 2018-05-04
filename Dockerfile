FROM ruby:2.4.2

# Default node version on apt is old. This makes sure a recent version is installed
# This step also runs apt-get update
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y build-essential libpq-dev nodejs

# Install PhantomJS for tests - see https://blog.codeship.com/testing-rails-application-docker/
ENV PHANTOMJS_VERSION 2.1.1
RUN set -ex; \
    mkdir -p /usr/local/share/phantomjs; \
    curl -fsSL https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-${PHANTOMJS_VERSION}-linux-x86_64.tar.bz2 \
      | tar xj -C /usr/local/share/phantomjs --strip-components=1; \
    ln -s /usr/local/share/phantomjs/bin/phantomjs /usr/local/bin/phantomjs

WORKDIR /planner

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . ./
