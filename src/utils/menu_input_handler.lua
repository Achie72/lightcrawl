local const = require "src.utils.const"
-- player.lua
local menu_handler = {}

function menu_handler.new()
    local self = {
      id = "a"
    }

    function self:keyreleased(key)
      if STATE == const.STATE_MENU then
        STATE = const.STATE_GAME
      end
      print("pressed")
    end

    function self:keypressed(key)
      if key == "left" then
        master_volume = master_volume - 0.1
      elseif key == "right" then
        master_volume = master_volume + 0.1
      end
    end

    return self
end

return menu_handler