local rb = {}

--v1

rb.new = function(textObject, limit)
    local text = textObject.text
    local extraWidth = textObject.width - limit
    local safeGuard = 1  -- variable to safe guard against infinite loop
    if extraWidth > 1  then
        while extraWidth > 1 and safeGuard < 100 do
            local percentReduction = limit / textObject.width
            local totalChars = text:len()
            local charactersToRemove = math.ceil(totalChars * (1-percentReduction) + 3)
            text = text:sub(1,totalChars-charactersToRemove)
            textObject.text = text
            if textObject.width == 0 and text:len() > 0 then -- checking if new width is 0. This may happen if we removed 1 byte of a 2-byte unicode char (like "í"), so in that case, remove 1 byte more
                text = text:sub(1,text:len() - 1)
            end
            text = text .. "..."
            textObject.text = text
            extraWidth = textObject.width - limit
            safeGuard = safeGuard + 1
        end
    end
end

return rb