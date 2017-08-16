FROM ruby:2.4.1
MAINTAINER simao <simao.belchior@vizzuality.com>

ENV NAME emission-scenario-portal

# Install dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client \
    && rm -rf /var/lib/apt/lists/* \
    && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
    && apt-get install -y nodejs

RUN apt-get install -y  build-essential patch zlib1g-dev liblzma-dev
RUN apt-get install -y libicu-dev
RUN gem install bundler --no-ri --no-rdoc
# Create app directory
RUN mkdir -p /usr/src/$NAME
WORKDIR /usr/src/$NAME

# Install app dependencies
COPY Gemfile Gemfile.lock ./

RUN bundle install --without development test --jobs 4 --deployment

# Set Rails to run in production
ENV RAILS_ENV production
ENV RACK_ENV production

# Bundle app source
COPY . ./

EXPOSE 3000

# Start puma
CMD bundle exec rake assets:precompile && bundle exec rake tmp:clear db:migrate && bundle exec puma -C config/puma.rb