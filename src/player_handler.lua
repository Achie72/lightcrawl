-- player.lua
local Player = {}
local const = require("src.utils.const")
local helpers = require("src.utils.helpers")
local input_handler = require("src.utils.input_handler")

function Player.new(id, x, y)
    local self = {
      id = id,
      x = x,
      y = const.TOP_LANE_Y_LEVEL,
      sprite = love.graphics.newImage("assets/sprites/player/player.png"),
      is_top_or_bottom = true,
      max_health = 10,
      health = 10,
      shield = 0,
      weapon = const.SWORD_TYPE,
      damage = 2,
      durability = 3,
      secondary_weapon =  const.SPEAR_TYPE,
      secondary_damage = 5,
      secondary_durability = 1
    }

    function self:keyreleased(key)
      if button_hold_frames >= button_hold_frames_treshold then
        -- switch weapos cuz we held the button
        local third_weapon = self.weapon
        local third_damage = self.damage
        local third_durability = self.durability
        -- second to first
        self.weapon = self.secondary_weapon
        self.durability = self.secondary_durability
        self.damage = self.secondary_damage
        -- temp to second
        self.secondary_weapon = third_weapon
        self.secondary_durability = third_damage
        self.secondary_damage = third_damage
      else
        self.is_top_or_bottom = not self.is_top_or_bottom

        self.y = self.is_top_or_bottom and const.TOP_LANE_Y_LEVEL or const.BOTTOM_LANE_Y_LEVEL
      end
    end
    
    function self:update(dt)
      -- if we don't have a main weapon, but do have a second one
      -- place secondary in main
      if self.weapon == const.NONE_TYPE and self.secondary_weapon ~= const.NONE_TYPE then
        self.weapon = self.secondary_weapon
        self.durability = self.secondary_durability
        self.damage = self.secondary_damage
        self.secondary_weapon = const.NONE_TYPE
      end
      self.health = math.min(self.health, self.max_health)



    end

    function self:draw()
       -- draw
      love.graphics.draw(self.sprite, self.x, self.y)
    end

    return self
end

return Player