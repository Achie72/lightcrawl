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
local game_background_handler = require "src.game_background_handler"
local helpers = require "src.utils.helpers"
local enemy_image_handler = require "src.utils.enemy_image_handler"
local sound_effect_handler = require "src.utils.sound_effect_handler"

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
	player = player_hander.new(1, 8, const.TOP_LANE_Y_LEVEL + 8)
	particle_collection = {}
	keypress_listener_collection = {}
	table.insert(keypress_listener_collection,player)
	entity_collection = {}
	--table.insert(entity_collection, enemy_handler.new(1, true))
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
	music_volume_ui = {
		master_volume = 1,
		on_screen_y = 58,
		off_screen = 80,
		draw_y = 0,
		y = 70, 
		pressed_ticks = 0
	}
	
	music:play()
	music:setLooping(true)

	dummy_image = love.graphics.newImage("assets/sprites/enemies/skeleton_archer.png")
	game_spawn_count = 0
	spawnticks = 0

	background_images = {}
	float_text_collection = {}
	projectile_collection = {}
	tooltip = {
		off_screen_y = -16,
		on_screen_y = 2,
		text = {},
		time_to_stay = 20,
		draw_y = 0
	}
	speed_map = {
		{60, 300},
		{40, 120},
		{20, 60}
	}
	gamespeed = 1
end

function update_projectile()
	for i=#projectile_collection, 1, -1 do
		local entity = projectile_collection[i]
		entity:update()
		if helpers.collide(player, entity) then
			player:take_damage(entity.damage)
			sound_effect_handler.play("hit")
			table.remove(projectile_collection, i)
		elseif entity.x < -8 then
			table.remove(projectile_collection, i)
		end
	end
end

function set_tooltip(text, time)
	tooltip.time_to_stay = time
	tooltip.text = text
end

function update_entities()
	for i=#entity_collection, 1, -1 do
		local e = entity_collection[i]
		e:update()
		if e.x < -10 then
			table.remove(entity_collection, i)
		end
	end

	for i=#background_images,1,-1 do
		local bg = background_images[i]
		bg:update()
		if bg.x <= -63 then
			table.remove(background_images, i)
			table.insert(background_images, game_background_handler.new(math.random(3), false))
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
	--player.weapon = const.NONE_TYPE
	--player.secondary_weapon = const.NONE_TYPE
	player.defeated = 0
	player.distance = 1
	player.gold = 0
	game_spawn_count = 0
	_G.diff_val = 0
	_G.item_diff_val = 0
	background_images = {}
	entity_collection = {}
	table.insert(background_images, game_background_handler.new(math.random(3), true))
	table.insert(background_images, game_background_handler.new(math.random(3), false))
	spawnticks = 0
	projectile_collection = {}
	speed = 0
	player.weapon = helpers.random_element_from({const.SWORD_TYPE, const.HAMMER_TYPE, const.SPEAR_TYPE})
	player.durability = 2
	player.damage = 1
	player.secondary_weapon = const.NONE_TYPE
	player.secondary_damage = 0
	player.secondary_durability = 0
end
function spawn_enemy(pos)
	table.insert(entity_collection, enemy_handler.new(helpers.random_weighted_element_from({1,2,3,4,5},{3,2,2,3,1}),pos == const.TOP_LANE_Y_LEVEL))
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
	if player.distance < 100 then gamespeed = 1 end
	if player.distance > 100 and player.distance < 200 then gamespeed = 2 end
	if player.distance > 200 then gamespeed = 3 end
	music:setVolume(music_volume_ui.master_volume)
	accumulator = accumulator+dt
	if accumulator >= tickPeriod then	
		ticks = ticks+1
		if ticks % speed_map[gamespeed][1] == 0 and (STATE == const.STATE_GAME) then
			ticks = 0
			player.distance =  player.distance + 1
		end
		STATE_MACHINE_FUNCTIONS[STATE].update()
		accumulator = accumulator - tickPeriod
		music_volume_ui.pressed_ticks = math.max(0, music_volume_ui.pressed_ticks - 1)
		tooltip.time_to_stay = math.max(0, tooltip.time_to_stay - 1)
		update_projectile()
	end
end

function update_menu()
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
	spawnticks = math.max(spawnticks - 1, 0)
	_G.diff_val = math.floor(player.distance/10)
	_G.item_diff_val = math.floor(_G.diff_val * 0.6)
	if love.keyboard.isDown('x') or (joystick ~= nil and joystick:isGamepadDown('x')) then
		button_hold_frames = button_hold_frames + 1
	end

	player:update(dt)
	if ticks % speed_map[gamespeed][1] == 0 then
		update_entities()
	end

	-- handle collisions
	local spawn_locations = {const.BOTTOM_LANE_Y_LEVEL, const.TOP_LANE_Y_LEVEL}
	local first_spawn = helpers.random_element_from(spawn_locations)
	helpers.remove_element_from_table(spawn_locations, first_spawn)
	if spawnticks == 0 then
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
		spawnticks = spawnticks + speed_map[gamespeed][2]
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
						--[[
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
						]]
						player:take_damage(incoming_damage)
					else
						sound_effect_handler.play("kill")
					end
					-- don't forget to reduce the durability of the current weapon
					--[[
					if incoming_damage > 0 then
						sound_effect_handler.play("hit")
						player.health = player.health - incoming_damage
					else
						sound_effect_handler.play("block")
					end
					]]
					player.durability = player.durability - 1
					if entity.skill == 4 and player.durability > 0 then
						player.durability = 0
					end
					if player.durability == 0 then
						set_tooltip({"weapon broken"}, 80)
						player.weapon = const.NONE_TYPE
					end
					local enemy_colors = {{color.PICO_WHITE, color.PICO_LIGHT_GREY},{color.PICO_GREEN, color.PICO_DARK_GREEN},{color.PICO_GREEN, color.PICO_DARK_GREEN},{color.PICO_GREEN, color.PICO_DARK_GREEN},{color.PICO_GREEN, color.PICO_DARK_GREEN}}
					for i=1, 20 do
						local part = particle_handler.new_particle(entity.x+8, entity.y, math.random(), math.random()*helpers.random_element_from({-1,1}), math.random(7)+7,helpers.random_element_from(enemy_colors[entity.id]), particle_handler.PARTICLE_TYPE.CIRCLE, helpers.random_element_from({0.5,1,1,1,1.5,2}))
						table.insert(particle_collection, part)    
					end
					
					if player.health > 0 then
						player.defeated = player.defeated + 1
					else
						player.defeated_by = entity.id
					end
					player.gold = player.gold + 1
					
					table.remove(entity_collection, i)
				elseif entity.encounter_type == const.ENCOUNTER_WEAPON then
					sound_effect_handler.play("pickup")
					if (player.weapon == const.NONE_TYPE or player.secondary_weapon ~= const.NONE_TYPE) then
						player.weapon = entity.id
						player.damage = entity.damage
						player.durability = entity.durability
						for i=1, 20 do
							local part = particle_handler.new_particle(entity.x, entity.y+6, math.random()*helpers.random_element_from({1, -1}), math.random()*-1, math.random(7)+7, color.PICO_LIGHT_GREY, particle_handler.PARTICLE_TYPE.CIRCLE, helpers.random_element_from({0.5,1,1,1,1.5,2}))
							table.insert(particle_collection, part)    
						end
						table.remove(entity_collection, i)
					elseif player.secondary_weapon == const.NONE_TYPE then
						player.secondary_weapon = entity.id
						player.secondary_damage = entity.damage
						player.secondary_durability = entity.durability
						for i=1, 20 do
							local part = particle_handler.new_particle(entity.x, entity.y+6, math.random()*helpers.random_element_from({1, -1}), math.random()*-1, math.random(7)+7, color.PICO_LIGHT_GREY, particle_handler.PARTICLE_TYPE.CIRCLE, helpers.random_element_from({0.5,1,1,1,1.5,2}))
							table.insert(particle_collection, part)    
						end
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
							sound_effect_handler.play("pickup")
						elseif entity.stat == "health" then
							if player.health == player.max_health then
								player.max_health = player.max_health + math.floor(entity.stats.health/2)
							else
								player.gold = player.gold - entity.cost
								entity:apply(player)
							end
							table.remove(entity_collection, i)
							sound_effect_handler.play("pickup")
						end
					end
				elseif entity.encounter_type == const.ENCOUNTER_CHOICE then
					entity:apply(player)
					table.remove(entity_collection, i)
					sound_effect_handler.play("pickup")
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
		sound_effect_handler.play("dead")
		particle_collection = {}
		tooltip.time_to_stay = 0
		music:pause()
	end
end

function update_gameover()

end

function add_puff(x,y)
	
end

function love.keypressed(key)
	sound_effect_handler.play("press")
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
	for k,v in ipairs(keypress_listener_collection) do
		if v.keypressed then 
			v:keypressed(button)
		end
	end
end

function love.gamepadreleased(joystick, button)
	for k,v in ipairs(keypress_listener_collection) do
		if v.keyreleased then 
			v:keyreleased(button)
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
	draw_music_ui()
	draw_tooltip()

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
	
	local tip_text = "- press x -"
	if ticks % 60 > 30 then
		draw_press_promt(tip_text, 0, 42, true)
	end
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

function draw_music_ui()
	local goal_y = music_volume_ui.pressed_ticks > 0 and music_volume_ui.on_screen_y or music_volume_ui.off_screen
	music_volume_ui.draw_y, music_volume_ui.ay = helpers.smooth_move(goal_y, music_volume_ui.draw_y, music_volume_ui.ay, 0.05, 0.3, 0.02)
	local text = "<"
	for i=1,10 do
		local append_char = i <= music_volume_ui.master_volume*10 and "#" or "."
		text = text..append_char
	end
	text = text ..">"
	draw_press_promt("volume", 0, music_volume_ui.draw_y-6, true)
	draw_press_promt(text, 0, music_volume_ui.draw_y, true)
end

function draw_tooltip()
	local goal_y = tooltip.time_to_stay > 0 and tooltip.on_screen_y or tooltip.off_screen_y
	tooltip.draw_y, tooltip.ay = helpers.smooth_move(goal_y, tooltip.draw_y, tooltip.ay, 0.05, 0.3, 0.02)
	if #tooltip.text > 0 then
		for i=0,#tooltip.text-1 do
			draw_press_promt(tooltip.text[i+1], 0, tooltip.draw_y+i*6, true)
		end
	end
end

function draw_game()
	
	
	for i=#background_images,1,-1 do
		local bg = background_images[i]
		bg:draw()
	end
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

	local text_lenght_table = {}
	if player.shield > 0 then
		local health_string_lenght = string.len(tostring(player.health).."/"..tostring(player.max_health)) * 4 + 7
		helpers.draw_icon_with_text(UI_IMAGES.SHIELD_ICON, 7, tostring(player.shield), health_string_lenght, UI_LINE_START, color.PICO_LIGHT_GREY)
	end
	local sprite_offsets_for_hp_line = player.shield > 0 and 15 or 4
	table.insert(text_lenght_table, helpers.text_lenght(player.health.."/"..player.max_health..player.shield) +  sprite_offsets_for_hp_line )

	local WEAPON_ICON_TABLE = {UI_IMAGES.WEAPON_SWORD, UI_IMAGES.WEAPON_SPEAR, UI_IMAGES.WEAPON_HAMMER}
	if player.weapon ~= const.NONE_TYPE then
		helpers.draw_icon_with_text(WEAPON_ICON_TABLE[player.weapon], 7, player.damage.."/"..player.durability, 0, UI_LINE_START + 5, color.PICO_LIGHT_GREY)
		table.insert(text_lenght_table, helpers.text_lenght(player.damage.."/"..player.durability) + 8)
	end

	if player.secondary_weapon ~= const.NONE_TYPE then
		helpers.draw_icon_with_text(WEAPON_ICON_TABLE[player.secondary_weapon], 7, player.secondary_damage.."/"..player.secondary_durability, 0, UI_LINE_START + 10, color.PICO_LIGHT_GREY)
		table.insert(text_lenght_table, helpers.text_lenght(player.secondary_damage.."/"..player.secondary_durability) + 8)
	end

	local goldt = tostring(player.gold)
	local dist = tostring(player.distance).."m"
	local gold_len = helpers.text_lenght(goldt) + 6
	local dist_len = helpers.text_lenght(dist)
	local start = (player.distance > 0 and dist_len > gold_len) and dist_len or gold_len
	helpers.draw_icon_with_text(UI_IMAGES.COIN, 7, goldt , 62-start, 53, color.PICO_ORANGE)
	if player.distance > 0 then	
		color.set(color.PICO_LIGHT_GREY)
    	love.graphics.print(dist, _G.font ,  63-start, 59)
		color.reset()
	end

	local left_side_box_border = math.max(unpack(text_lenght_table))

	color.set(color.PICO_LIGHT_GREY)
	-- for hp and weapons
	love.graphics.rectangle("line", -0.5, UI_LINE_START+0.5-1, left_side_box_border, 20)
	love.graphics.rectangle("line", left_side_box_border-1+0.5, UI_LINE_START+0.5-3, 2, 2)
	-- for gold and distance
	love.graphics.rectangle("line",  63-start-1-0.5, 52+0.5, 40, 40)
	love.graphics.rectangle("line",  63-start-1-0.5-2, 52+0.5-2, 2, 2)
	color.reset()

	draw_projectile()

	for _,particle in ipairs(particle_collection) do
		particle:draw()
	end
end

function draw_gameover()
	local tip_text = "- press x-"
	love.graphics.draw(UI_IMAGES.GAMEOVER_TEXT_LOGO, 10, math.floor(1 + math.sin(math.rad(ticks))*2))
	draw_press_promt(tip_text, 0, 57, true)
	local distance_text = "distance: "..player.distance..'m'
	local defeated_text = "defeated: "..player.defeated
	draw_press_promt(distance_text, 0, 27, true)
	draw_press_promt(defeated_text, 0, 35, true)
	-- draw_grave
	love.graphics.draw(UI_IMAGES.GAMEOVER_GRAVE, 19, 43)
	if player.defeated_by == 0 then player.defeated_by = 1 end
	local sprite_to_draw = ticks % 30 > 15 and enemy_image_handler.images[player.defeated_by][1] or enemy_image_handler.images[player.defeated_by][2]
	love.graphics.draw(sprite_to_draw, 33, 46)
end

function draw_projectile()
	for i=#projectile_collection, 1, -1 do
		projectile_collection[i]:draw()
	end
end