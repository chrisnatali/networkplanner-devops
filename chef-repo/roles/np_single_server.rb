name "np_single_server"
description "Standalone Server Deployment for Network Planner"
run_list "role[np_base]", "recipe[np_setup::server]"
