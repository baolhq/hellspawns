local tileManager = require("src.managers.tile_manager")
local vector = require("lib.vector")
local res = require("src.consts.res")

local enemy = {}
local pool = {}
local poolSize = 50

local function getRandomPos()
    local x, y
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    local margin = 100
    -- Pick one random edge: 1=left, 2=right, 3=top, 4=bottom
    local edge = love.math.random(4)

    -- Set initial position to random off-screen
    if edge == 1 then
        x = -margin
        y = love.math.random(0, screenH)
    elseif edge == 2 then
        x = margin + screenW
        y = love.math.random(0, screenH)
    elseif edge == 3 then
        x = love.math.random(0, screenW)
        y = -margin
    elseif edge == 4 then
        x = love.math.random(0, screenW)
        y = margin + screenH
    end
    return vector(x, y)
end

local function spawn()
    local randKind = love.math.random(2)
    local e = {
        kind = randKind == 1 and "chaser" or "wanderer",
        maxHp = 100,
        hp = 100,
        pos = getRandomPos(),
        dir = vector(0, 0),
        width = 32, -- Base 8px, x4 upscaled
        height = 32,
        removable = false,
    }

    e.speed = randKind == 1 and 50 or 100
    e.sprite = randKind == 1 and tileManager.chaser or tileManager.wanderer

    setmetatable(e, { __index = enemy })
    return e
end

local function createPool()
    print("New pool requested")
    for i = 1, poolSize do
        table.insert(pool, spawn())
    end
end

function enemy.get()
    if #pool == 0 then createPool() end
    return table.remove(pool)
end

function enemy:update(dt, others)
    -- Separation vector
    local sep = vector(0, 0)
    local sepRadius = 32
    local repulseStr = 100

    for _, e in ipairs(others) do
        if e ~= self then
            local offset = self.pos - e.pos
            local dist = offset:len()

            if dist < sepRadius and dist > 0 then
                local force = (1 - dist / repulseStr)
                if force > 0.01 then
                    -- Prevent jittering movements
                    sep = sep + offset:normalized() * force
                end
            end
        end
    end

    -- Combine with exists direction
    local comDir = self.dir + sep * repulseStr
    if comDir:len() > 0 then
        comDir = comDir:normalized()
    end

    -- Apply movements
    self.pos = self.pos + comDir * self.speed * dt
end

function enemy:draw()
    local x = math.floor(self.pos.x)
    local y = math.floor(self.pos.y)
    love.graphics.draw(tileManager.tilemap, self.sprite, x, y, 0, 4, 4)
end

return enemy
