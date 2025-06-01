local vector    = require("lib.vector")
local colors    = require("src.consts.colors")
local keys      = require("src.consts.keys")
local res       = require("src.consts.res")
local array     = require("src.utils.array")

local player    = require("src.models.player")
local bullet    = require("src.models.bullet")

local mainScene = {
    assets = {},
    actions = {},
    configs = {},
    bullets = {},
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
    local mx, my = love.mouse.getPosition()
    local b = bullet.get()

    b.pos = player.pos
    -- Set bullet direction to the cursor
    local dir = vector(mx, my) - b.pos
    b.dir = dir:normalized()
    table.insert(self.bullets, b)
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

    player:update(dt)
    for _, b in pairs(self.bullets) do
        b:update(dt)
    end
end

function mainScene:draw()
    love.graphics.clear(colors.SLATE_100)

    player:draw()
    for _, b in pairs(self.bullets) do
        b:draw()
    end
end

return mainScene
