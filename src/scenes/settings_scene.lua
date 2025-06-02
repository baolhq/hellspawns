local inputManager  = require("src.managers.input_manager")
local colors        = require("src.consts.colors")

local settingsScene = {
    assets = {},
    actions = {},
    configs = {},
}

function settingsScene:load(assets, actions, configs)
    self.assets = assets
    self.actions = actions
    self.configs = configs
end

function settingsScene:handleInputs()
    if inputManager:wasPressed("back") then
        self.actions.switchScene("title")
    end
end

function settingsScene:update(dt)
    self:handleInputs()
end

function settingsScene:draw()
    love.graphics.clear(colors.SLATE_100)
end

return settingsScene
