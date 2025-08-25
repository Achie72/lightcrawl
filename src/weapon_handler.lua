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

local weapon_random_values = {
    {{2,4},{2,4}},
    {{1,3},{3,5}},
    {{3,5},{1,3}}
}


function Weapon.new(id, is_top_or_bottom)
    local self = {
        id = id,
        x = 72,
        y = is_top_or_bottom and const.TOP_LANE_Y_LEVEL or const.BOTTOM_LANE_Y_LEVEL,
        sprite = weapon_image_table[id],
        damage = math.random(weapon_random_values[id][1][1],weapon_random_values[id][1][2]) + _G.item_diff_val,
        durability = math.random(weapon_random_values[id][2][1],weapon_random_values[id][2][2]),
        encounter_type = const.ENCOUNTER_WEAPON
    }
    
    function self:update(dt)
        self.x = self.x - const.MOVEMENT_SPEED
    end

    function self:draw()
        local x_pos, y_pos = math.floor(self.x), math.floor(self.y)
        helpers.draw_outline(self.sprite, x_pos, y_pos)
        color.set(color.PICO_LIGHT_GREY)
        helpers.print_outline(self.damage.."/"..self.durability, x_pos, y_pos-6, 6, 1, 0)
        color.reset()
    end

    return self
end

return Weapon