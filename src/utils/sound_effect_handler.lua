local helpers = require "src.utils.helpers"
local sound_effect_handler = {}

sound_effect_handler.hit = {
    love.audio.newSource("assets/sfx/hit.wav", "static"),
    love.audio.newSource("assets/sfx/hit2.wav", "static"),
    love.audio.newSource("assets/sfx/hit3.wav", "static")
}

sound_effect_handler.pickup = {
    love.audio.newSource("assets/sfx/pickup.wav", "static"),
    love.audio.newSource("assets/sfx/pickup2.wav", "static"),
    love.audio.newSource("assets/sfx/pickup3.wav", "static"),
}

sound_effect_handler.press = {
    love.audio.newSource("assets/sfx/press.wav", "static"),
}

sound_effect_handler.dead = {
    love.audio.newSource("assets/sfx/dead.wav", "static"),
}

sound_effect_handler.block = {
    love.audio.newSource("assets/sfx/block.wav", "static"),
}

sound_effect_handler.proj = {
    love.audio.newSource("assets/sfx/proj.wav", "static"),
}

sound_effect_handler.kill = {
    love.audio.newSource("assets/sfx/kill.wav", "static"),
}

function sound_effect_handler.play(category)
    local sound_effect = helpers.random_element_from(sound_effect_handler[category])
    sound_effect:setVolume(music_volume_ui.master_volume*0.8)
    sound_effect:play()
end

return sound_effect_handler