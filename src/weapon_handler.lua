-- player.lua
local Weapon = {}
local const = require("src.utils.const")
local helpers = require("src.utils.helpers")
local input_handler = require("src.utils.input_handler")
local color = require "src.utils.color"
local WEAPON_IMAGES = require "src.utils.item_image_handler"

local weapon_image_table = {
    WEAPON_IMAGES.SWORD_IMAGE,
    WEAPON_IMAGES.SPEAR_IMAGE,
    WEAPON_IMAGES.HAMMER_IMAGE
}


function Weapon.new(id, is_top_or_bottom)
    local self = {
        id = id,
        x = 70,
        y = is_top_or_bottom and const.TOP_LANE_Y_LEVEL or const.BOTTOM_LANE_Y_LEVEL,
        sprite = weapon_image_table[id],
        damage = helpers.random_element_from({1,2,3}) + _G.item_diff_val,
        durability = helpers.random_element_from({1,2,3}),
        encounter_type = const.ENCOUNTER_WEAPON
    }
    
    function self:update(dt)
        self.x = self.x - 0.6
    end

    function self:draw()
        local x_pos, y_pos = math.floor(self.x), math.floor(self.y)
        love.graphics.draw(self.sprite, x_pos, y_pos)
        color.set(color.PICO_LIGHT_GREY)
        love.graphics.print(self.damage.."/"..self.durability, _G.font, x_pos, y_pos-6)
        color.reset()
    end

    return self
end

return Weapon