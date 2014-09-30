FROM ubuntu:14.04
MAINTAINER David Liu <davidbliu@gmail.com>
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y ruby ruby-dev libpq-dev build-essential
RUN gem install sinatra bundler --no-ri --no-rdoc


#
# add files
#
ADD . /opt/assassins
WORKDIR /opt/assassins
RUN bundle install

EXPOSE 3000
CMD bundle exec rails s
