local tileManager = require("src.managers.tile_manager")
local vector      = require("lib.vector")
local colors      = require("src.consts.colors")
local consts      = require("src.consts.consts")
local drawer      = require("src.utils.drawer")
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
    self.isPaused = false
    self.isGameOver = false

    self.enemies = {}
    self.enemyMax = 5
    self.enemyTimer = 0
    self.enemyThreshold = 2

    if self.configs.diff then
        self.enemyMax = self.enemyMax * self.configs.diff
    end

    tileManager:init()
    player:init()

    self.assets.bgSound:play()
end

function mainScene:mousepressed(x, y, btn)
    if btn == 1 then
        local b = bullet.get()
        b.pos = player.gunTip:clone() -- Shoot from gun tip
        b.dir = (vector(x, y) - b.pos):normalized()
        table.insert(self.bullets, b)

        -- Play random pitch from 0.5 to 1.5
        local pitch = love.math.random() + 0.5
        self.assets.shootSound:setPitch(pitch)
        self.assets.shootSound:play()
    end
end

function mainScene:handleInputs(dt)
    if input:wasPressed("back") then
        self.assets.bgSound:stop()
        self.actions.switchScene("title")
        self:unload()
    end

    if input:wasPressed("space") then
        self.isPaused = not self.isPaused
    end

    -- Player movements
    if not (self.isPaused or self.isGameOver) then
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
    if self.isPaused then return end

    -- Update player states
    if player.hp <= 0 then self:gameOver() end
    if not self.isGameOver then
        player:update(self.enemies, self.assets.playerHitSound, dt)
    end

    -- Update bullet positions
    for i, b in ipairs(self.bullets) do
        b:update(self.enemies, self.assets.bulletHitSound, dt)
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

    -- Apply screenshake
    local offsetX, offsetY = 0, 0
    if player.shakeTime > 0 then
        offsetX = love.math.random(-consts.SHAKE_MAGNITUDE, consts.SHAKE_MAGNITUDE)
        offsetY = love.math.random(-consts.SHAKE_MAGNITUDE, consts.SHAKE_MAGNITUDE)
    end

    -- Save current screen state into the stack
    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)

    player:draw()
    if not self.isGameOver then player:drawHp() end

    for _, b in pairs(self.bullets) do b:draw() end
    for _, e in pairs(self.enemies) do e:draw() end

    -- Load previous screen state
    love.graphics.pop()

    -- Game paused message
    if self.isPaused then
        drawer.drawOverlay(140, "PAUSED", {
            { text = "PRESS <SPACE> TO RESUME", y = 28 },
        })
    end

    -- Game over message
    if self.isGameOver then
        drawer.drawOverlay(140, "GAME OVER", {
            { text = "PRESS <ENTER> TO RETURN", y = 24 }
        })
    end
end

return mainScene
