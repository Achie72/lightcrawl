local game_background_handler = {}
local game_background_image_handler = require "src.utils.game_background_image_handler"
local const = require "src.utils.const"

-- pairs of modifier that might be positive and negative
-- player choice to pick them up
function game_background_handler.new(id, front_or_back)
    local self = {
      id = id,
      x = front_or_back and 0 or 64,
      y = 0,
      sprite = game_background_image_handler.images[id]
    }

    function self:update(dt)
        self.x = self.x - const.MOVEMENT_SPEED
    end

    function self:draw()
        local x_pos, y_pos = math.floor(self.x), math.floor(self.y)
        
        love.graphics.draw(self.sprite, x_pos, y_pos)
    end

    return self
end

return game_background_handler