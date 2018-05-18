local rb = {}

---------------------------------------------------------------
-- Increases the value of a number linearly to the device width
--
-- v4
--
------

rb.new = function( minValue , maxValue )
    maxValue = maxValue or 2*minValue
    local a = (maxValue - minValue) / (375 - 320)
    local value = a * _G.SCREEN_W + maxValue - a * 375
    value = math.min( value , maxValue)

    return value
end

return rb