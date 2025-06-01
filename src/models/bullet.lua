local vector   = require("lib.vector")
local res      = require("src.consts.res")

local bullet   = {
    dmg = 0,
    speed = 0,
    pos = {},
    dir = {},
    sprite = {},
}

local pool     = {}
local poolSize = 20
local sprite   = love.graphics.newImage(res.BULLET_SPR)

local function spawn()
    local b = {
        dmg = 20,
        speed = 800,
        pos = vector(0, 0),
        dir = vector(0, 0),
        sprite = sprite,
    }
    setmetatable(b, { __index = bullet })
    return b
end

local function createPool()
    for i = 1, poolSize do
        table.insert(pool, spawn())
    end
end

function bullet.get()
    if #pool == 0 then createPool() end
    return table.remove(pool)
end

function bullet:update(dt)
    self.pos = self.pos + self.dir * self.speed * dt
end

function bullet:draw()
    love.graphics.draw(self.sprite, self.pos.x, self.pos.y)
end

return bullet
