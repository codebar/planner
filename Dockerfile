FROM ruby:2.7.2

# Default node version on apt is old. This makes sure a recent version is installed
# This step also runs apt-get update
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y --force-yes build-essential libpq-dev nodejs

# Install latest chrome dev package
RUN set -ex; \
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && wget -q -O - https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y --force-yes google-chrome-stable --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /planner

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . ./
