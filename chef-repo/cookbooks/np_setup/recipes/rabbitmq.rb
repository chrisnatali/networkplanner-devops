# Cookbook Name:: np_setup
# Recipe:: rabbitmq
#
# Copyright 2012, 
#
# All rights reserved - Do Not Redistribute

# Setup the server components

package "rabbitmq-server"

service "rabbitmq-server" do
    supports :status => true, :restart => true, :reload => true
    action [:enable, :start]
end
