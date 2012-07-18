#!/bin/bash
# Setup Chef and get the networkplanner-devops repo to bootstrap 
# Network Planner installation

sudo apt-get update
sudo apt-get -y install build-essential
sudo apt-get -y install ruby1.9.1 ruby1.9.1-dev
sudo gem install chef --no-rdoc --no-ri
sudo apt-get -y install git-core

