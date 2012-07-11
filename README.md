Overview
========

Repository for automated deployment/configuration of computing nodes associated with networkplanner.

To deploy to a network planner node use:

* fab provision:host_string=<host>,system_type=<system>,branch=<np_branch>
* fab deploy:host_string=<host>,system_type=<system>,branch=<np_branch>

Where <system> is one of:
* `single-server` - Single User Mode
* `cluster-server` - Server that "manages" clusters
* `cluster-processor` - A computing node


Main Components
======================

* `fabfile.py` - fabfile which orchestrates deployment
* `chef-repo` - the chef configuration for setting up nodes
* `<server-type>.json` - files defining chef components of each server type

Caveat Emptor
==========

THIS IS INCOMPLETE!!!

fab provision task has not been defined

No systems other than single-server have been tested

Testing has only been done on vagrant vm's (not amazon or other linux instances)
