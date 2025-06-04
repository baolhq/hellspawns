local tileManager  = require("src.managers.tile_manager")
local vector       = require("lib.vector")
local colors       = require("src.consts.colors")
local res          = require("src.consts.res")

local enemy        = {}

-- === Constants ===
local SPRITE_SCALE = 4
local SPRITE_SIZE  = 8 * SPRITE_SCALE
local POOL_SIZE    = 50
local SEP_RADIUS   = 32
local REPULSE_STR  = 100
local SHOW_HP_DUR  = 2

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

local function initParticle()
    local img = love.graphics.newImage(res.PARTICLE)
    local ps = love.graphics.newParticleSystem(img, 100)

    ps:setParticleLifetime(0.8, 1.2)
    ps:setEmissionRate(0)
    ps:setSizes(1.0, 0.6, 0.2)
    ps:setSpeed(40, 100)
    ps:setSpread(math.pi * 2)
    ps:setLinearDamping(1.5, 2.5)
    ps:setRadialAcceleration(-20, -50)
    ps:setColors(0.8, 0.8, 0.8, 1, 0.2, 0.2, 0.2, 0)

    return ps
end

-- Spawn an enemy with either "chaser" or "wanderer" behavior
local function spawn()
    local kind = love.math.random(2) and "chaser" or "wanderer"
    local e = {
        kind           = kind,
        maxHp          = 100,
        hp             = 100,
        pos            = getRandomPos(),
        dir            = vector(0, 0),
        alpha          = 1, -- Fading effect
        width          = SPRITE_SIZE,
        height         = SPRITE_SIZE,
        removable      = false,
        showHp         = false,
        showHpTimer    = 0,

        particles      = initParticle(),
        particlesTimer = 0,
        showParticles  = false,

        dmg            = kind == "chaser" and 20 or 10,
        speed          = kind == "chaser" and 50 or 100,
        sprite         = kind == "chaser" and
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
    -- Movements
    local separation = self:computeSeparation(others)
    local direction = self.dir + separation * REPULSE_STR

    if direction:len() > 0 then
        direction = direction:normalized()
    end
    self.pos = self.pos + direction * self.speed * dt

    -- Show health bar on being hit
    if self.showHp then
        self.showHpTimer = self.showHpTimer + dt
    end
    if self.showHpTimer > SHOW_HP_DUR then
        self.showHp = false
        self.showHpTimer = 0
    end

    -- Particles on death
    if self.activateParticles then
        self.particles:update(dt)
        self.particlesTimer = self.particlesTimer + dt

        -- Update self fading out
        self.alpha = self.alpha - dt

        if self.particlesTimer > 1 then
            self.removable = true
            self.activateParticles = false
        end
    end
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

function enemy:explode()
    self.particles:setPosition(
        self.pos.x + self.width / 2,
        self.pos.y + self.height / 2
    )
    self.particles:emit(10)
    self.activateParticles = true
    self.particlesTimer = 0
    self.speed = 0
end

function enemy:draw()
    local r, g, b = unpack(colors.WHITE)
    love.graphics.setColor(r, g, b, self.alpha)

    local x, y = math.floor(self.pos.x), math.floor(self.pos.y)
    love.graphics.draw(
        tileManager.tilemap,
        self.sprite,
        x, y, 0,
        SPRITE_SCALE, SPRITE_SCALE
    )

    -- Draw particles
    if self.activateParticles then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(self.particles)
    end

    if self.speed ~= 0 then self:drawHp() end
end

function enemy:drawHp()
    if not self.showHp then return end

    local barW, barH = 40, 8
    local x = self.pos.x + (self.width / 2) - (barW / 2)
    local y = self.pos.y + self.height + 8
    local percent = self.hp / self.maxHp

    -- Outline
    love.graphics.setColor(colors.SLATE_200)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, barW, barH, 4, 4)

    -- Fill
    love.graphics.setColor(colors.RED)
    love.graphics.rectangle("fill", x, y, barW * percent, barH, 4, 4)
end

return enemy
