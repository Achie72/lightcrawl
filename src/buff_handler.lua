local Choice = {}
local const = require "src.utils.const"
local UI_IMAGES = require "src.utils.ui_image_handler"
local helpers = require "src.utils.helpers"
local color = require "src.utils.color"


local stat_keys_image_pairs = {
    damage = UI_IMAGES.WEAPON_SWORD,
    durability = UI_IMAGES.DURABILITY,
    health = UI_IMAGES.HEART_ICON,
    shield = UI_IMAGES.SHIELD_ICON,
    max_health = UI_IMAGES.MAX_HEALTH_UP
}

local stat_keys = {
    "damage","durability","health","shield", "max_health"
}



-- pairs of modifier that might be positive and negative
-- player choice to pick them up
function Choice.new(is_top_or_bottom)
    local self = {
        x = 70,
        y = is_top_or_bottom and const.TOP_LANE_Y_LEVEL or const.BOTTOM_LANE_Y_LEVEL,
        encounter_type = const.ENCOUNTER_ITEM,
        stats = {}
    }
    -- fetch two randomly and assign values
    -- check for stats on player, so we can filter values that don't exist
    local stat_option_to_fetch_from = {}
    for _,v in pairs(stat_keys) do
        if player[v] > 0 or v == "shield" then
            table.insert(stat_option_to_fetch_from, v)
        end
    end

    local random_key = helpers.random_element_from(stat_option_to_fetch_from)
    local random_key2 = helpers.random_element_from(stat_option_to_fetch_from)
    -- I need to guard against infinite loop when only one item is inside options
    if #stat_option_to_fetch_from > 1 then
        -- if we have more than 1, try fetch another
        while random_key2 == random_key do
            random_key2 = helpers.random_element_from(stat_option_to_fetch_from)
        end
    end

    -- assign random value
    self.stats[random_key] = math.random(3) * helpers.random_element_from({1,1,1,1,1,1,1,-1,-1,-1})
    self.stats[random_key2] = math.random(3) * helpers.random_element_from({1,1,1,1,1,1,1,-1,-1,-1})

    if self.stats[random_key2] < 0 and self.stats[random_key] < 0 then
        -- if both is negative, flip one of them
        local flipper = helpers.random_element_from({random_key, random_key2})
        self.stats[flipper] = self.stats[flipper] * -1
    end


    function self:update(dt)
        self.x = self.x - 0.6
    end

    function self:apply(obj)
        for key,val in pairs(self.stats) do
            if helpers.is_value_in_set(key, {"max_health","health","shield", "damage", "durability"}) then
                obj[key] = obj[key] + val
            end
        end
    end

    function self:draw()
        local x_pos, y_pos = math.floor(self.x), math.floor(self.y)

        local lineoffset = 0
        for _,v in pairs(self.stats) do
            helpers.draw_icon_with_text(stat_keys_image_pairs[_], 8, tostring(v), x_pos, y_pos+lineoffset-3, color.PICO_LIGHT_GREY)
            lineoffset = 5
        end
    end

    return self
end

return Choice