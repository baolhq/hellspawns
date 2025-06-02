local vector = require("lib.vector")
local res = require("src.consts.res")

local enemy = {
    kind = "chaser", -- "chaser", "wanderer"
    hp = 0,
    maxHp = 0,
    speed = 0,
    pos = {},
    dir = {},
    sprite = {},
    width = 0,
    height = 0,
    removable = false,
}

local pool = {}
local poolSize = 50
local sprite = love.graphics.newImage(res.ENEMY_SPR)

local function spawn()
    local randKind = love.math.random(2)
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    local margin = 100

    -- Pick one random edge: 1=left, 2=right, 3=top, 4=bottom
    local edge = love.math.random(4)
    local x, y

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

    local e = {
        kind = randKind == 1 and "chaser" or "wanderer",
        maxHp = 100,
        hp = 100,
        speed = 50,
        pos = vector(x, y),
        dir = vector(0, 0),
        sprite = sprite,
        width = sprite:getWidth(),
        height = sprite:getHeight(),
    }
    setmetatable(e, { __index = enemy })
    return e
end

local function createPool()
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
    local sepRadius = 30
    local repulseStr = 300

    for _, e in ipairs(others) do
        if e ~= self then
            local offset = self.pos - e.pos
            local dist = offset:len()

            if dist < sepRadius and dist > 0 then
                -- Push away from close enemies
                sep = sep + offset:normalized() * (1 - dist / repulseStr)
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
    love.graphics.draw(self.sprite, self.pos.x, self.pos.y)
end

return enemy
