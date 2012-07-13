#!/bin/bash
# Setup Chef and get the networkplanner-devops repo to bootstrap 
# Network Planner installation

sudo apt-get update

sudo apt-get -y install ruby1.9.1 ruby1.9.1-dev
sudo gem install chef --no-rdoc --no-ri

sudo apt-get -y install git-core

if [ ! -d networkplanner-devops ]; then
    git clone git://github.com/chrisnatali/networkplanner-devops.git
fi

cd networkplanner-devops

sudo chef-solo -c solo.rb -j single-server.json
