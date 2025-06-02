local vector = require("lib.vector")
local bullet = require("src.models.bullet")

local player = {}

function player:init(pos, sprite)
    self.maxHp = 100
    self.hp = self.maxHp
    self.speed = 400
    self.pos = pos
    self.velocity = vector(0, 0)
    self.sprite = sprite
    self.width = sprite:getWidth()
    self.height = sprite:getHeight()
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

function player:shoot(dir, sprite)
    local b = bullet.spawn(self.pos, dir, sprite)
    table.insert(self.bullets, b)
end

function player:update(dt)

end

function player:draw()
    love.graphics.draw(self.sprite, self.pos.x, self.pos.y)
end

return player
