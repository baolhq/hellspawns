local res = require("src.consts.res")

local tileManager = {}

function tileManager:init()
    self.tilemap = love.graphics.newImage(res.TILEMAP)
    self.player = love.graphics.newQuad(32, 0, 8, 8, self.tilemap)
    self.chaser = love.graphics.newQuad(56, 0, 8, 8, self.tilemap)
    self.wanderer = love.graphics.newQuad(72, 0, 8, 8, self.tilemap)
end

return tileManager
