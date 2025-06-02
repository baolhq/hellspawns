local inputManager = require("src.managers.input_manager")
local colors       = require("src.consts.colors")
local consts       = require("src.consts.consts")
local res          = require("src.consts.res")
local drawer       = require("src.utils.drawer")

local titleScene   = {
    assets = {},
    actions = {},
    configs = {},
}

local focusedIndex = 1
local buttonOrder  = { "start", "settings" }
local buttons      = {
    start = {
        x = 0,
        y = 0,
        width = 200,
        height = 40,
        text = "START",
        active = true,
    },
    settings = {
        x = 0,
        y = 0,
        width = 200,
        height = 40,
        text = "SETTINGS",
        active = false,
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

function titleScene:mousepressed(x, y, btn)
    self.assets.clickSound:play()
    for _, b in pairs(buttons) do
        b.focused = false
    end

    if btn == 1 and buttons.start.hovered then
        buttons.start.active = true
        self.actions.switchScene("main")
    elseif btn == 1 and buttons.settings.hovered then
        buttons.settings.active = true
        self.actions.switchScene("settings")
    end
end

function titleScene:handleInputs()
    if inputManager:wasPressed("back") then
        self.actions.quit()
    end

    if inputManager:wasPressed("accept") then
        if buttons.start.active then
            self.actions.switchScene("main")
        else
            self.actions.switchScene("settings")
        end
    end

    if inputManager:wasPressed("tab") or
        inputManager:wasPressed("down")
    then
        for _, b in pairs(buttons) do b.active = false end
        focusedIndex = (focusedIndex - 2) % #buttonOrder + 1
    elseif inputManager:wasPressed("up") then
        for _, b in pairs(buttons) do b.active = false end
        focusedIndex = focusedIndex % #buttonOrder + 1
    end
    buttons[buttonOrder[focusedIndex]].active = true
end

function titleScene:update(dt)
    self:handleInputs()

    local mx, my = love.mouse.getPosition()
    for _, btn in pairs(buttons) do
        if mx > btn.x and mx < btn.x + btn.width and
            my > btn.y and my < btn.y + btn.height
        then
            for _, b in pairs(buttons) do b.active = false end
            btn.active = true
        end
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
