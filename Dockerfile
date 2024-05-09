# Take image from dockerhub with ruby 3.3
FROM ruby:3.3

# Run update and install build-essential, apt-utils, libpq-dev and nodejs
RUN apt-get update -qq && apt-get install -y build-essential apt-utils libpq-dev nodejs

# Create a directory /myapp
WORKDIR /myapp

# Copy the Gemfile and Gemfile.lock from the current directory into the /myapp directory
RUN gem install bundler
COPY Gemfile* ./

# Install the gems
RUN bundle install

# Copy the current directory contents into the container at /myapp
ADD . /myapp

# Set the environment variable RAILS_ENV to development
ARG DEFAULT_PORT 3000
EXPOSE ${DEFAULT_PORT}

# Start the main process: the rails server
# -b 0.0.0.0 because we want to access the server from outside the container
# rm -f tmp/pids/server.pid to remove the server.pid file: this is necessary because the server.pid file is created when the server starts and it is not removed when the server stops
CMD rm -f tmp/pids/server.pid && rails s -b '0.0.0.0'


# How to run
# sudo docker image build --tag eventmanager:2024 .
# sudo docker container run -p 3000:3000 eventmanager:2024

# To run the container opening a shell
# sudo docker container run -it eventmanager:2024 bash

# To run the docker compose
# docker-compose up --build
# docker-compose down

