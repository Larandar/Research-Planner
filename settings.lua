data:extend({
    {
        type = "string-setting",
        name = "research-planner-enable-queue",
        setting_type = "runtime-global",
        default_value = "keep-map-settings",
        allowed_values = {"keep-map-settings", "disable", "enable"}
    }, {
        type = "string-setting",
        name = "research-planner-sharing",
        setting_type = "runtime-global",
        default_value = "secret-to-enemies",
        allowed_values = {"no", "friends", "always", "secret-to-enemies"}
    }
})
