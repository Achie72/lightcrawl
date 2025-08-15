local gameover_input_handler = require "src.utils.gameover_input_handler"

io.stdout:setvbuf('no')

local color = require "src.utils.color"
local const = require "src.utils.const"
local player_hander = require "src.player_handler"
local enemy_handler = require "src.enemy_handler"
local weapon_handler = require "src.weapon_handler"
local particle_handler = require "src.particle_handler"
local item_handler = require "src.item_handler"
local buff_handler = require "src.buff_handler"
local menu_input_handler = require "src.utils.menu_input_handler"
local helpers = require "src.utils.helpers"

function love.load()
	math.randomseed( os.time() )
	love.graphics.setDefaultFilter('nearest','nearest', 1)
	_G.font = love.graphics.newFont("assets/font/3x4dot.ttf", 4)
	_G.font:setFilter("linear", "nearest")
	UI_IMAGES = require "src.utils.ui_image_handler"
	local joysticks = love.joystick.getJoysticks()
    joystick = joysticks[1]
	love.keyboard.setKeyRepeat(true)
	tickPeriod = 1/60
	accumulator = 0.0
	canvasWidth = 64
	canvasHeight = 64
	_G.diff_val = 0
	gameCanvas = nil
	love.window.setMode (640, 640, {resizable=true, borderless=false})
	love.window.setTitle = "LOWREZJAM"
	gameCanvas = love.graphics.newCanvas(canvasWidth, canvasHeight, {format = "srgba8"})
	player = player_hander.new(1, 10, 10)
	particle_collection = {}
	keypress_listener_collection = {}
	table.insert(keypress_listener_collection,player)
	entity_collection = {}
	table.insert(entity_collection, enemy_handler.new(1, true))
	ticks = 0
	button_hold_frames = 0
	button_hold_frames_treshold = 20
	STATE = const.STATE_MENU
	STATE_MACHINE_FUNCTIONS = {
		menu = {update = update_menu, draw = draw_menu},
		game = {update = update_game, draw = draw_game},
		gameover = {update = update_gameover, draw = draw_gameover}
	}
	menu_player_object = {
		x = 0,
		y = const.MENU_LANE_TOP
	}
	menu_input_handler_obj = menu_input_handler.new()
	gameover_input_handler = gameover_input_handler.new()
	input_id = nil
	table.insert(keypress_listener_collection, menu_input_handler_obj)
	table.insert(keypress_listener_collection, gameover_input_handler)

	music = love.audio.newSource("assets/sfx/lightcrawl_3.wav", "stream")
	master_volume = 0
	music:play()

	dummy_image = love.graphics.newImage("assets/sprites/enemies/skeleton_archer.png")
	game_spawn_count = 0
end

function update_entities()
	for i=#entity_collection, 1, -1 do
		local e = entity_collection[i]
		e:update()
		if e.x < -10 then
			table.remove(entity_collection, i)
		end
	end
end

function draw_enemies()
	for _,e in ipairs(entity_collection) do
		e:draw()
	end
end


function reset_game()
	player.max_health = 10
	player.health = 10
	player.shield = 0
	player.weapon = const.NONE_TYPE
	player.secondary_weapon = const.NONE_TYPE
	player.defeated = 0
	player.distance = 0
	player.gold = 0
	game_spawn_count = 0
	_G.diff_val = 0
	_G.item_diff_val = 0
end
function spawn_enemy(pos)
	table.insert(entity_collection, enemy_handler.new(helpers.random_element_from({1,2}),pos == const.TOP_LANE_Y_LEVEL))
end

function spawn_weapon(pos)
	table.insert(entity_collection, weapon_handler.new(helpers.random_element_from({1,2,3}),pos == const.TOP_LANE_Y_LEVEL))
end

function spawn_shopitem(pos)
	table.insert(entity_collection, item_handler.new(helpers.random_element_from({1,2,3}),pos == const.TOP_LANE_Y_LEVEL))
end

function spawn_choice(pos)
	table.insert(entity_collection, buff_handler.new(pos == const.TOP_LANE_Y_LEVEL))
end

function love.update(dt)
	music:setVolume(master_volume)
	accumulator = accumulator+dt
	if accumulator >= tickPeriod then	
		ticks = ticks+1
		if ticks == 60 then
			ticks = 0
			player.distance =  player.distance + 1
		end
		STATE_MACHINE_FUNCTIONS[STATE].update()
		accumulator = accumulator - tickPeriod
	end
end

function update_menu()
	if love.keyboard.isDown('c') then
		STATE = const.STATE_GAME
		reset_game()
	end

	if #particle_collection < 5 then
		local part = particle_handler.new_particle(
			math.random(64), 
			math.random(64), 
			math.random()/4 * helpers.random_element_from({-1,1}),
			math.random()/4 * helpers.random_element_from({-1,1}),
			120,
			color.PICO_DARK_BLUE,
			particle_handler.PARTICLE_TYPE.SPARK
		)
		table.insert(particle_collection, part)
	end

	for i=#particle_collection, 1, -1 do
		local particle = particle_collection[i]
		particle:update()
		if particle.lifetime <= 0 then
			table.remove(particle_collection, i)
		end
	end

	menu_player_object.x = menu_player_object.x + 1
	if menu_player_object.x > 65 then
		menu_player_object.y = math.random() < 0.49 and const.MENU_LANE_TOP or const.MENU_LANE_BOTTOM
		menu_player_object.x = 0
	end
end

function update_game()
-- chek button held frames

	_G.diff_val = math.floor(player.distance/10)
	_G.item_diff_val = math.floor(_G.diff_val * 0.6)
	if love.keyboard.isDown() then
		button_hold_frames = button_hold_frames + 1
	end

	player:update(dt)
	update_entities()

	-- handle collisions
	local spawn_locations = {const.BOTTOM_LANE_Y_LEVEL, const.TOP_LANE_Y_LEVEL}
	local first_spawn = helpers.random_element_from(spawn_locations)
	helpers.remove_element_from_table(spawn_locations, first_spawn)
	if ticks == 0 then
		local spawn_function_table = {spawn_enemy, spawn_weapon, spawn_choice, spawn_shopitem}
		if game_spawn_count % 10 == 0 then
			spawn_function_table = {spawn_shopitem, spawn_shopitem}
		end
		local spawn_function = helpers.random_weighted_element_from(spawn_function_table, const.SPAWN_WEIGHT_TABLE)
		spawn_function(first_spawn)
		-- do second spawn
		if math.random() < const.DOUBLE_SPAWN_CHANCE then
			spawn_function = helpers.random_weighted_element_from(spawn_function_table, const.SPAWN_WEIGHT_TABLE)
			spawn_function(spawn_locations[1])
		end
		game_spawn_count = game_spawn_count + 1
	end
	-- handle collision with stuff on the road
	for i=#entity_collection,1,-1 do
		local entity = entity_collection[i]
		if entity.is_top_or_bottom ~= player.is_top_or_bottom then
			if helpers.collide(entity, player) then
				if entity.encounter_type == const.ENCOUNTER_ENEMY then

					-- TODO - consider berserk dealing full og damage if not right
					-- weapon is used, aka as if player dealt no damage
					
					-- deal no damage if no weapon is active
					if player.weapon ~= const.NONE_TYPE then
						local using_effective_weapon = player.weapon == entity.weakness
						entity.health = entity.health - (using_effective_weapon and player.damage * 2 or player.damage)
					end
					
					local incoming_damage = 0
					-- if enemy still "alive"
					if entity.health > 0 then
					
						local berserk_right_weapon = true
						-- first check berserk and the right weapon
						-- because berserk hits double dam if you don't
						-- use the right weapon against them
						local is_berserk = entity.skill == const.ENEMY_SKILL_BERSERK
						if is_berserk and (entity.weakness ~= player.weapon) then
							berserk_right_weapon = false
						end
						incoming_damage = berserk_right_weapon and entity.health or entity.health * 2
						-- take player shield into account
						if player.shield > 0 then
							-- reduce damage by shield
							local remainder = incoming_damage - player.shield
							-- remove shield
							player.shield = math.max(0, player.shield-incoming_damage)
							-- after our remining damage is either positive, because shield did not get
							-- rid of all, or it is negative, meaning shield is higher, hence we no longer
							-- take damage (right???)
							incoming_damage = math.max(0, remainder)	
						end
					end
					-- don't forget to reduce the durability of the current weapon
					if incoming_damage > 0 then
						player.health = player.health - incoming_damage
					end
					player.durability = player.durability - 1
					if player.durability == 0 then
						player.weapon = const.NONE_TYPE
					end
					table.remove(entity_collection, i)
					player.defeated = player.defeated + 1
					player.gold = player.gold + 1
				elseif entity.encounter_type == const.ENCOUNTER_WEAPON then
					if (player.weapon == const.NONE_TYPE or player.secondary_weapon ~= const.NONE_TYPE) then
						player.weapon = entity.id
						player.damage = entity.damage
						player.durability = entity.durability
						table.remove(entity_collection, i)
					elseif player.secondary_weapon == const.NONE_TYPE then
						player.secondary_weapon = entity.id
						player.secondary_damage = entity.damage
						player.secondary_durability = entity.durability
						table.remove(entity_collection, i)
					end
				elseif entity.encounter_type == const.ENCOUNTER_ITEM then
					-- we need to check to not spend money on items
					-- that do nothing for us
					if player.gold >= entity.cost then
						if helpers.is_value_in_set(entity.stat, {"damage","durability"}) and player.weapon ~= const.NONE_TYPE then							
							player.gold = player.gold - entity.cost
							entity:apply(player)
							table.remove(entity_collection, i)
						elseif entity.stat == "health" then
							if player.health == player.max_health then
								player.max_health = player.max_health + math.floor(entity.stats.health/2)
							else
								player.gold = player.gold - entity.cost
								entity:apply(player)
							end
							table.remove(entity_collection, i)
						end
					end
				elseif entity.encounter_type == const.ENCOUNTER_CHOICE then
					entity:apply(player)
					table.remove(entity_collection, i)
				end
			end
		end
	end
	
	for i=#particle_collection, 1, -1 do
		local particle = particle_collection[i]
		particle:update()
		if particle.lifetime <= 0 then
			table.remove(particle_collection, i)
		end
	end
	-- check for player values to "clamp" or "rest"
	player.health = math.min(player.health, player.max_health)
	if player.durability <= 0 then
		player.weapon = const.NONE_TYPE
	end
	if player.health <= 0 then
		STATE = const.STATE_GAME_OVER
	end
end

function update_gameover()

end

function love.keypressed(key)
	for k,v in ipairs(keypress_listener_collection) do
		if v.keypressed then 
			v:keypressed(key)
		end
	end

	if key == "q" then
		love.event.push("quit", "restart")
		--love.event.quit( "restart" )
	end
end

function love.keyreleased(key)

	for k,v in ipairs(keypress_listener_collection) do
		if v.keyreleased then
			v:keyreleased(key)
		end
		
	end
	button_hold_frames = 0
end

function love.gamepadpressed(joystick, button)
	button_hold_frames = button_hold_frames + 1
end

function love.gamepadreleased(joystick, button)
	if (joystick:getConnectedIndex() == input_id) then
		for k,v in ipairs(keypress_listener_collection) do
			if v.keyreleased then 
				v:keyreleased(key)
			end
			
		end
	end
	button_hold_frames = 0
end

function love.touchpressed()
	button_hold_frames = button_hold_frames + 1
end

function love.touchreleased()
	for k,v in ipairs(keypress_listener_collection) do
		if v.keyreleased then 
			v:keyreleased(key)
		end
		
	end
	button_hold_frames = 0
end


function love.draw()
	
 	--love.graphics.setFont(_G.font)
	
	--love.graphics.scale(4,4)	

	
	local width, height = love.graphics.getDimensions()
	local gameScale = canvasWidth / canvasHeight
	local windowScale = width / height
	local sw, sh = width/canvasWidth, height/canvasHeight

	if windowScale > gameScale then
		drawScale = sh
	else
		drawScale = sw
	end

	local hSpace = width - (canvasWidth * drawScale)
	local vSpace = height - (canvasHeight * drawScale)

	local drawOffsetHorizontal = hSpace / 2
	local drawOffsetVertical = vSpace / 2





	love.graphics.setCanvas(gameCanvas)
	
	love.graphics.clear(0,0,0,1)

	STATE_MACHINE_FUNCTIONS[STATE].draw()

	love.graphics.setCanvas()
	love.graphics.draw(gameCanvas, drawOffsetHorizontal, drawOffsetVertical, 0, drawScale, drawScale)
end

function draw_menu()

	for _,particle in ipairs(particle_collection) do
		particle:draw()
	end

	love.graphics.draw(UI_IMAGES.MENU_BACKGROUND, 0, 24)
	love.graphics.draw(UI_IMAGES.MENU_TEXT_LOGO, 10, math.floor(1 + math.sin(math.rad(ticks))*2))
	love.graphics.draw(UI_IMAGES.MENU_PLAYER_SPRITE, menu_player_object.x, menu_player_object.y)
	
	local tip_text = "- press -"
	draw_press_promt(tip_text, 0, 42, true)
end

function draw_press_promt(text, x, y, is_center)
	x = is_center and 32-helpers.text_lenght(text)/2 or x
	if ticks then
		helpers.print_outline(text, x, y, color.PICO_LIGHT_GREY, 1, 1)
		helpers.print_outline(text, x, y+1, color.PICO_LAVENDER, 1, 1)
		color.set(color.PICO_LIGHT_GREY)
		love.graphics.print(text, _G.font, x, y)
		color.reset()
	end
end

function draw_game()
	
	
	
	for _,particle in ipairs(particle_collection) do
		particle:draw()
	end

	-- try to draw player
	player:draw()
	draw_enemies()

	-- draw stats of player
	UI_LINE_START = 58
	if player.weapon ~= const.NONE_TYPE then
		UI_LINE_START = UI_LINE_START - 6
	end
	if player.secondary_weapon ~= const.NONE_TYPE then
		UI_LINE_START = UI_LINE_START - 6
	end
	helpers.draw_icon_with_text(UI_IMAGES.HEART_ICON, 7, player.health.."/"..player.max_health, 0, UI_LINE_START, color.PICO_RED)

	if player.shield > 0 then
		local health_string_lenght = string.len(tostring(player.health).."/"..tostring(player.max_health)) * 4 + 7
		helpers.draw_icon_with_text(UI_IMAGES.SHIELD_ICON, 7, tostring(player.shield), health_string_lenght, UI_LINE_START, color.PICO_LIGHT_GREY)
	end

	local WEAPON_ICON_TABLE = {UI_IMAGES.WEAPON_SWORD, UI_IMAGES.WEAPON_SPEAR, UI_IMAGES.WEAPON_HAMMER}
	if player.weapon ~= const.NONE_TYPE then
		helpers.draw_icon_with_text(WEAPON_ICON_TABLE[player.weapon], 7, player.damage.."/"..player.durability, 0, UI_LINE_START + 5, color.PICO_LIGHT_GREY)
	end

	if player.secondary_weapon ~= const.NONE_TYPE then
		helpers.draw_icon_with_text(WEAPON_ICON_TABLE[player.secondary_weapon], 7, player.secondary_damage.."/"..player.secondary_durability, 0, UI_LINE_START + 10, color.PICO_LIGHT_GREY)
	end

	local goldt = tostring(player.gold)
	local dist = tostring(player.distance).."m"
	local gold_len = 62 - helpers.text_lenght(goldt) - 5
	local dist_len = 62 - helpers.text_lenght(dist)
	local start = (player.distance > 0 and dist_len-4 > gold_len) and dist_len or gold_len
	helpers.draw_icon_with_text(UI_IMAGES.COIN, 7, goldt , start-1, 53, color.PICO_ORANGE)
	if player.distance > 0 then	
		color.set(color.PICO_LIGHT_GREY)
    	love.graphics.print(dist, _G.font , start, 59)
		color.reset()
	end
end

function draw_gameover()
	local tip_text = "- press -"
	love.graphics.draw(UI_IMAGES.GAMEOVER_TEXT_LOGO, 10, math.floor(1 + math.sin(math.rad(ticks))*2))
	draw_press_promt(tip_text, 0, 57, true)
	local distance_text = "distance: "..player.distance..'m'
	local defeated_text = "defeated: "..player.defeated
	draw_press_promt(distance_text, 0, 27, true)
	draw_press_promt(defeated_text, 0, 35, true)
	-- draw_grave
	love.graphics.draw(UI_IMAGES.GAMEOVER_GRAVE, 19, 43)
	love.graphics.draw(dummy_image, 33, 46)
end