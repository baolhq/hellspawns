local colors = require("src.consts.colors")
local consts = require("src.consts.consts")
local res    = require("src.consts.res")
local file   = require("src.utils.file")

local drawer = {}

function drawer.drawCenteredText(text, font, xOffset, yOffset)
    local textW = font:getWidth(text)
    local textH = font:getHeight(text)
    local x = (consts.WINDOW_WIDTH - textW) / 2 + xOffset
    local y = (consts.WINDOW_HEIGHT - textH) / 2 + yOffset

    love.graphics.print(text, x, y)
end

function drawer.drawButton(btn, font)
    -- Draw background
    if btn.active then
        -- Active button effect
        love.graphics.setColor(colors.SLATE_400)
    else
        love.graphics.setColor(colors.SLATE_200)
    end
    love.graphics.rectangle("fill", btn.x, btn.y, btn.width, btn.height, 4, 4)

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

---Draw main scene overlays
---@param bgHeight number
---@param headerText string
---@param subTexts table
function drawer.drawOverlay(bgHeight, headerText, subTexts)
    love.graphics.setColor(colors.SLATE_800)
    local bgY = (love.graphics.getHeight() - bgHeight) / 2
    love.graphics.rectangle("fill", 0, bgY, consts.WINDOW_WIDTH, bgHeight)

    local headerFont = file:getFont(res.MAIN_FONT, consts.FONT_HEADER_SIZE)
    love.graphics.setColor(colors.SLATE_100)
    drawer.drawCenteredText(headerText, headerFont, 0, subTexts[1].y - 30)

    local subFont = file:getFont(res.MAIN_FONT, consts.FONT_SUB_SIZE)
    love.graphics.setColor(colors.SLATE_300)
    for _, textInfo in ipairs(subTexts) do
        drawer.drawCenteredText(textInfo.text, subFont, 0, textInfo.y)
    end
end

return drawer
