local qgui = require("scripts.QGUI")
local drone = require("classes.Drone")

local font = love.graphics.newFont("font.ttf")
local font16 = love.graphics.newFont("font.ttf", 16)

-- config

local PANEL_WIDTH = 300
local SHIFT_DISTANCE = 300

local MAX_DESTINATIONS = 5

local moveTable = {
    "showMenu", 
    "menuPanel", 
    "menuLabel", 
    "menuLabelParameters", 
    "menuButtonRepopulate", 
    "menuLabelSpeed", 
    "menuSwitchSpeed", 
    "menuButtonSpeed", 
    "menuLabelCount", 
    "menuSwitchCount", 
    "menuSwitchDroneSpeed", 
    "menuLabelDroneSpeed", 
    "menuSwitchDroneRange", 
    "menuLabelDroneRange", 
    "menuLabelDroneFluctuation", 
    "menuSwitchDroneFluctuation", 
    "menuLabelDestinationSpeed", 
    "menuSwitchDestinationSpeed",
    "menuButtonRange",
    "menuButtonBaseAdd",
    "menuButtonBaseRemove",
    "menuLabelBase",
    "menuButtonResourceAdd",
    "menuButtonResourceRemove",
    "menuLabelResource",
    "menuLabelVisual",
    "menuLabelStabilization",
    "menuButtonStabilization",
    "menuLabelShowConnection",
    "menuButtonShowConnection",
    "menuLabelShowDrone",
    "menuButtonShowDrone",
    "menuLabelShowObject",
    "menuButtonShowObject",
    "menuLabelShowRadius",
    "menuButtonShowRadius",
    "menuLabelShowAngle",
    "menuButtonShowAngle",
}

-- vars
local menushown = false

-- Show/hide Menu button
local function shiftEverything(amount)
    for _, objectName in pairs(moveTable) do
        local object = qgui.getObject(objectName)

        object.x = object.x + amount
    end
end

local function activateMenu()
    local buttonObject = qgui.getObject("showMenu")

    menushown = not menushown

    shiftEverything(SHIFT_DISTANCE * (menushown and -1 or 1))
    buttonObject.text = menushown and ">>" or "<<"
end

qgui.new{
    "showMenu",
    "button",
    fill = true,
    w = 50,
    h = 50,
    x = love.graphics.getWidth() - 50 - 10,
    y = 10,
    text = "<<",
    font = font,
    fnc = activateMenu
}

-- Menu main panel
qgui.new{
    "menuPanel",
    "screen",
    fill = true,
    w = PANEL_WIDTH,
    h = love.graphics.getHeight(),
    x = love.graphics.getWidth(),
    y = 0,
    color = {0, 0.5, 0, 0.25}
}

-- Menu label text
qgui.new{
    "menuLabel",
    "onelineText",
    fill = true,
    w = 290,
    x = love.graphics.getWidth() + 5,
    y = 10,
    font = font16,
    text = "Панель управления симуляцией",
    frame = {0, 0.5, 0, 0.5},
}

-- "simulation parameters" text
qgui.new{
    "menuLabelParameters",
    "onelineText",
    fill = true,
    w = 290,
    x = love.graphics.getWidth() + 5,
    y = 60,
    font = font16,
    text = "Параметры симуляции",
    align = "left"
}

-- simulation speed label
local textBase = "Скорость симуляции: "
qgui.new{
    "menuLabelSpeed",
    "onelineText",
    fill = true,
    w = 290,
    x = love.graphics.getWidth() + 5,
    y = 90,
    font = font,
    text = "Скорость симуляции: 1x",
    align = "left"
}

-- simulation speed switch
qgui.new{
    "menuSwitchSpeed",
    "softSwitch",
    w = 250,
    x = love.graphics.getWidth() + 5 + 30,
    y = 110,
    color = {0, 0.25, 0, 0.25},
    switchColor = {0, 0.25, 0, 1},
    switchFrameColor = {0, 0.5, 0, 1},
    current = 0.5,
    cursor = "sizewe",
    max = 20
}
local switchObjectSpeed = qgui.getObject("menuSwitchSpeed")
local labelObjectSpeed = qgui.getObject("menuLabelSpeed")

local oldHold = switchObjectSpeed.upd
function switchObjectSpeed.upd(obj,i,x,y,dt)
    local multiplier = math.floor(obj.current*20)/10
    if qgui.getValue("menuButtonSpeed") then
        labelObjectSpeed.text = textBase .. multiplier .."x"
    else
        labelObjectSpeed.text = textBase .. "Пауза"
    end
    oldHold(obj,i,x,y,dt)
end

--simulation pause/start
qgui.new{
    "menuButtonSpeed",
    "checkBox",
    check = true,
    w = 15,
    h = 15,
    x = love.graphics.getWidth() + 10,
    y = 110,
    color={0, 0.5, 0, 1}
}

-- drones count label
local textBase = "Количество агентов: "
qgui.new{
    "menuLabelCount",
    "onelineText",
    fill = true,
    w = 290,
    x = love.graphics.getWidth() + 5,
    y = 140,
    font = font,
    text = "Количество агентов: ",
    align = "left"
}

-- drones count switch
qgui.new{
    "menuSwitchCount",
    "softSwitch",
    w = 250,
    x = love.graphics.getWidth() + 5 + 30,
    y = 160,
    color = {0, 0.25, 0, 0.25},
    switchColor = {0, 0.25, 0, 1},
    switchFrameColor = {0, 0.5, 0, 1},
    current = 0.5,
    cursor = "sizewe"
}
local switchObjectCount = qgui.getObject("menuSwitchCount")
local labelObjectCount = qgui.getObject("menuLabelCount")

local oldHold = switchObjectCount.upd
function switchObjectCount.upd(obj,i,x,y,dt)
    local drones = math.floor(obj.current * 2000)

    labelObjectCount.text = textBase .. drones

    G_world:setDroneCount(drones)

    oldHold(obj,i,x,y,dt)
end

--repopulate world button
qgui.new{
    "menuButtonRepopulate",
    "button",
    w = 15,
    h = 15,
    x = love.graphics.getWidth() + 10,
    y = 160,
    color={0.5, 0.5, 1, 1},
    text = "!",
    fill = true,
    fnc = function ()
        G_world:repopulate()
    end
}

-- drones Speed label
local textBase = "Скорость агентов: "
qgui.new{
    "menuLabelDroneSpeed",
    "onelineText",
    fill = true,
    w = 290,
    x = love.graphics.getWidth() + 5,
    y = 190,
    font = font,
    text = "Скорость агентов: 1х",
    align = "left"
}

-- drones Speed switch
qgui.new{
    "menuSwitchDroneSpeed",
    "softSwitch",
    w = 250,
    x = love.graphics.getWidth() + 5 + 30,
    y = 210,
    color = {0, 0.25, 0, 0.25},
    switchColor = {0, 0.25, 0, 1},
    switchFrameColor = {0, 0.5, 0, 1},
    current = 0.5,
    cursor = "sizewe"
}
local switchObjectSpeed = qgui.getObject("menuSwitchDroneSpeed")
local labelObjectSpeed = qgui.getObject("menuLabelDroneSpeed")
local oldSpd = 1

local oldHold = switchObjectSpeed.upd
function switchObjectSpeed.upd(obj,i,x,y,dt)
    local spd = math.floor(obj.current * 20)/10

    if oldSpd ~= spd then
        labelObjectSpeed.text = textBase .. spd .."x"
        G_world:setDroneSpeedMultiplier(spd)
        
        oldSpd = spd
    end

    oldHold(obj,i,x,y,dt)
end

-- drones Range label
local textBase = "Радиус крика агентов: "
qgui.new{
    "menuLabelDroneRange",
    "onelineText",
    fill = true,
    w = 290,
    x = love.graphics.getWidth() + 5,
    y = 240,
    font = font,
    text = "Радиус крика агентов: 1х",
    align = "left"
}

-- drones Range switch
qgui.new{
    "menuSwitchDroneRange",
    "softSwitch",
    w = 250,
    x = love.graphics.getWidth() + 5 + 30,
    y = 260,
    color = {0, 0.25, 0, 0.25},
    switchColor = {0, 0.25, 0, 1},
    switchFrameColor = {0, 0.5, 0, 1},
    current = 0.5,
    cursor = "sizewe"
}
local switchObjectRange = qgui.getObject("menuSwitchDroneRange")
local labelObjectRange = qgui.getObject("menuLabelDroneRange")
local oldRng = 1

local oldHold = switchObjectRange.upd
function switchObjectRange.upd(obj,i,x,y,dt)
    local Rng = math.floor(obj.current * 20)/10

    if oldRng ~= Rng then
        labelObjectRange.text = textBase .. Rng .."x"
        drone.setScreamRadiusMultiplier(Rng)
        
        oldRng = Rng
    end

    oldHold(obj,i,x,y,dt)
end

--drone scream enable/disable
qgui.new{
    "menuButtonRange",
    "checkBox",
    check = true,
    w = 15,
    h = 15,
    x = love.graphics.getWidth() + 10,
    y = 260,
    color={0, 0.5, 0, 1}
}

-- drones Fluctuation label
local textBase = "Флуктуации угла движения агентов: "
qgui.new{
    "menuLabelDroneFluctuation",
    "onelineText",
    fill = true,
    w = 290,
    x = love.graphics.getWidth() + 5,
    y = 290,
    font = font,
    text = "Флуктуации угла движения агентов: 1х",
    align = "left"
}

-- drones Fluctuation switch
qgui.new{
    "menuSwitchDroneFluctuation",
    "softSwitch",
    w = 250,
    x = love.graphics.getWidth() + 5 + 30,
    y = 310,
    color = {0, 0.25, 0, 0.25},
    switchColor = {0, 0.25, 0, 1},
    switchFrameColor = {0, 0.5, 0, 1},
    current = 0.5,
    cursor = "sizewe"
}
local switchObjectFluctuation = qgui.getObject("menuSwitchDroneFluctuation")
local labelObjectFluctuation = qgui.getObject("menuLabelDroneFluctuation")
local oldFluct = 1

local oldHold = switchObjectFluctuation.upd
function switchObjectFluctuation.upd(obj,i,x,y,dt)
    local Fluct = math.floor(obj.current * 20)/10

    if oldFluct ~= Fluct then
        labelObjectFluctuation.text = textBase .. Fluct .."x"
        drone.setAngleFluctuationMultiplier(Fluct)
        
        oldFluct = Fluct
    end

    oldHold(obj,i,x,y,dt)
end

-- Destination Speed label
local textBase = "Скорость пунктов назначения: "
qgui.new{
    "menuLabelDestinationSpeed",
    "onelineText",
    fill = true,
    w = 290,
    x = love.graphics.getWidth() + 5,
    y = 340,
    font = font,
    text = "Скорость пунктов назначения: 1х",
    align = "left"
}

-- Destinations Speed switch
qgui.new{
    "menuSwitchDestinationSpeed",
    "softSwitch",
    w = 250,
    x = love.graphics.getWidth() + 5 + 30,
    y = 360,
    color = {0, 0.25, 0, 0.25},
    switchColor = {0, 0.25, 0, 1},
    switchFrameColor = {0, 0.5, 0, 1},
    current = 0.5,
    cursor = "sizewe"
}
local switchObjectSpeed = qgui.getObject("menuSwitchDestinationSpeed")
local labelObjectSpeed = qgui.getObject("menuLabelDestinationSpeed")
local oldSpeed = 1

local oldHold = switchObjectSpeed.upd
function switchObjectSpeed.upd(obj,i,x,y,dt)
    local Speed = math.floor(obj.current * 20)/10

    if oldSpeed ~= Speed then
        labelObjectSpeed.text = textBase .. Speed .."x"
        G_world:setDestinationSpeedMultiplier(Speed)
        
        oldSpeed = Speed
    end

    oldHold(obj,i,x,y,dt)
end

-- bases count label
local textBase = "Количество баз: "
local basesCount = 1
qgui.new{
    "menuLabelBase",
    "onelineText",
    fill = true,
    w = 290,
    x = love.graphics.getWidth() + 10 + 25 + 25 + 5,
    y = 390,
    font = font16,
    text = "Количество баз: 1",
    align = "left"
}

--bases count plus
qgui.new{
    "menuButtonBaseAdd",
    "button",
    w = 20,
    h = 20,
    x = love.graphics.getWidth() + 10,
    y = 390,
    color={0, 0.75, 0, 1},
    text = "+",
    fill = true,
    fnc = function ()
        if basesCount < MAX_DESTINATIONS then
            basesCount = basesCount + 1
            G_world:placeBase(math.random(0, G_world.width), math.random(0, G_world.height))
            qgui.getObject("menuLabelBase").text = textBase .. basesCount
        end
    end,
    font = font
}

--bases count minus
qgui.new{
    "menuButtonBaseRemove",
    "button",
    w = 20,
    h = 20,
    x = love.graphics.getWidth() + 10 + 25,
    y = 390,
    color={0.75, 0, 0, 1},
    text = "-",
    font = font,
    fill = true,
    fnc = function ()
        if basesCount > 0 then
            basesCount = basesCount - 1
            G_world:removeBase()
            qgui.getObject("menuLabelBase").text = textBase .. basesCount
        end
    end
}

-- resource count label
local textBase = "Количество ресурсов: "
local resourceCount = 1
qgui.new{
    "menuLabelResource",
    "onelineText",
    fill = true,
    w = 290,
    x = love.graphics.getWidth() + 10 + 25 + 25 + 5,
    y = 420,
    font = font16,
    text = "Количество ресурсов: 1",
    align = "left"
}

--resource count plus
qgui.new{
    "menuButtonResourceAdd",
    "button",
    w = 20,
    h = 20,
    x = love.graphics.getWidth() + 10,
    y = 420,
    color={0, 0.75, 0, 1},
    text = "+",
    fill = true,
    fnc = function ()
        if resourceCount < MAX_DESTINATIONS then
            resourceCount = resourceCount + 1
            G_world:placeResource(math.random(0, G_world.width), math.random(0, G_world.height))
            qgui.getObject("menuLabelResource").text = textBase .. resourceCount
        end
    end,
    font = font
}

--resource count minus
qgui.new{
    "menuButtonResourceRemove",
    "button",
    w = 20,
    h = 20,
    x = love.graphics.getWidth() + 10 + 25,
    y = 420,
    color={0.75, 0, 0, 1},
    text = "-",
    font = font,
    fill = true,
    fnc = function ()
        if resourceCount > 0 then
            resourceCount = resourceCount - 1
            G_world:removeResource()
            qgui.getObject("menuLabelResource").text = textBase .. resourceCount
        end
    end
}

-- world stabilization label
qgui.new{
    "menuLabelStabilization",
    "onelineText",
    fill = true,
    w = 290,
    x = love.graphics.getWidth() + 25 + 25 + 25,
    y = 460,
    font = font16,
    text = "Стабилизация мира",
    align = "left"
}

--world stabilization check
qgui.new{
    "menuButtonStabilization",
    "checkBox",
    w = 20,
    h = 20,
    x = love.graphics.getWidth() + 20 + 25,
    y = 460,
    color={0, 0.75, 0, 1},
}

-- "visual settings" text
qgui.new{
    "menuLabelVisual",
    "onelineText",
    fill = true,
    w = 290,
    x = love.graphics.getWidth() + 5,
    y = 500,
    font = font16,
    text = "Визуальные настройки",
    align = "left"
}

-- show connections label
qgui.new{
    "menuLabelShowConnection",
    "onelineText",
    fill = true,
    w = 290,
    x = love.graphics.getWidth() + 25 + 25,
    y = 530,
    font = font16,
    text = "Отображать связи",
    align = "left"
}

--show connections check
qgui.new{
    "menuButtonShowConnection",
    "checkBox",
    w = 20,
    h = 20,
    x = love.graphics.getWidth() + 20,
    y = 530,
    check = true,
    color={0, 0.75, 0, 1},
}
local obj = qgui.getObject("menuButtonShowConnection")
local oldClick = obj.fncRelease
function obj.fncRelease(objr, x, y, but)
    oldClick(objr, x, y, but)
    G_world:setShowConnections(obj.check)
end

-- show drones label
qgui.new{
    "menuLabelShowDrone",
    "onelineText",
    fill = true,
    w = 290,
    x = love.graphics.getWidth() + 25 + 25,
    y = 560,
    font = font16,
    text = "Отображать агентов",
    align = "left"
}

--show drones check
qgui.new{
    "menuButtonShowDrone",
    "checkBox",
    w = 20,
    h = 20,
    x = love.graphics.getWidth() + 20,
    y = 560,
    check = true,
    color={0, 0.75, 0, 1},
}
local obj = qgui.getObject("menuButtonShowDrone")
local oldClick = obj.fncRelease
function obj.fncRelease(objr, x, y, but)
    oldClick(objr, x, y, but)
    G_world:setShowDrones(obj.check)
end

-- show objects label
qgui.new{
    "menuLabelShowObject",
    "onelineText",
    fill = true,
    w = 290,
    x = love.graphics.getWidth() + 25 + 25,
    y = 590,
    font = font16,
    text = "Отображать п. назначения",
    align = "left"
}

--show objects check
qgui.new{
    "menuButtonShowObject",
    "checkBox",
    w = 20,
    h = 20,
    x = love.graphics.getWidth() + 20,
    y = 590,
    check = true,
    color={0, 0.75, 0, 1},
}
local obj = qgui.getObject("menuButtonShowObject")
local oldClick = obj.fncRelease
function obj.fncRelease(objr, x, y, but)
    oldClick(objr, x, y, but)
    G_world:setShowObjects(obj.check)
end

-- show radius label
qgui.new{
    "menuLabelShowRadius",
    "onelineText",
    fill = true,
    w = 290,
    x = love.graphics.getWidth() + 25 + 25,
    y = 620,
    font = font16,
    text = "Отображать радиус крика",
    align = "left"
}

--show radius check
qgui.new{
    "menuButtonShowRadius",
    "checkBox",
    w = 20,
    h = 20,
    x = love.graphics.getWidth() + 20,
    y = 620,
    check = false,
    color={0, 0.75, 0, 1},
}
local obj = qgui.getObject("menuButtonShowRadius")
local oldClick = obj.fncRelease
function obj.fncRelease(objr, x, y, but)
    oldClick(objr, x, y, but)
    G_world:setShowRadius(obj.check)
end

-- show Angle label
qgui.new{
    "menuLabelShowAngle",
    "onelineText",
    fill = true,
    w = 290,
    x = love.graphics.getWidth() + 25 + 25,
    y = 650,
    font = font16,
    text = "Отображать напр. агентов",
    align = "left"
}

--show Angle check
qgui.new{
    "menuButtonShowAngle",
    "checkBox",
    w = 20,
    h = 20,
    x = love.graphics.getWidth() + 20,
    y = 650,
    check = false,
    color={0, 0.75, 0, 1},
}
local obj = qgui.getObject("menuButtonShowAngle")
local oldClick = obj.fncRelease
function obj.fncRelease(objr, x, y, but)
    oldClick(objr, x, y, but)
    drone.setShowDroneDirections(obj.check)
end