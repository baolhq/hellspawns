local colors = require "src.consts.colors"

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

function settingsScene:keypressed(key)
    if key == "escape" then
        self.actions.switchScene("title")
    end
end

function settingsScene:update(dt)

end

function settingsScene:draw()
    love.graphics.clear(colors.SLATE_100)
end

return settingsScene
