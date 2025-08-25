local projectile_handler = {}
local const = require "src.utils.const"
local UI_IMAGES = require "src.utils.ui_image_handler"
local helpers = require "src.utils.helpers"
local color = require "src.utils.color"

projectile_handler.spr = love.graphics.newImage("assets/sprites/enemies/arrow.png")
-- pairs of modifier that might be positive and negative
-- player choice to pick them up
function projectile_handler.new(x, y, target, image)
    local self = {
        x = x,
        y = y,
        ax = 0,
        ay = 0,
        encounter_type = const.PROJECTILE,
        damage = 1 + math.floor(_G.item_diff_val/2),
        target = target,
        sprite = image,
    }
   
    function self:update(dt)
        self.x = self.x - 1.5
    end

    function self:draw()
        local x_pos, y_pos = math.floor(self.x), math.floor(self.y)
        helpers.draw_outline(self.sprite, x_pos, y_pos)
    end

    return self
end

return projectile_handler