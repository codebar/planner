FROM ruby:2.4.10

# Install Node and other build dependencies
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y build-essential libpq-dev nodejs

# Install latest Chrome browser (for automated testing)
RUN curl -L https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \ 
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get -y install google-chrome-stable

WORKDIR /planner

# Install project dependencies using all available CPU cores
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs $(getconf _NPROCESSORS_ONLN) --retry 3

COPY . ./
