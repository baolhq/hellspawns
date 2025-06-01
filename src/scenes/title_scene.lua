local colors = require("src.consts.colors")
local consts = require("src.consts.consts")
local res = require("src.consts.res")
local drawer = require("src.utils.drawer")

local titleScene = {
    assets = {},
    actions = {},
    configs = {},
}

local focusedIndex = 1
local buttonOrder = { "start", "settings" }
local buttons = {
    start = {
        x = 0,
        y = 0,
        width = 200,
        height = 40,
        text = "START",
        focused = true,
        hovered = false,
    },
    settings = {
        x = 0,
        y = 0,
        width = 200,
        height = 40,
        text = "SETTINGS",
        focused = false,
        hovered = false,
    }
}

function titleScene:load(assets, actions, configs)
    self.assets = assets
    self.actions = actions
    self.configs = configs

    local spacingY = 48
    buttons.start.x = (love.graphics.getWidth() - buttons.start.width) / 2
    buttons.start.y = (love.graphics.getHeight() - buttons.start.height) / 2 + 28
    buttons.settings.x = buttons.start.x
    buttons.settings.y = buttons.start.y + spacingY
end

function titleScene:keypressed(key)
    if key == "escape" then self.actions.quit() end
end

function titleScene:mousepressed(x, y, btn)
    self.assets.clickSound:play()
    for _, b in pairs(buttons) do
        b.focused = false
    end

    if btn == 1 and buttons.start.hovered then
        buttons.start.focused = true
        self.actions.switchScene("main")
    elseif btn == 1 and buttons.settings.hovered then
        buttons.settings.focused = true
        self.actions.switchScene("settings")
    end
end

function titleScene:update(dt)
    local mx, my = love.mouse.getPosition()

    for _, name in ipairs(buttonOrder) do
        local btn = buttons[name]
        btn.hovered =
            mx > btn.x and mx < btn.x + btn.width and
            my > btn.y and my < btn.y + btn.height
    end
end

function titleScene:draw()
    love.graphics.clear(colors.SLATE_100)

    local font = drawer:getFont(res.MAIN_FONT, consts.FONT_TITLE_SIZE)
    drawer:drawCenteredText(consts.GAME_TITLE, font, 0, -68)

    font = drawer:getFont(res.MAIN_FONT, consts.FONT_SUB_SIZE)
    drawer:drawButton(buttons.start, font)
    drawer:drawButton(buttons.settings, font)
end

return titleScene
