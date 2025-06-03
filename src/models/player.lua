local tileManager     = require("src.managers.tile_manager")
local vector          = require("lib.vector")
local colors          = require("src.consts.colors")
local collider        = require("src.utils.collider")

local player          = {}

-- === Constants ===
local IFRAME_DURATION = 2
local SPRITE_SCALE    = 4
local SPRITE_SIZE     = 8 * SPRITE_SCALE

function player:init()
    self.maxHp = 100
    self.hp = self.maxHp
    self.speed = 400
    self.velocity = vector(0, 0)
    self.sprite = tileManager.player
    self.width = SPRITE_SIZE
    self.height = SPRITE_SIZE
    self.iFrame = false
    self.iFrameTimer = 0

    -- Center player on screen
    local x = (love.graphics.getWidth() - 32) / 2
    local y = (love.graphics.getHeight() - 32) / 2
    self.pos = vector(x, y)
end

function player:move(dir, dt)
    -- Normalize diagonal movements
    if dir.x ~= 0 and dir.y ~= 0 then dir = dir:normalized() end

    self.pos = self.pos + dir * self.speed * dt
end

-- Invincible state last for a bit
function player:updateIFrame(dt)
    if self.iFrame then
        if self.iFrameTimer < IFRAME_DURATION then
            self.iFrameTimer = self.iFrameTimer + dt
        else
            self.iFrameTimer = 0
            self.iFrame = false
        end
    end
end

-- Check colliding with enemies
function player:checkCollisions(enemies, dt)
    for i, e in ipairs(enemies) do
        if not self.iFrame and collider.aabb(self, e) then
            self.hp = self.hp - e.dmg
            self.iFrame = true
            break
        end
    end
end

-- === Behavior ===
function player:update(enemies, dt)
    self:updateIFrame(dt)
    self:checkCollisions(enemies, dt)
end

function player:draw()
    local x, y = math.floor(self.pos.x), math.floor(self.pos.y)
    love.graphics.setColor(colors.WHITE)
    love.graphics.draw(
        tileManager.tilemap, self.sprite, x, y,
        0, SPRITE_SCALE, SPRITE_SCALE
    )
end

function player:drawHeath()
    if not self.iFrame then return end

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

return player
