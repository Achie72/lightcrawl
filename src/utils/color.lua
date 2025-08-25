local color = {}

---@alias RGBColor {number, number, number}
---@class ColorModule
---@field palette RGBColor[]
---@field PICO_BLACK RGBColor
---@field PICO_RED RGBColor

-- Actual color values
color.palette = {
    {0, 0, 0},         -- 1 - BLACK
    {29, 43, 83},      -- 2 - DARK_BLUE
    {126, 37, 83},     -- 3 - DARK_PURPLE
    {0, 135, 81},      -- 4 - DARK_GREEN
    {171, 82, 54},     -- 5 - BROWN
    {95, 87, 79},      -- 6 - DARK_GREY
    {194, 195, 199},   -- 7 - LIGHT_GREY
    {255, 241, 232},   -- 8 - WHITE
    {255, 0, 77},      -- 9 - RED
    {255, 163, 0},     -- 10 - ORANGE
    {55, 236, 39},     -- 11 - YELLOW
    {0, 228, 54},      -- 12 - GREEN
    {41, 173, 255},    -- 13 - BLUE
    {131, 118, 156},   -- 14 - LAVENDER
    {255, 119, 168},   -- 15 - PINK
    {255, 204, 170},   -- 16 - LIGHT_PEACH
    {41, 24, 20},      -- 17 - BROWNISH_BLACK
    {17, 29, 53},      -- 18 - DARKER_BLUE
    {66, 33, 54},      -- 19 - DARKER_PURPLE
    {18, 83, 89},      -- 20 - BLUE_GREEN
    {116, 47, 41},     -- 21 - DARK_BROWN
    {73, 51, 59},      -- 22 - DARKER_GREY
    {162, 136, 121},   -- 23 - MEDIUM_GREY
    {243, 239, 125},   -- 24 - LIGHT_YELLOW
    {190, 18, 80},     -- 25 - DARK_RED
    {255, 108, 36},    -- 26 - DARK_ORANGE
    {168, 231, 46},    -- 27 - LIME_GREEN
    {0, 181, 67},      -- 28 - MEDIUM_GREEN
    {6, 90, 181},      -- 29 - TRUE_BLUE
    {117, 70, 101},    -- 30 - MAUVE
    {255, 110, 89},    -- 31 - DARK_PEACH
    {255, 157, 129},   -- 32 - PEACH
    {119, 195, 246}    -- 33 - BABY_BLUE
}

-- Constants for named access
color.PICO_BLACK            = color.palette[1]
color.PICO_DARK_BLUE        = color.palette[2]
color.PICO_DARK_RED         = color.palette[3]
color.PICO_DARK_GREEN       = color.palette[4]
color.PICO_BROWN            = color.palette[5]
color.PICO_DARK_GREY        = color.palette[6]
color.PICO_LIGHT_GREY       = color.palette[7]
color.PICO_WHITE            = color.palette[8]
color.PICO_RED              = color.palette[9]
color.PICO_ORANGE           = color.palette[10]
color.PICO_YELLOW           = color.palette[11]
color.PICO_GREEN            = color.palette[12]
color.PICO_BLUE             = color.palette[13]
color.PICO_LAVENDER         = color.palette[14]
color.PICO_PINK             = color.palette[15]
color.PICO_LIGHT_PEACH      = color.palette[16]
color.PICO_ALT_BLACK        = color.palette[17]
color.PICO_ALT_BLUE         = color.palette[18]
color.PICO_ALT_PURPLE       = color.palette[19]
color.PICO_ALT_BLUE_GREEN   = color.palette[20]
color.PICO_ALT_DARK_BROWN   = color.palette[21]
color.PICO_ALT_DARKER_GREY  = color.palette[22]
color.PICO_ALT_MEDIUM_GREY  = color.palette[23]
color.PICO_ALT_LIGHT_YELLOW = color.palette[24]
color.PICO_ALT_DARK_RED     = color.palette[25]
color.PICO_ALT_DARK_ORANGE  = color.palette[26]
color.PICO_ALT_LIME_GREEN   = color.palette[27]
color.PICO_ALT_MEDIUM_GREEN = color.palette[28]
color.PICO_ALT_TRUE_BLUE    = color.palette[29]
color.PICO_ALT_MAUVE        = color.palette[30]
color.PICO_ALT_DARK_PEACH   = color.palette[31]
color.PICO_ALT_PEACH        = color.palette[32]
color.BABY_BLUE             = color.palette[33]

--- Set the color value of love.graphics (through love.graphics.setcolor)
---@param color_index RGBColor | number: fetch the color from color.palette either through index or name
---@param alpha? number: set the alpha value. Default: 255
function color.set(color_index, alpha)
    local color_to_use = type(color_index) == "number" and color.palette[color_index + 1] or color_index
    love.graphics.setColor(
        color_to_use[1] / 255,
        color_to_use[2] / 255,
        color_to_use[3] / 255)
end

--- Restore the love.graphics.color() to 1,1,1,1
function color.reset()
    love.graphics.setColor(1,1,1,1)
end

---@type ColorModule
return color