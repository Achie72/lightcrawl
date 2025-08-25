local const = require "src.utils.const"
local helpers = require "src.utils.helpers"
-- player.lua
local menu_handler = {}

function menu_handler.new()
    local self = {
      id = "a"
    }

    function self:keyreleased(key)
      if key == "x" then
        if STATE == const.STATE_MENU then
          STATE = const.STATE_GAME
          reset_game()
        end
      end

    end

    function self:keypressed(key)
      if helpers.is_value_in_set(key, {"left","dpleft"}) then
        music_volume_ui.pressed_ticks = 60
        music_volume_ui.master_volume = music_volume_ui.master_volume - 0.1
        
      elseif helpers.is_value_in_set(key, {"right","dpright"}) then
        music_volume_ui.pressed_ticks = 60
        music_volume_ui.master_volume = music_volume_ui.master_volume + 0.1
      end
    end

    return self
end

return menu_handler