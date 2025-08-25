local helpers = require "src.utils.helpers"

local floating_text_handler = {}

function floating_text_handler.new(x, y, text, image, color, lifetime)
    local self = {
      x = x,
      y = y,
      sprite = image,
      text = text,
      color  = color,
      lifetime = lifetime
    }

    function self:update()
        self.y = self.y + 0.2
    end

    function self:draw()
        if self.sprite ~= nil then
            helpers.draw_icon_with_text(self.sprite, 8, self.text, self.x, self.y, self.color)
        else
            helpers.print_outline(self.text, self.x, self.y, self.color)
        end
    end
    
    return self
end

return floating_text_handler