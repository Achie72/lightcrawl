local const = {}

const.TOP_LANE_Y_LEVEL = 10
const.BOTTOM_LANE_Y_LEVEL = 28
const.DOUBLE_SPAWN_CHANCE = 0.3
const.SPAWN_WEIGHT_TABLE = {6,2,1,1}

-- weapon types
const.NONE_TYPE = 0
const.SWORD_TYPE = 1
const.SPEAR_TYPE = 2
const.HAMMER_TYPE = 3

const.ENCOUNTER_ENEMY = "enemy"
const.ENCOUNTER_ITEM = "item"
const.ENCOUNTER_WEAPON = "weapon"
const.ENCOUNTER_CHOICE = "choice"
const.ENCOUNTER_SHOP = "shop"

const.ENEMY_SKILL_NONE = 1
const.ENEMY_SKILL_RANGED = 2
const.ENEMY_SKILL_BERSERK = 3
const.ENEMY_SKILL_RUSTING = 4

const.STATE_MENU = "menu"
const.STATE_GAME = "game"
const.STATE_GAME_OVER = "gameover"

const.MENU_LANE_TOP = 32
const.MENU_LANE_BOTTOM = 56 

return const