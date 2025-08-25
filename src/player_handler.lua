-- player.lua
local Player = {}
local const = require("src.utils.const")
local helpers = require("src.utils.helpers")
local input_handler = require("src.utils.input_handler")
local sound_effect_handler = require "src.utils.sound_effect_handler"
local particle_handler = require "src.particle_handler"
local color = require "src.utils.color"

function Player.new(id, x, y)
  local self = {
    id = id,
    x = x,
    y = const.TOP_LANE_Y_LEVEL,
    sprite = love.graphics.newImage("assets/sprites/player/player.png"),
    sprite2 = love.graphics.newImage("assets/sprites/player/player2.png"),
    shielded = love.graphics.newImage("assets/sprites/player/shield1.png"),
    unarmed = love.graphics.newImage("assets/sprites/player/unarmed1.png"),
    unarmed2 = love.graphics.newImage("assets/sprites/player/unarmed2.png"),
    is_top_or_bottom = true,
    max_health = 10,
    health = 10,
    shield = 0,
    weapon = const.NONE_TYPE,
    damage = 0,
    durability = 0,
    secondary_weapon = const.NONE_TYPE,
    secondary_damage = 0,
    secondary_durability = 0,
    distance = 0,
    defeated = 0,
    defeated_by = 0,
    gold = 0,
    draw_x = 0,
    draw_y = 0
  }

  function self:keyreleased(key)
    if key == 'x' then
      if button_hold_frames >= button_hold_frames_treshold and player.secondary_weapon ~= const.NONE_TYPE then
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

    -- cursor.drawx,cursor.ax = smooth_move(cursor.goalx,cursor.drawx,cursor.ax, 0.05, 0.8, 0.02)
    self.draw_x, self.ax = helpers.smooth_move(self.x, self.draw_x, self.ax, 0.1, 0.4, 0.02)
    self.draw_y, self.ay = helpers.smooth_move(self.y, self.draw_y, self.ay, 0.1, 0.4, 0.02)
  end

  function self:draw()
    -- draw
    local x_pos, y_pos = self.draw_x, self.draw_y
    local sprite_to_draw = self.sprite
    if self.weapon ~= const.NONE_TYPE then
      sprite_to_draw = ticks % 30 > 15 and self.sprite or self.sprite2
    else
      sprite_to_draw = ticks % 30 > 15 and self.unarmed or self.unarmed2
    end
    
    love.graphics.draw(sprite_to_draw, x_pos, y_pos)
    if self.shield > 0 then
      love.graphics.draw(self.shielded, x_pos, y_pos)
    end
  end

  function self:take_damage(damage)
      if self.shield > 0 then
      -- reduce damage by shield
      local remainder = damage - self.shield
      -- remove shield
      self.shield = math.max(0, self.shield - damage)
      -- after our remining damage is either positive, because shield did not get
      -- rid of all, or it is negative, meaning shield is higher, hence we no longer
      -- take damage (right???)
      damage = math.max(0, remainder)
    end
    if damage > 0 then
      sound_effect_handler.play("hit")
      player.health = player.health - damage
      for i=1,10 do
        local part = particle_handler.new_particle(self.x+4, self.y+4, math.random(), math.random()*helpers.random_element_from({-1,1}), math.random(7)+7,color.PICO_LIGHT_GREY, particle_handler.PARTICLE_TYPE.CIRCLE, helpers.random_element_from({0.5,1,1,1,1.5,2}))
        table.insert(particle_collection, part) 
      end
    else
      local part = particle_handler.new_particle(self.x+4, self.y+4, math.random(), math.random()*helpers.random_element_from({-1,1}), math.random(7)+7,color.PICO_LIGHT_GREY, particle_handler.PARTICLE_TYPE.CIRCLE, helpers.random_element_from({0.5,1,1,1,1.5,2}))
			table.insert(particle_collection, part)    
      sound_effect_handler.play("block")
    end
  end

  return self
end

return Player
