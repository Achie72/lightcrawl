local const = require "src.utils.const"
-- player.lua
local gameover_handler = {}

function gameover_handler.new()
    local self = {
      id = "a"
    }

    function self:keyreleased(key)
      if STATE == const.STATE_GAME_OVER then
        STATE = const.STATE_MENU
      end
      print("pressed")
    end

    return self
end

return gameover_handler