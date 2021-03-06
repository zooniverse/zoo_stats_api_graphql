FROM ruby:2.6-slim

WORKDIR /rails_app

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        build-essential \
        libpq-dev \
        && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ARG REVISION=''
ENV REVISION=$REVISION

ADD ./Gemfile /rails_app/
ADD ./Gemfile.lock /rails_app/

RUN bundle config --global jobs `cat /proc/cpuinfo | grep processor | wc -l | xargs -I % expr % - 1`
RUN bundle install --without development test

ADD ./ /rails_app/

EXPOSE 80

CMD ["/rails_app/scripts/docker/start.sh"]
