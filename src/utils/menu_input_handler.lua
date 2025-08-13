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

    return self
end

return menu_handler