# Cookbook Name:: np_setup
# Recipe:: server 
#
# Copyright 2012, 
#
# All rights reserved - Do Not Redistribute

# Setup the server components

package "nginx"
package "postgresql"

service "nginx" do
    supports :status => true, :restart => true, :reload => true
    action [:enable, :start]
end

# determine which postgresql service was installed
$postgres_service = "postgresql"
ruby_block "find-postgres-service" do
    block do
       files = Dir.glob("/etc/init.d/postgresql*")
       if files.length != 1
           Chef::Log.fatal("postgresql not installed properly")
       end
       $postgres_service = files[0]
       $postgres_service["/etc/init.d/"] = ""
    end
    action :create
end

# start postgres via bash 
bash "start-postgresql" do
    code <<-EOH
    POSTGRES_SERVICE=`ls /etc/init.d | sed 's/\/etc\/init.d\///' | grep postgresql`
    if /etc/init.d/$POSTGRES_SERVICE status | grep -v '^Running' > /dev/null
    then
        /etc/init.d/$POSTGRES_SERVICE start
    fi
    EOH
end

# enable postgres via bash 
bash "enable-postgresql" do
    not_if(%q{ls /etc/rc*.d | grep postgresql})
    code <<-EOH
    POSTGRES_SERVICE=`ls /etc/init.d | sed 's/\/etc\/init.d\///' | grep postgresql`
    update-rc.d $POSTGRES_SERVICE defaults
    EOH
end


#configure the database
#NOTE:  We're leaving the default security configuration 
bash "setup-np-postgresql" do
    not_if(%q{psql -At -c '\l' | grep '^np|np'}, :user => 'postgres')
    user "postgres"
    code <<-EOH
    createdb np
    createuser np --no-createrole --no-superuser --no-createdb
    psql -c "grant all on database np to np;"
    psql -c "alter role np password 'AyfNFioDbFJDNyjaQK3xHDtUZIcHdU0b';"
    EOH
end

# restart postgres via bash (only needed if we update config file)
bash "restart-postgresql" do
    code <<-EOH
    POSTGRES_SERVICE=`ls /etc/init.d | sed 's/\/etc\/init.d\///' | grep postgresql`
    if /etc/init.d/$POSTGRES_SERVICE status | grep -v '^Running' > /dev/null
    then
        /etc/init.d/$POSTGRES_SERVICE restart
    fi
    EOH
end

#setup nginx config
cookbook_file "/etc/nginx/sites-available/networkplanner.conf" do
    source "networkplanner.conf"
    mode 0644
    owner "root"
    group "root"
end

link "/etc/nginx/sites-enabled/networkplanner.conf" do
    to "/etc/nginx/sites-available/networkplanner.conf"
end

link "/etc/nginx/sites-enabled/default" do
    action :delete
end

service "nginx" do
    action :restart
end
