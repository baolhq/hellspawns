local vector   = require("lib.vector")
local res      = require("src.consts.res")
local collider = require("src.utils.collider")

local bullet   = {
    dmg = 0,
    speed = 0,
    pos = {},
    dir = {},
    sprite = {},
    width = 0,
    height = 0,
    removable = false,
}

local pool     = {}
local poolSize = 20
local sprite   = love.graphics.newImage(res.BULLET_SPR)

local function spawn()
    local b = {
        dmg = 50,
        speed = 800,
        pos = vector(0, 0),
        dir = vector(0, 0),
        sprite = sprite,
        width = sprite:getWidth(),
        height = sprite:getHeight(),
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

function bullet:update(enemies, dt)
    self.pos = self.pos + self.dir * self.speed * dt

    for i, e in ipairs(enemies) do
        if collider.aabb(self, e) then
            -- Enemy takes damage
            e.hp = e.hp - self.dmg
            if e.hp <= 0 then e.removable = true end

            self.removable = true
            break
        end
    end
end

function bullet:draw()
    love.graphics.draw(self.sprite, self.pos.x, self.pos.y)
end

return bullet
