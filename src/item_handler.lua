local Item = {}
local item_image_handler = require "src.utils.item_image_handler"
local const = require "src.utils.const"
local color = require "src.utils.color"
local helpers = require "src.utils.helpers"

local item_image_table = {
    item_image_handler.WHETSTONE_IMAGE,
    item_image_handler.FORGE_HAMMER,
    item_image_handler.POTION_IMAGE,
    item_image_handler.SHIELD_IMAGE
}

local stat_keys = {
    "damage","durability","health","shield"
}


function Item.new(id, is_top_or_bottom)
    local self = {
        id = id,
        x = 70,
        y = is_top_or_bottom and const.TOP_LANE_Y_LEVEL or const.BOTTOM_LANE_Y_LEVEL,
        sprite = item_image_table[id],
        encounter_type = const.ENCOUNTER_ITEM,
        stats = {
            damage = 0,
            durability = 0,
            health = 0,
            shield = 0,
        }
    }
    self.stats[stat_keys[id]] = math.random(4)
    
    function self:update(dt)
        self.x = self.x - 0.6
    end

    function self:apply(obj)
        for key,val in pairs(self.stats) do
            if helpers.is_value_in_set(key, {"health","shield", "damage", "durability"}) then
                obj[key] = obj[key] + val
            end
        end
    end

    function self:draw()
        local x_pos, y_pos = math.floor(self.x), math.floor(self.y)
        love.graphics.draw(self.sprite, x_pos, y_pos)
        color.set(color.PICO_LIGHT_GREY)
        local stat_that_matters = 0
        --huh, don forget ipairs for numeric index, pairs for associative

        for _,v in pairs(self.stats) do
            if v > 0 then
                stat_that_matters = v
                break
            end
        end


        love.graphics.print(stat_that_matters, _G.font, x_pos, y_pos-6)
        color.reset()
    end

    return self
end

return Item