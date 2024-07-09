---@diagnostic disable: duplicate-set-field
local qgui, locale

local hintFont = love.graphics.newFont("font.ttf", 15)

local currentHint = 0
local currentHintedObject

function love.load()
    math.randomseed(os.time())

    qgui = require("scripts.QGUI")
    locale = require("scripts.locale")
    G_world = require("classes.World")

    G_world = G_world.new(love.graphics.getWidth(), love.graphics.getHeight(), 1000, "yes")

    require("scripts.swarmMenuLayout")

    qgui.hook()
end

function love.update(dt)
    if qgui.getValue("menuButtonSpeed") then
        local dt = dt

        if qgui.getValue("menuButtonStabilization") then
            dt = 0.01
        end

        G_world:tick(dt*math.floor(qgui.getValue("menuSwitchSpeed"))/10)
    end

    if currentHint ~= qgui.hl then
        local name = (qgui.queue[qgui.hl] or {}).name
        qgui.remove("hintPanel")

        if locale[name] then
            currentHintedObject = name

            local _, wrappedtext = hintFont:getWrap(locale[name], 280)

            qgui.new{
                "hintPanel",
                "screen",
                fill = true,
                w = 300,
                h = 20 + #wrappedtext*hintFont:getHeight(),
                x = love.graphics.getWidth() - 610,
                y = 70,
                color = {0, 0.25, 0, 0.75}
            }

            local oldDraw = qgui.getObject("hintPanel").draw
            qgui.getObject("hintPanel").draw = function ()
                oldDraw()

                love.graphics.setFont(hintFont)
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.printf(locale[currentHintedObject] or "", love.graphics.getWidth() - 600, 80, 280, "left")
            end
        else
            currentHintedObject = nil
        end

        currentHint = qgui.hl
    end

    if G_world.screamsEnabled ~= qgui.getValue("menuButtonRange") then
        G_world:setScreamEnabled(qgui.getValue("menuButtonRange"))
    end
end

function love.draw()
    G_world:paint()
end

function love.keypressed(key)
    if key == "space" then
        qgui.getObject("menuButtonSpeed").check = not qgui.getObject("menuButtonSpeed").check
    end
end