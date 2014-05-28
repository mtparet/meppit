#!/usr/bin/env bash

if [ ! -f ~/runonce ]
then
  # Update
  apt-get update
  apt-get upgrade -y

  # Install dependencies
  apt-get install -y git ruby2.0 ruby2.0-dev redis-server postgresql-9.1 postgresql-contrib-9.1 postgresql-server-dev-9.1 libpq-dev nodejs libxslt1.1 imagemagick build-essential libtool checkinstall libjson0-dev libxml2-dev libproj-dev python2.7-dev swig libgeos-3.3.3 libgeos-dev gdal-bin libgdal1-1.9.0-grass libgdal1-dev openjdk-7-jre

  # ========================
  # compile postgis
  cd /home/vagrant/
  wget http://download.osgeo.org/postgis/source/postgis-2.0.3.tar.gz
  tar xzf postgis-2.0.3.tar.gz
  cd postgis-2.0.3
  ./configure
  make
  make install


  # ============================
  # Ruby dependencies
  gem install bundler

  # Create postgres user
  sudo -u postgres createuser -r -s -d vagrant
  sudo -u postgres createdb vagrant -O vagrant

  # Configure Meppit
  cd /home/vagrant/
  sudo -u vagrant ln -s /vagrant /home/vagrant/meppit

  cd meppit
  if [ ! -f config/secrets.yml ]
  then
    sudo -u vagrant cp config/secrets.yml.sample config/secrets.yml
  fi

  if [ ! -f config/database.yml ]
  then
    sudo -u vagrant cp config/database.yml.sample config/database.yml
    sudo -u vagrant sed -i -e 's/username: postgres/username: vagrant/g' config/database.yml
  fi

  # Install elasticsearch
  wget -P vendor/ https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.2.0.tar.gz
  tar xzvf vendor/elasticsearch-1.2.0.tar.gz -C vendor/
  mv vendor/elasticsearch-1.2.0 vendor/elasticsearch
  rm vendor/elasticsearch-1.2.0.tar.gz
  chmod +x vendor/elasticsearch/bin/elasticsearch

  # Setup
  sudo -u vagrant bundle
  sudo -u vagrant bundle exec rake db:create db:migrate
  sudo -u vagrant bundle exec rake db:create db:migrate RAILS_ENV=test
  sudo -u vagrant bundle exec rspec

  touch ~/runonce
fi
