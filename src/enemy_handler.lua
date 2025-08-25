-- player.lua
local Enemy = {}
local const = require("src.utils.const")
local helpers = require("src.utils.helpers")
local input_handler = require("src.utils.input_handler")
local color = require "src.utils.color"
local UI_IMAGES = require "src.utils.ui_image_handler"
local enemy_image_handler = require "src.utils.enemy_image_handler"
local projectile_handler = require "src.projectile_handler"
local sound_effect_handler = require "src.utils.sound_effect_handler"


local enemy_data_table = {
    -- first is damage
    {2, 3, 4, 1, 4},
    -- second is damage weakness
    {const.HAMMER_TYPE , const.SPEAR_TYPE, const.HAMMER_TYPE, const.SWORD_TYPE, 0},
    -- third is skills
    {const.ENEMY_SKILL_RANGED,const.ENEMY_SKILL_BERSERK,const.ENEMY_SKILL_RUSTING, 1, 1},
    -- minimum damage modifier
    {0, 1, 1, 0, 3}
}

local weakness_table = {
  UI_IMAGES.WEAKNESS_SWORD,
  UI_IMAGES.WEAKNESS_SPEAR,
  UI_IMAGES.WEAKNESS_HAMMER,
  UI_IMAGES.WEAKNESS_SWORD,
  nil,
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
      x = 72,
      y = is_top_or_bottom and const.TOP_LANE_Y_LEVEL or const.BOTTOM_LANE_Y_LEVEL,
      sprite = enemy_image_handler.images[id][1],
      sprite2 = enemy_image_handler.images[id][2],
      is_top_lane = is_top_or_bottom,
      health = enemy_data_table[1][id] + _G.diff_val + enemy_data_table[4][id],
      weakness = enemy_data_table[2][id],
      skill = enemy_data_table[3][id],
      encounter_type = const.ENCOUNTER_ENEMY,
      shot = false,
    }
    
    function self:update(dt)
      self.x = self.x - const.MOVEMENT_SPEED
      if self.id == 1 and (not self.shot) and self.x <= 56 and self.y == player.y then
        local projectile = projectile_handler.new(self.x, self.y, player, projectile_handler.spr)
        table.insert(projectile_collection, projectile)
        self.shot = true
        sound_effect_handler.play("hit")
      end
    end

    function self:draw()
       -- draw
      color.set(color.PICO_DARK_RED)
      local x_pos,y_pos = math.floor(self.x), math.floor(self.y)
      -- draw health (which is damage basically)
      helpers.print_outline(self.health, x_pos-3, y_pos-5, 2)
      color.reset()
      local sprite_to_draw = ticks % 30 > 15 and self.sprite or self.sprite2
      helpers.draw_outline(sprite_to_draw, x_pos, y_pos)
      -- draw weakness if exists
      if self.weakness ~= 0 then
        helpers.draw_outline(weakness_table[self.weakness], x_pos+8, y_pos+6)  
      end
      -- draw skill if exists
      if self.skill ~= 1 then
        helpers.draw_outline(skill_table[self.skill], x_pos+8, y_pos-4)  
      end

      --love.graphics.rectangle("line", self.x, self.y, 8, 8)
 
    end

    return self
end

return Enemy