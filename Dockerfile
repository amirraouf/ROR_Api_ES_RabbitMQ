FROM ruby:latest
MAINTAINER Amir Raouf <amir2raouf@gmail.com>
RUN apt-get update; apt-get upgrade --yes; apt-get install --yes libpq-dev \
        nodejs build-essential net-tools
ENV APP_PATH /inst_challenge
RUN mkdir -p $APP_PATH
WORKDIR $APP_PATH
COPY Gemfile Gemfile.lock ./
COPY entrypoint.sh /entrypoint.sh
RUN bundle install \
    && bundle update \
    && groupadd -r rails \
    && useradd -r -g rails rails
RUN chmod +x /entrypoint.sh \
    && chown rails /entrypoint.sh
COPY . .
ENTRYPOINT ["/entrypoint.sh"]
CMD rm tmp/pids/server.pid; bundle exec rails server -p 3000 -b 0.0.0.0
