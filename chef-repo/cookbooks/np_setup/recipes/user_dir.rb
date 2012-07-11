#
# Cookbook Name:: np_setup
# Recipe:: user_dir
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
# Create the NP user and dir for running NP

user "np" do
    comment "Network Planner User"
    home "/home/np"
    shell "/bin/bash"
    password "$1$cFxWg9A6$NLFmZO8loMDIacwWZT6aT/"
    supports :manage_home => true
    action :create
end

# authorized keys
directory "/home/np/.ssh" do
    owner "np"
    group "np"
    mode "0700"
    action :create
end

cookbook_file "/home/np/.ssh/authorized_keys" do
    source "authorized_keys"
    owner "np"
    group "np"
    mode "0700"
    action :create
end

# Setup dir for running np from
directory "/var/www/np" do
    owner "np"
    group "np"
    recursive true
    action :create
end
