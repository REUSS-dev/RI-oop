-- Body
local Body = {}



-- documentation

---@alias ColorRGBA {[1]: number, [2]:number, [3]:number, [4]:number}
---@alias pixels number

-- config



-- consts

Body.DEFAULT_COLOR = {255, 255, 255}
Body.DEFAULT_RADIUS = 10

---@enum BodyType Type constants for body types
Body.BodyType = {
    CIRCULAR = "Circular"
}

-- vars



-- init



-- fnc

---Paint circular body
---@param self BodyCircular
---@param x pixels X coordinate position for paint
---@param y pixels Y coordinate position for paint
local function paintCircular(self, x, y)
    love.graphics.setColor(self.color)
    love.graphics.circle(self.fill, x, y, self.radius)
end

-- classes

---@class Body Circular object body class.
---@field bodyType BodyType Shape of a body object
---@field paint fun(self, x: pixels, y: pixels) Body paint virtual function
local body = {}
local Body_meta = {__index = body}

-- Body fnc

---Create new body object
---@param type BodyType
---@param ... any
---@return Body Object
---@overload fun(type: BodyType.CIRCULAR, ...):BodyCircular Create Circular body
function Body.new(type, ...)
    local obj

    if type == Body.BodyType.CIRCULAR then
        ---@class BodyCircular
        ---@field radius radians
        ---@field color ColorRGBA
        obj = {
            bodyType = Body.BodyType.CIRCULAR,
            radius = select(1, ...) or Body.DEFAULT_RADIUS,
            color = select(2, ...) or Body.DEFAULT_COLOR,
            fill = "fill"
        }

        ---Set fill for circle
        ---@param isFilled boolean
        function obj:setFill(isFilled)
            self.fill = isFilled and "fill" or "line"
        end

        obj.paint = paintCircular
    end

    setmetatable(obj, Body_meta)

    ---@cast obj Body
    return obj
end

return Body