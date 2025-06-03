local tileManager  = require("src.managers.tile_manager")
local vector       = require("lib.vector")
local colors       = require("src.consts.colors")

local enemy        = {}

-- === Constants ===
local SPRITE_SCALE = 4
local SPRITE_SIZE  = 8 * SPRITE_SCALE
local POOL_SIZE    = 50
local SEP_RADIUS   = 32
local REPULSE_STR  = 100

-- === Enemy Pool ===
local pool         = {}

-- Pick one random position off-screen
local function getRandomPos()
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    local margin = 100
    -- Pick one random edge: 1=left, 2=right, 3=top, 4=bottom
    local edge = love.math.random(4)

    -- Set initial position to random off-screen
    if edge == 1 then
        return vector(-margin, love.math.random(0, screenH))
    elseif edge == 2 then
        return vector(margin + screenW, love.math.random(0, screenH))
    elseif edge == 3 then
        return vector(love.math.random(0, screenW), -margin)
    elseif edge == 4 then
        return vector(love.math.random(0, screenW), margin + screenH)
    end
end

-- Spawn an enemy with either "chaser" or "wanderer" behavior
local function spawn()
    local kind = love.math.random(2) and "chaser" or "wanderer"
    local e = {
        kind      = kind,
        maxHp     = 100,
        hp        = 100,
        pos       = getRandomPos(),
        dir       = vector(0, 0),
        width     = SPRITE_SIZE,
        height    = SPRITE_SIZE,
        removable = false,
        dmg       = kind == "chaser" and 20 or 10,
        speed     = kind == "chaser" and 50 or 100,
        sprite    = kind == "chaser" and
            tileManager.chaser or tileManager.wanderer,
    }

    setmetatable(e, { __index = enemy })
    return e
end

-- Create an object pool of enemies
local function createPool()
    for i = 1, POOL_SIZE do
        table.insert(pool, spawn())
    end
end

-- Get the last enemy from the pool
function enemy.get()
    if #pool == 0 then createPool() end
    return table.remove(pool)
end

-- === Behavior ===
function enemy:update(dt, others)
    local separation = self:computeSeparation(others)
    local direction = self.dir + separation * REPULSE_STR

    if direction:len() > 0 then
        direction = direction:normalized()
    end

    self.pos = self.pos + direction * self.speed * dt
end

-- Calculate the reverse vector to push enemies off each other
function enemy:computeSeparation(others)
    local sep = vector(0, 0)

    for _, e in ipairs(others) do
        if e ~= self then
            local offset = self.pos - e.pos
            local dist = offset:len()

            if dist < SEP_RADIUS and dist > 0 then
                local force = 1 - dist / REPULSE_STR
                -- Prevent jittering movements
                if force > 0.01 then
                    sep = sep + offset:normalized() * force
                end
            end
        end
    end

    return sep
end

function enemy:draw()
    local x, y = math.floor(self.pos.x), math.floor(self.pos.y)
    love.graphics.setColor(colors.WHITE)
    love.graphics.draw(tileManager.tilemap, self.sprite, x, y, 0, 4, 4)
end

return enemy
