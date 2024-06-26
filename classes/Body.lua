-- Body
local Body = {}



-- documentation



-- config



-- consts

Body.DEFAULT_COLOR = {255, 255, 255}
Body.DEFAULT_RADIUS = 10

---@enum BodyType
Body.BodyType = {
    CIRCULAR = "Circular"
}

-- vars



-- init



-- fnc



-- classes

---@class Body Circular object body class.
---@field bodyType BodyType
local body = {}
local Body_meta = {__index = body}

-- Body fnc

---Create new body object
---@param type BodyType
---@param ... any
---@return Body
function Body.new(type, ...)
    local obj

    if type == Body.BodyType.CIRCULAR then
        ---@class BodyCircular
        obj = {
            bodyType = Body.Bodytype.CIRCULAR,
            radius = select(1, ...) or Body.DEFAULT_RADIUS,
            color = select(2, ...) or Body.DEFAULT_COLOR
        }
    end

    setmetatable(obj, Body_meta)

    ---@cast obj Body
    return obj
end

return Body