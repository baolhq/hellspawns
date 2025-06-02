local tileManager = require("src.managers.tile_manager")
local vector = require("lib.vector")

local player = {}

function player:init()
    self.maxHp = 100
    self.hp = self.maxHp
    self.speed = 400
    self.velocity = vector(0, 0)
    self.sprite = tileManager.player
    self.width = 32 -- Base 8px, x4 upscaled
    self.height = 32

    local x = (love.graphics.getWidth() - 32) / 2
    local y = (love.graphics.getHeight() - 32) / 2
    self.pos = vector(x, y)
end

function player:move(dir, dt)
    -- Normalize diagonal movements
    if dir.x ~= 0 and dir.y ~= 0 then
        local len = math.sqrt(dir.x * dir.x + dir.y * dir.y)
        dir = vector(dir.x / len, dir.y / len)
    end

    self.pos.x = self.pos.x + dir.x * self.speed * dt
    self.pos.y = self.pos.y + dir.y * self.speed * dt
end

function player:update(dt)

end

function player:draw()
    local x = math.floor(self.pos.x)
    local y = math.floor(self.pos.y)
    love.graphics.draw(tileManager.tilemap, self.sprite, x, y, 0, 4, 4)
end

return player
