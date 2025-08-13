local input_helper = {}
local helpers = require("src.utils.helpers")

function input_helper.is_left_input(key)
    return helpers.is_value_in_set(key, {"a","left","dpleft"})
end

function input_helper.is_right_input(key)
    return helpers.is_value_in_set(key, {"d","right","dpright"})
end

function input_helper.is_up_input(key)
    return helpers.is_value_in_set(key, {"w","up","dpright"})
end

function input_helper.is_down_input(key)
    return helpers.is_value_in_set(key, {"s","down","dpright"})
end

return input_helper