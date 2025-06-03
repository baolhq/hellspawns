local vector    = require("lib.vector")
local colors    = require("src.consts.colors")
local res       = require("src.consts.res")
local collider  = require("src.utils.collider")

local bullet    = {}

-- === Constants ===
local POOL_SIZE = 20
local DAMAGE    = 50
local SPEED     = 800
local SPRITE    = love.graphics.newImage(res.BULLET_SPR)

-- === Bullet Pool ===
local pool      = {}

-- Spawn a new bullet
local function spawn()
    local b = {
        dmg       = DAMAGE,
        speed     = SPEED,
        pos       = vector(0, 0),
        dir       = vector(0, 0),
        sprite    = SPRITE,
        width     = SPRITE:getWidth(),
        height    = SPRITE:getHeight(),
        removable = false,
    }

    setmetatable(b, { __index = bullet })
    return b
end

-- Create the bullet pool
local function createPool()
    for i = 1, POOL_SIZE do
        table.insert(pool, spawn())
    end
end

-- Get the last bullet from the pool
function bullet.get()
    if #pool == 0 then createPool() end
    return table.remove(pool)
end

-- === Behavior ===
function bullet:update(enemies, hitSound, dt)
    self.pos = self.pos + self.dir * self.speed * dt

    if self:isOutOfBounds() then
        self.removable = true
        return
    end

    -- Check hitting enemies
    for _, e in ipairs(enemies) do
        if collider.aabb(self, e) then
            e.hp = e.hp - self.dmg
            if e.hp <= 0 then e.removable = true end
            self.removable = true
            hitSound:play()
            break
        end
    end
end

-- Check out of screen
function bullet:isOutOfBounds()
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    return self.pos.x < 0 or self.pos.x + self.width > screenW or
        self.pos.y < 0 or self.pos.y + self.height > screenH
end

function bullet:draw()
    love.graphics.setColor(colors.WHITE)
    love.graphics.draw(self.sprite, self.pos.x, self.pos.y)
end

return bullet
