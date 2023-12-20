FROM ruby:3.2.2

# Default node version on apt is old. This makes sure a recent version is installed
# Instructions for installing node from nodesource can be found here:
# https://github.com/nodesource/distributions
RUN set -ex; \
    apt-get update \
    && apt-get install -y ca-certificates curl gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update 
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
RUN bundle install --jobs 4

COPY . ./
