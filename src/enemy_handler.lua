-- player.lua
local Enemy = {}
local const = require("src.utils.const")
local helpers = require("src.utils.helpers")
local input_handler = require("src.utils.input_handler")
local color = require "src.utils.color"
local UI_IMAGES = require "src.utils.ui_image_handler"


local enemy_data_table = {
    -- first is damage
    {2, 2, 3, 4},
    -- second is damage weakness
    {const.SPEAR_TYPE , 2, 3, 0},
    -- third is skills
    {const.ENEMY_SKILL_BERSERK,const.ENEMY_SKILL_RANGED,const.ENEMY_SKILL_BERSERK,const.ENEMY_SKILL_RUSTING }
}

local weakness_table = {
  UI_IMAGES.WEAKNESS_SWORD,
  UI_IMAGES.WEAKNESS_SPEAR,
  UI_IMAGES.WEAKNESS_HAMMER
}

local skill_table = {
  {},
  UI_IMAGES.SKILL_RANGED,
  UI_IMAGES.SKILL_BERSERK,
  UI_IMAGES.SKILL_RUSTING
}

function Enemy.new(id, is_top_or_bottom)
    local self = {
      id = id,
      x = 70,
      y = is_top_or_bottom and const.TOP_LANE_Y_LEVEL or const.BOTTOM_LANE_Y_LEVEL,
      sprite = id == 1 and love.graphics.newImage("assets/sprites/enemies/skeleton_archer.png") or love.graphics.newImage("assets/sprites/enemies/cyclops.png"),
      is_top_lane = is_top_or_bottom,
      health = enemy_data_table[1][id],
      weakness = enemy_data_table[2][id],
      skill = enemy_data_table[3][id],
      encounter_type = const.ENCOUNTER_ENEMY
    }
    
    function self:update(dt)
      self.x = self.x - 0.6
    end

    function self:draw()
       -- draw
      color.set(color.PICO_DARK_RED)
      local x_pos,y_pos = math.floor(self.x), math.floor(self.y)
      -- draw health (which is damage basically)
      love.graphics.print(self.health, _G.font, x_pos-3, y_pos-4)
      color.reset()
      love.graphics.draw(self.sprite, x_pos, y_pos)
      -- draw weakness if exists
      if self.weakness ~= 0 then
        love.graphics.draw(weakness_table[self.weakness], x_pos+8, y_pos+6)  
      end
      -- draw skill if exists
      if self.skill ~= 1 then
        love.graphics.draw(skill_table[self.skill], x_pos+8, y_pos-4)  
      end

      --love.graphics.rectangle("line", self.x, self.y, 8, 8)
 
    end

    return self
end

return Enemy