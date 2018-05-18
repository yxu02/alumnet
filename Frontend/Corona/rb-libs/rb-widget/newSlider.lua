local rb = {}

------------------------------------------------------------
--  Slider
--
--  v11
---------------------------
-- dependencies:
--
-- none
--
---------------------------
--
-- v6: added enableVerticalMode()
--
--
------------------------------------------------------------


rb.new = function(options)

    -- receiving params
    local parent = options.parent
    local left = options.left
    local x = options.x
    local right = options.right
    local top = options.top
    local y = options.y
    local bottom = options.bottom
    local width = options.width
    local height = options.height or 14

    local minValue = options.minValue or 0
    local maxValue = options.maxValue or 100
    local incrementalValue = options.incrementalValue or 1 -- used to round the values or get discrete changes
    local onChange = options.onChange -- listener called when the user has moved the cursor.


    local cursorImageFile = options.cursorImageFile or options.cursorImageFilename
    local cursorImageBaseDir = options.cursorImageBaseDir or system.ResourceDirectory
    local cursorImageWidth = options.cursorImageWidth
    local cursorImageHeight = options.cursorImageHeight

    local cursorCircleRadius = options.cursorCircleRadius
    local cursorCircleColor = options.cursorCircleColor or {1,1,1}

    local useCursorMiddlePosition = options.useCursorMiddlePosition -- if false or nil, we make the cursor never go outside the background (left cursor will start at the left of the background and it will stop having the right side of cursor at the right side of the background)

    local backgroundColor = options.backgroundColor or {190/255, 190/255, 210/255}
    local backgroundCompletedColor = options.backgroundCompletedColor -- usefull when using the slider as a progress bar



    local group = display.newGroup()
    group.anchorChildren = true


    local background = display.newRect(group, 0,0, width, height)
    background.anchorX = 0
    background:setFillColor( unpack(backgroundColor) )

    local backgroundCompleted
    if backgroundCompletedColor then
        backgroundCompleted = display.newRect(group, 0,0, 0, height)
        backgroundCompleted.anchorX = 0
        backgroundCompleted:setFillColor( unpack(backgroundCompletedColor) )
    end

    local cursor
    if cursorImageFile then
        if cursorImageWidth then
            cursor = display.newImageRect( group, cursorImageFile, cursorImageBaseDir, cursorImageWidth, cursorImageHeight )
        else
            cursor = display.newImage(group, cursorImageFile, cursorImageBaseDir)
        end
    elseif cursorCircleRadius then
        cursor = display.newCircle( group, background.x, background.y, cursorCircleRadius )
    end
    cursor.y = background.y
    cursor.x = background.x
    cursor:setFillColor( unpack(cursorCircleColor) )


    local setCursorPosition = function(percent)
        percent = percent or 0
        if not useCursorMiddlePosition then
            cursor.anchorX = percent/100
        end
        cursor.x = background.width * (percent/100)
    end

    -- reseting the position
    background.y = math.max(background.contentHeight, cursor.contentHeight)*.5
    cursor.y = background.y
    if backgroundCompleted then
        backgroundCompleted.y = background.y
    end

    group.value = 0
    setCursorPosition(group.value)

    local updateValue = function(skipOnChange)

        if backgroundCompleted then
            backgroundCompleted.width = cursor.x -- regardless if rotated or not, we need to change the width position (as if not rotated)
        end

        local total = background.width

        local percent = 100 * (cursor.x / total)

        local newValue = minValue + (maxValue - minValue) * percent/100
        newValue = math.max(newValue, minValue)
        newValue = math.modf(newValue / incrementalValue) * incrementalValue

        group.value = newValue
        if onChange and not skipOnChange then
            onChange({target=group, value=newValue, percent=percent})  --string.format( "$%.2f", newValue)
        end

    end



    local isVertical = false


    local cursorListener = function(event)

        local phase = event.phase
        if ( event.phase == "began" ) then
                display.getCurrentStage():setFocus( event.target )
                group._isFocus = true


        elseif ( group._isFocus ) then
            if ( event.phase == "moved" ) then
                local percentProgress
                if isVertical then
                    local backgroundContentTop = background.contentBounds.yMin --background:localToContent( 0,- background.contentHeight*.5 )
                    local newY = math.min(backgroundContentTop + background.contentHeight, event.y ) -- limits to not go beyond total
                    newY = math.max(newY, backgroundContentTop) -- limits to not go negative

                    percentProgress = 100 * (newY - backgroundContentTop) / background.width
                    --cursor.x = y - backgroundContentTop  -- although rotated, we need to change the X position (as if not rotated)

                else
                    local backgroundContentLeft = background.contentBounds.xMin --background:localToContent( - background.contentWidth*.5,0 )
                    local newX = math.min(backgroundContentLeft + background.contentWidth,event.x) -- limits to not go beyond total
                    newX = math.max(newX, backgroundContentLeft)  -- limits to not go negative

                    percentProgress = 100 * (newX - backgroundContentLeft) / background.width

                    --cursor.x = x - backgroundContentLeft
                end
                setCursorPosition(percentProgress)
                updateValue()

            elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
                display.getCurrentStage():setFocus( nil )
                group._isFocus = false
            end
        end

        return true

    end
    cursor:addEventListener( "touch", cursorListener )


    -- sets a new value (value is between [minValue - maxValue])
    group.setValue = function(newValue)
        if newValue > maxValue then print( "[rb-slider] new value is greater than maxValue. Using maxValue instead." ); newValue = maxValue end
        if newValue < minValue then print( "[rb-slider] new value is smaller than minValue. Using minValue instead." ); newValue = minValue  end
        local delta = (newValue - minValue)
        print(delta)
        group.setProgress(100*delta/(maxValue - minValue))
    end

    group.getValue = function()
        return group.value
    end

    -- sets progress in percent value (e.g: 30  for  30%)
    group.setProgress = function(percent, skipOnChange) -- skipOnChange makes the onChange listener to not be called
        if group._isFocus then print("[rb-slider] user is holding the cursor. Cannot update progress right now"); return end
        -- local newX = background.width*percent/100
        -- cursor.x = newX
        setCursorPosition(percent)
        updateValue(skipOnChange)
    end

    group.getProgress = function()
        return (100 * cursor.x / background.width)
    end

    group.enableVerticalMode = function(isVrtcl) -- if this slider is rotated (or belonged to a group that is rotated, call this to enable the vertical mode)
        isVertical = isVrtcl
    end


    group.x = x or (left and (left + group.contentWidth*.5)) or (right and (right - group.contentWidth*.5))
    group.y = y or (top and (top + group.contentHeight*.5)) or (bottom and (bottom - group.contentHeight*.5))


    if parent then
        parent:insert(group)
    end

    return group
end

return rb



--[[


local slider = rbw.newSlider{
    x = display.contentCenterX,
    y = display.contentCenterY,
    width = 300,
    height = 40,
    cursorCircleRadius = 30,
    backgroundColor = {1,0,1},
    backgroundCompletedColor = {1,1,1},
    onChange = function(e)
        print("on change=", e.value)
    end

}

local i=0
timer.performWithDelay(1000, function()
    i=i+1
    slider.setProgress(i)
end,10)


]]

