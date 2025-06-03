local tileManager = require("src.managers.tile_manager")
local vector      = require("lib.vector")
local colors      = require("src.consts.colors")
local input       = require("src.utils.input")

local player      = require("src.models.player")
local bullet      = require("src.models.bullet")
local enemy       = require("src.models.enemy")

local mainScene   = {}

function mainScene:load(assets, actions, configs)
    self.assets = assets
    self.actions = actions
    self.configs = configs
    self.bullets = {}
    self.enemies = {}
    self.enemyMax = 10
    self.enemyTimer = 0
    self.enemyThreshold = 2
    self.isGameOver = false
    tileManager:init()

    -- Initialize the player
    player:init()
end

function mainScene:mousepressed(x, y, btn)
    if btn == 1 then
        local b = bullet.get()
        local bx = player.pos.x + player.width / 2
        local by = player.pos.y + player.height / 2

        b.pos = vector(bx, by)
        -- Set bullet direction to the cursor
        local dir = vector(x, y) - b.pos
        b.dir = dir:normalized()
        table.insert(self.bullets, b)
    end
end

function mainScene:handleInputs(dt)
    if input:wasPressed("back") then
        self.actions.switchScene("title")
    end

    -- Player movements
    if not self.isGameOver then
        local dir = vector(0, 0)
        if input:isDown("left") then dir.x = dir.x - 1 end
        if input:isDown("right") then dir.x = dir.x + 1 end
        if input:isDown("up") then dir.y = dir.y - 1 end
        if input:isDown("down") then dir.y = dir.y + 1 end
        player:move(dir, dt)
    end
end

function mainScene:unload()
    for _, b in pairs(self.bullets) do
        b.removable = true
    end

    for _, e in pairs(self.enemies) do
        e.removable = true
    end
end

function mainScene:gameOver()
    self.isGameOver = true
    self:unload()
end

function mainScene:update(dt)
    self:handleInputs(dt)

    -- Update player states
    if not self.isGameOver then player:update(self.enemies, dt) end
    if player.hp <= 0 then self:gameOver() end

    -- Update bullet positions
    for i, b in ipairs(self.bullets) do
        b:update(self.enemies, dt)
        if b.removable then table.remove(self.bullets, i) end
    end

    -- Spawn new enemy wave
    self.enemyTimer = self.enemyTimer + dt
    if self.enemyTimer >= self.enemyThreshold and #self.enemies == 0 then
        for i = 1, self.enemyMax do
            table.insert(self.enemies, enemy.get())
        end
        self.enemyTimer = 0
    end

    -- Move and destroy dead enemies
    for i = #self.enemies, 1, -1 do
        local e = self.enemies[i]
        local target = vector(player.pos.x, player.pos.y)

        if e.kind == "chaser" or love.math.random(100) <= 50 then
            -- Chaser: Follow player till its end
            e.dir = (target - e.pos)
        else
            -- Wanderer: Randomized movements
            e.dir = vector(love.math.random(-1, 1), love.math.random(-1, 1))
        end

        e:update(dt, self.enemies)
        if e.removable then table.remove(self.enemies, i) end
    end
end

function mainScene:draw()
    love.graphics.clear(colors.SLATE_100)

    player:draw()
    if not self.isGameOver then player:drawHeath() end

    for _, b in pairs(self.bullets) do b:draw() end
    for _, e in pairs(self.enemies) do e:draw() end
end

return mainScene
