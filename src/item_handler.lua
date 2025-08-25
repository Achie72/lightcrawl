local Item = {}
local item_image_handler = require "src.utils.item_image_handler"
local const = require "src.utils.const"
local color = require "src.utils.color"
local helpers = require "src.utils.helpers"
local UI_IMAGES = require "src.utils.ui_image_handler"

local item_image_table = {
    item_image_handler.WHETSTONE_IMAGE,
    item_image_handler.FORGE_HAMMER,
    item_image_handler.POTION_IMAGE,
    item_image_handler.SHIELD_IMAGE,
    UI_IMAGES.MAX_HEALTH_UP,
}

local stat_keys = {
    "damage","durability","health","shield","max_health"
}


function Item.new(id, is_top_or_bottom)
    local self = {
        id = id,
        x = 72,
        y = is_top_or_bottom and const.TOP_LANE_Y_LEVEL or const.BOTTOM_LANE_Y_LEVEL,
        sprite = item_image_table[id],
        encounter_type = const.ENCOUNTER_ITEM,
        stats = {
            damage = 0,
            durability = 0,
            health = 0,
            shield = 0,
            max_health = 0
        },
        stat = nil,
        cost = math.random(10) + _G.diff_val
    }
    self.stats[stat_keys[id]] = helpers.random_weighted_element_from({1,2,3,4,5,10},{10,30,40,40,20,1})
    self.stat = stat_keys[id]
    -- nerf durability heavily
    if self.stat == 'durability' then
        self.stats[stat_keys[id]] = helpers.random_weighted_element_from({1,2,3,4,5},{1,4,4,2,1})
    end
    
    function self:update(dt)
        self.x = self.x - const.MOVEMENT_SPEED
    end

    function self:apply(obj)
        local text = {
            max_health = "max hp up",
            health = "hp recovered",
            damage = "damage up",
            durability = "durability up"
        }
        for key,val in pairs(self.stats) do
            if helpers.is_value_in_set(key, {"health","shield", "damage", "durability", "max_health"}) then
                obj[key] = obj[key] + val
                if val > 0 then
                    set_tooltip({text[key]}, 80)
                end
            end
        end
    end

    function self:draw()

        local x_pos, y_pos = math.floor(self.x), math.floor(self.y)
        helpers.draw_outline(self.sprite, x_pos, y_pos)
        
        local stat_that_matters = 0
        --huh, don forget ipairs for numeric index, pairs for associative

        for _,v in pairs(self.stats) do
            if v > 0 then
                stat_that_matters = v
                break
            end
        end

        helpers.draw_icon_with_text(UI_IMAGES.COIN, 7, tostring(self.cost).."->"..tostring(stat_that_matters), x_pos-4, y_pos-6, color.PICO_ORANGE)
    end

    return self
end

return Item