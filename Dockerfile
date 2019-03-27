FROM ruby:2.4.2

# Default node version on apt is old. This makes sure a recent version is installed
# This step also runs apt-get update
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y build-essential libpq-dev nodejs

# Install latest chrome dev package
RUN set -ex; \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-unstable --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /planner

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . ./
