local rb = {}

-- v5

--
-- improved version of Corona display.newText
--
--
--
-- v4: restructured to return a rb group object with background & label and now with maxWidth that can be used to align the text without fixing the width
--
--
--


-- get the actual text width (which can be different from the label object if that is with a fixed width)
local getIntrinsicLabelWidth = function(textObj, font) -- todo: try to improve this function by not having to explicit ask for the font type
    local lb = display.newText{text=textObj.text, font=font, fontSize=textObj.size}
    local width = lb.contentWidth
    display.remove(lb)
    --print("getLabelWidth=", width)
    return width
end


-- truncates a label object if its text width is longer than the limit. It appends a "..." in the text if truncated and addThreeDots is set to true
local truncateTextObj = function(textObject, limit, addThreeDots)
    --print("limit=", limit)
    local text = textObject.text
    local textWidth = getIntrinsicLabelWidth(textObject, textObject._options.font)
    local extraWidth = textWidth - limit
    local safeGuard = 1  -- variable to safe guard against infinite loop

    while extraWidth > 1 and safeGuard < 100 do
        --print("a extraWidth=", extraWidth)
        local percentReduction = limit / textWidth
        local totalChars = text:len()
        local charactersToRemove = math.ceil(totalChars * (1-percentReduction) + 3)
        text = text:sub(1,totalChars-charactersToRemove)
        textObject.text = text
        textWidth = getIntrinsicLabelWidth(textObject, textObject._options.font)
        if textWidth == 0 and text:len() > 0 then -- checking if new width is 0. This may happen if we removed 1 byte of a 2-byte unicode char (like "í"), so in that case, remove 1 byte more
            text = text:sub(1,text:len() - 1)
        end
        if addThreeDots then
            text = text .. "..."
        end
        textObject.text = text
        textWidth = getIntrinsicLabelWidth(textObject, textObject._options.font)
        extraWidth = textWidth - limit
        safeGuard = safeGuard + 1
    end
end


-- reduces a label object by decreasing its fontsize until reaches the minFontSize (if specified)
local reduceFontSizeUntil = function(textObject, desiredWidth, minFontSize)
    local safeGuard = 1  -- variable to safe guard against infinite loop
    local extraWidth = getIntrinsicLabelWidth(textObject, textObject._options.font) - desiredWidth
    local reachedMinFontSize = false

    while extraWidth > 1 and safeGuard < 100 and reachedMinFontSize == false do
        --print("b extraWidth=", extraWidth)
        local newFontSize = textObject.size - 1
        if minFontSize and newFontSize < minFontSize then
            reachedMinFontSize = true
        else
            textObject.size = newFontSize
            extraWidth = getIntrinsicLabelWidth(textObject, textObject._options.font) - desiredWidth
            safeGuard = safeGuard + 1
        end
    end
    --print(desiredWidth, extraWidth, textObject.width, textObject.contentWidth, minFontSize)
    return extraWidth > 0, minFontSize
end




rb.new = function(options)

    -- custom text options in addition to normal Corona display.newText options

    local maxWidth = options.maxWidth or options._maxWidth     -- size to which after the text will cut, truncated or go to a new line
    local limitMode = options.limitMode or options._limitMode    -- "cut", "newLine", "fit", "truncate" (will add the '...' to the end)
    local minFontSize = options.minFontSize or options._minFontSize  -- used when user selected the limitMode "fit"
    local color = options.color or options._color
    local backgroundColor = options.backgroundColor or {1,1,1,0}

    local parent = options.parent
    local height = options.height
    local width = options.width
    local left = options.left
    local x = options.x
    local right = options.right
    local top = options.top
    local y = options.y
    local bottom = options.bottom
    local align = options.align




    -- TODO: for the future
    --local _underlineStrokeWidth = options._underlineStrokeWidth
    --local _undelineStrokeColor = options._undelineStrokeColor or options.color

    maxWidth = maxWidth or width

    if maxWidth and limitMode == nil then
        limitMode = "newLine"
    end

    if maxWidth and limitMode == nil then
        error("[rb-display] param 'limitMode' is required when 'maxWidth' is specified in newText")
    end


    if limitMode then
        if limitMode == "newLine" then
            options.width = options.width or options.maxWidth
        else
            --options.width = nil  -- if using limitMode different from 'newLine' or "fit", let's not use the standard width
        end
    end


    local group = display.newGroup()
    group.anchorChildren = true

    group.align = align

    ----------------------------------------
    -- creating the label obj

    local label = display.newText(options)
    label._rawText = options.text
    label._options = options -- storing the options so we can access font and fontSize later if needed
    label._maxWidth = maxWidth

    --print("label.contentWidth=", label.contentWidth)
    if maxWidth then
        local shouldTruncate = (limitMode == "truncate" or limitMode == "cut")
        if limitMode == "fit" then
            shouldTruncate = reduceFontSizeUntil(label, maxWidth, minFontSize)
            --print("shouldTruncate=", shouldTruncate)
            limitMode = "truncate"
        end
        if shouldTruncate or limitMode == "truncate" or limitMode == "cut" then
            truncateTextObj(label, maxWidth, limitMode == "truncate")
        end
    end

    if color then
        label:setTextColor( unpack(color) )
    end

    -- Todo: for the future
    -- if _underlineStrokeWidth then
    --     local lineY = label.y + label.contentHeight*.5
    --     label._underline = display.newLine()
    -- end

    local labelW = label.contentWidth
    local labelH = label.contentHeight


    ----------------------------------------
    -- creating the background obj


    local backgroundW = maxWidth or width or labelW
    local backgroundH = height or label.contentHeight
    local background = display.newRect(group, backgroundW*.5, backgroundH*.5, backgroundW, backgroundH)
    background.fill = backgroundColor
    group.background = background


    ----------------------------------------
    -- aligning the label inside the background

    group:insert(label)
    group.label = label

    local repositionLabel = function(obj)
        if obj.align == "left" then
            obj.label.x = obj.background.x - obj.background.contentWidth*.5 + obj.label.contentWidth*.5
        elseif obj.align == "center" then
            obj.label.x = obj.background.x
        elseif obj.align == "right" then
            obj.label.x = obj.background.x + obj.background.contentWidth*.5 - obj.label.contentWidth*.5
        end
        obj.label.y = obj.background.y
    end

     repositionLabel(group)



    ------------------------------
    -- Public functions

    -- change the label text and also applies the limit constraints
    group.setText = function(obj, newText)
        obj.label.text = newText
        obj.label._rawText = newText
        obj.label.size = options.fontSize


        if obj.label._maxWidth then
            limitMode = options.limitMode
            local shouldTruncate = (limitMode == "truncate" or limitMode == "cut")
            if limitMode == "fit" then
                shouldTruncate = reduceFontSizeUntil(obj.label, obj.label._maxWidth, minFontSize)
                limitMode = "truncate"
            end
            if shouldTruncate or limitMode == "truncate" or limitMode == "cut" then
                truncateTextObj(obj.label, obj.label._maxWidth, limitMode == "truncate")
            end
        end

        repositionLabel(obj)
    end

    -- gets the full, unlimited text
    group.getText = function(obj)
        return obj.label._rawText
    end

    group.setTextColor = function(obj,rOrTable,b,g)
        if type(rOrTable) == "table" then
            obj.label:setTextColor(unpack(rOrTable))
        else
            obj.label:setTextColor(rOrTable,b,g)
        end
    end

    group.getLabelWidth = function(obj)
        return obj.label.contentWidth
    end




    local groupW = group.contentWidth
    local groupH = group.contentHeight

    group.x = x or (left and left + groupW*.5) or (right and right - groupW*.5)
    group.y = y or (top and top + groupH*.5) or (bottom and bottom - groupH*.5)

    if parent then
        parent:insert(group)
    end


    return group

end


return rb