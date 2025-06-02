local vector    = require("lib.vector")
local colors    = require("src.consts.colors")
local keys      = require("src.consts.keys")
local res       = require("src.consts.res")
local array     = require("src.utils.array")

local player    = require("src.models.player")
local bullet    = require("src.models.bullet")
local enemy     = require("src.models.enemy")

local mainScene = {
    assets = {},
    actions = {},
    configs = {},
    bullets = {},
    enemies = {},
    enemyMax = 10,
    enemyTimer = 0,
    enemyThreshold = 2,
}

function mainScene:load(assets, actions, configs)
    self.assets = assets
    self.actions = actions
    self.configs = configs

    -- Initialize the player
    local pS = love.graphics.newImage(res.PLAYER_SPR)
    local pX = (love.graphics.getWidth() - pS:getWidth()) / 2
    local pY = (love.graphics.getHeight() - pS:getHeight()) / 2
    player:init(vector(pX, pY), pS)
end

function mainScene:keypressed(key)
    if array.contains(keys.BACK, key) then
        self.actions.switchScene("title")
    end
end

function mainScene:mousepressed(x, y, btn)
    if btn == 1 then
        local b = bullet.get()

        b.pos = player.pos
        -- Set bullet direction to the cursor
        local dir = vector(x, y) - b.pos
        b.dir = dir:normalized()
        table.insert(self.bullets, b)
    end
end

local function handleMovement(dt)
    -- Player movements
    local dir = vector(0, 0)
    for _, k in pairs(keys.LEFT) do
        if love.keyboard.isDown(k) then dir.x = dir.x - 1 end
    end
    for _, k in pairs(keys.RIGHT) do
        if love.keyboard.isDown(k) then dir.x = dir.x + 1 end
    end
    for _, k in pairs(keys.UP) do
        if love.keyboard.isDown(k) then dir.y = dir.y - 1 end
    end
    for _, k in pairs(keys.DOWN) do
        if love.keyboard.isDown(k) then dir.y = dir.y + 1 end
    end
    player:move(dir, dt)
end

function mainScene:update(dt)
    handleMovement(dt)

    -- Update player states
    player:update(dt)

    -- Update bullet positions
    for i, b in ipairs(self.bullets) do
        b:update(self.enemies, dt)
        if b.removable then table.remove(self.bullets, i) end
    end

    -- Update enemies
    self.enemyTimer = self.enemyTimer + dt
    if self.enemyTimer >= self.enemyThreshold and #self.enemies == 0 then
        for i = 1, self.enemyMax do
            table.insert(self.enemies, enemy.get())
        end
        self.enemyTimer = 0
    end

    for i, e in ipairs(self.enemies) do
        local dir = vector(player.pos.x, player.pos.y) - e.pos
        e.dir = dir:normalized()
        e:update(dt, self.enemies)
        if e.removable then table.remove(self.enemies, i) end
    end

    for i = #self.enemies, 1, -1 do
        local e = self.enemies[i]
        local dir = vector(player.pos.x, player.pos.y) - e.pos
        e.dir = dir:normalized()
        e:update(dt, self.enemies)

        if e.removable then table.remove(self.enemies, i) end
    end
end

function mainScene:draw()
    love.graphics.clear(colors.SLATE_100)

    player:draw()
    for _, b in pairs(self.bullets) do b:draw() end
    for _, e in pairs(self.enemies) do e:draw() end
end

return mainScene
