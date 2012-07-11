name "np_base"
description "Baseline configuration for Network Planner"

run_list(
    "recipe[np_setup]",
    "recipe[np_setup::user_dir]",
    "recipe[sudo]"
)

# np sudo config
default_attributes(
    "authorization" => {
        "sudo" => {
            "users" => ["np"],
            "groups" => ["admin"],
            "passwordless" => true
        }
    }
)
