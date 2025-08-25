local game_background_image_handler = {}

game_background_image_handler.ONE = love.graphics.newImage("assets/sprites/ui/map_bg1.png")
game_background_image_handler.TWO = love.graphics.newImage("assets/sprites/ui/map_bg2.png")
game_background_image_handler.THREE = love.graphics.newImage("assets/sprites/ui/map_bg3.png")


game_background_image_handler.images = {
    game_background_image_handler.ONE,
    game_background_image_handler.TWO,
    game_background_image_handler.THREE
}

return game_background_image_handler