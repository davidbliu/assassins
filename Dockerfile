FROM ubuntu:14.04
MAINTAINER David Liu <davidbliu@gmail.com>
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y ruby ruby-dev libpq-dev build-essential
RUN gem install sinatra bundler --no-ri --no-rdoc

#
# install sshd
#
RUN apt-get install -y sudo ntp openssh-server supervisor
RUN mkdir -p /var/run/sshd
RUN adduser --gecos "" container
RUN echo 'container:container' | sudo -S chpasswd
RUN echo 'container ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN sed -i -e 's/^\(session\s\+required\s\+pam_loginuid.so$\)/#\1/' /etc/pam.d/sshd


ADD . /opt/assassins

WORKDIR /opt/assassins
RUN bundle install

EXPOSE 3000
CMD bundle exec rails s
