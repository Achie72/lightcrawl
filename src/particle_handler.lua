local colors = require "src.utils.color"

---@class ParticleModule
local particle_handler = {   
    ---@enum PARTICLE_TYPE
    PARTICLE_TYPE = {
        DOT = 1, RECTANGLE = 2, CIRCLE = 3, SPARK = 4
    }
}

local color_handler = require "src.utils.color"

---Create a new particle object.
---@param x integer: x position to create particle on.
---@param y integer: y position to create the particle on.
---@param sx number: movement speed of the particle in x axis
---@param sy number: movement speed of the particle in y axis
---@param lifetime number: frame number the particle is alive for
---@param color RGBColor|number: the color value of the particle
---@param type PARTICLE_TYPE: type of the particle
---@return table: the particle object
function particle_handler.new_particle(x, y, sx, sy, lifetime, color, type)
    local particle = {
        x = x,
        y = y,
        sx = sx,
        sy = sy,
        lifetime = lifetime,
        color = color,
        type = type or particle_handler.PARTICLE_TYPE.DOT
    }

    function particle:update(dt)
        self.lifetime = self.lifetime - 1
        self.x = self.x + self.sx
        self.y = self.y + self.sy
    end

    function particle:draw()
        if self.type == particle_handler.PARTICLE_TYPE.DOT then
            color_handler.set(color)
            love.graphics.rectangle("fill", self.x, self.y, 1, 1)
            color_handler.reset()
        elseif self.type == particle_handler.PARTICLE_TYPE.SPARK then
            local clr = self.lifetime % 30 < 15 and colors.PICO_DARK_BLUE or colors.PICO_ORANGE
            color_handler.set(clr)
            love.graphics.rectangle("fill", self.x, self.y, 1, 1)
            color_handler.reset()
        end
    end

    return particle
end

---Create a new particle object.
---@param x integer: x position to create particle on.
---@param y integer: y position to create the particle on.
---@param sx number: movement speed of the particle in x axis
---@param sy number: movement speed of the particle in y axis
---@param lifetime number: frame number the particle is alive for
---@param color RGBColor | number: the color value of the particle
---@param type PARTICLE_TYPE: type of the particle
---@param amount? number: the amount of particles to create
---@return table: the particle object
function particle_handler.new_particles(x, y, sx, sy, lifetime, color, type, amount)
    local particles = {}
    for i=1,amount do
        local part = particle_handler.new_particle(x, y, sx, sy, lifetime, color, type)
        table.insert(particles, part)
    end
    
    return particles
end

---@class ParticleModule
return particle_handler