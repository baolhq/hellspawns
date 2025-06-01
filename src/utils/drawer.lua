local colors = require("src.consts.colors")

local drawer = {
    screenW = love.graphics.getWidth(),
    screenH = love.graphics.getHeight(),
    fontCache = {}
}

function drawer:drawCenteredText(text, font, xOffset, yOffset)
    local textW = font:getWidth(text)
    local textH = font:getHeight(text)

    local x = (self.screenW - textW) / 2 + xOffset
    local y = (self.screenH - textH) / 2 + yOffset

    love.graphics.print(text, x, y)
end

function drawer:drawButton(btn, font)
    -- Hover effect
    if btn.hovered then
        love.graphics.setColor(colors.SLATE_400)
    else
        love.graphics.setColor(colors.SLATE_200)
    end

    -- Button rectangle
    love.graphics.rectangle("fill", btn.x, btn.y, btn.width, btn.height, 4, 4)

    -- Button outline on focused
    if btn.focused then
        love.graphics.setColor(colors.SLATE_400)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", btn.x, btn.y, btn.width, btn.height, 4, 4)
    end

    -- Button text
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font)
    local textW = font:getWidth(btn.text)
    local textH = font:getHeight(btn.text)
    love.graphics.print(
        btn.text,
        btn.x + (btn.width - textW) / 2,
        btn.y + (btn.height - textH) / 2
    )
end

-- Load font from provided path with fixed size <br/>
-- Also cache them and change to the new font
function drawer:getFont(path, size)
    self.fontCache[path] = self.fontCache[path] or {}

    self.fontCache[path][size] =
        self.fontCache[path][size] or
        love.graphics.newFont(path, size)

    local newFont = self.fontCache[path][size]
    love.graphics.setFont(newFont)

    return newFont
end

return drawer
