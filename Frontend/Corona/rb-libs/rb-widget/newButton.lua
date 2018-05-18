local rb = {}

------------------------------------------------------------
-- New Button
--
--  v30
--
-- v30: fixed labePadding left/right not working
-- v29: added imageDisabled and imageDisabledColor
-- v28: added onImageDownloadComplete (from rb-display.loadImageFromInternet dependency)
-- v27: added imageURL (uses rb-display.loadImageFromInternet dependency)
-- v26 (initializing button.isEnabled = false; fixed reduceFontSizeToFitLabel, added support to horizontal scrollViewParent; added toggleMode, backgroundStrokeDisabledColor, added support to button without label and image, added check for SV == nil, added error message or imageWith,imageHeight; added imageFilename option, alignX, alignY, added change status on tap, added imageBaseDir, fixed tap propagation, setEnabled, getLabel, setLabel,added cornerRadius, updated view.x position; fixed tableview getting focus)
--
--
------------------------------------------------------------


rb.new = function(options)

    local id = options.id

    -- button position
    local top = options.top
    local y = options.y
    local bottom = options.bottom
    local left = options.left
    local x = options.x
    local right = options.right
    local rotation = options.rotation


    -- button background
    local width = options.width or 0
    local height = options.height or 0

    local backgroundColor = options.backgroundColor or {1,1,1,0}
    local backgroundOverColor = options.backgroundOverColor
    local backgroundDisabledColor = options.backgroundDisabledColor or {.3,.3,.3}

    local backgroundStrokeWidth = options.backgroundStrokeWidth or 0
    local backgroundStrokeColor = options.backgroundStrokeColor or {0,0,0,0}
    local backgroundStrokeOverColor = options.backgroundStrokeOverColor or {0,0,0,0}
    local backgroundStrokeDisabledColor = options.backgroundStrokeDisabledColor

    local cornerRadius = options.cornerRadius
    local alignX = options.align or options.alignX or options.alignHorizontal or "center" -- "left", "center", "right"
    local alignY = options.alignY or options.alignVertical or "center" -- "top", "center", "bottom"




    -- button label
    local labelString = options.label
    local labelFont = options.labelFont or native.systemFont
    local labelFontSize = options.labelFontSize or 12
    local labelColor = options.labelColor or { 1,1,1 }
    local labelOverColor = options.labelOverColor or { 1,1,1 }
    local labelPadding = options.labelPadding or {left=0, top=0, bottom=0, right=0}
    local labelTruncate = options.labelTruncate or false
    local labelAlign = options.labelAlign or "left"
    local labelWrap = options.labelWrap or (labelAlign ~= "left") or false
    local labelLineSpacing = options.labelLineSpacing
    local labelVerticalPosition = options.labelVerticalPosition or options.labelVerticalPos or "center"  -- "bottom", "center", "top"
    local labelWidth = options.labelWidth

    local labelDisabledColor = options.labelDisabledColor or options.labelColor

    local reduceFontSizeToFitLabel = options.reduceFontSizeToFitLabel
    local _limitMode = options._limitMode
    local _maxWidth = options._maxWidth

    -- button image
    local imageURL = options.imageURL
    local onImageDownloadComplete = options.onImageDownloadComplete
    local imageBaseDir = options.imageBaseDir or system.ResourceDirectory
    local imageFile = options.imageFile or options.imageFilename
    local imageOverFile = options.imageOverFile
    local imageDisabledFile = options.imageDisabledFile

    local imageColor = options.imageColor
    local imageOverColor = options.imageOverColor
    local imageDisabledColor = options.imageDisabledColor

    local imageWidth = options.imageWidth
    local imageHeight = options.imageHeight
    local imagePadding = options.imagePadding or {left=0, top=0, bottom=0, right=0}
    local imagePosition = options.imagePosition or options.imagePos or "left"  --  in relation to the label. Possible values: "left", "right", "center", "top", "bottom"
    local imageScaleX = options.imageScaleX or 1
    local imageScaleY = options.imageScaleY or 1
    local imageRotation = options.imageRotation or 0

    local imageDisabledColor = options.imageDisabledColor or options.imageColor

    local independentPositions = options.independentPositions or false  -- if true makes the image and label position independent from each other

    -- listener
    local onRelease = options.onRelease
    local onEvent = options.onEvent
    local onTap = options.onTap

    -- extra
    local keepPressed = options.keepPressed -- this disables the over effect and leaves the button pressed
    local scrollViewObj = options.scrollViewParent or options.scrollViewObj -- used to give focus to scrollView
    local toggleMode = options.toggleMode

    if toggleMode then
       keepPressed =  toggleMode
    end

    -- making sure table values have all values filled out
    labelPadding.left = labelPadding.left or 0
    labelPadding.right = labelPadding.right or 0
    labelPadding.top = labelPadding.top or 0
    labelPadding.bottom = labelPadding.bottom or 0

    imagePadding.left = imagePadding.left or 0
    imagePadding.right = imagePadding.right or 0
    imagePadding.top = imagePadding.top or 0
    imagePadding.bottom = imagePadding.bottom or 0




    local button = display.newGroup()   -- button group
    button.anchorChildren = true
    button.isEnabled = true
    button.isPressed = false

    button.id = id



    local image = nil
    local imageOver = nil
    local imageDisabled = nil
    local label = nil


    local view = display.newGroup()     -- group that hold the label and image

    -- sets the appropriatecolor accordingly to the button status
    local function setStatus(isPressed)

        if isPressed == button.isPressed then return end

        local newBackgroundColor = backgroundColor
        local newBackgroundStrokeColor = backgroundStrokeColor
        local newLabelColor = labelColor
        local newImageColor = imageColor


        if isPressed then
            newBackgroundColor = backgroundOverColor
            newBackgroundStrokeColor = backgroundStrokeOverColor
            newLabelColor = labelOverColor
            newImageColor = imageOverColor
        end

        if newBackgroundColor and button.background then
            button.background:setFillColor( unpack(newBackgroundColor) )
        end
        if newLabelColor and button.label then
            button.label:setTextColor( unpack(newLabelColor) )
        end
        if newImageColor and button.image then
            button.image:setFillColor( unpack(newImageColor) )
        end
        if backgroundStrokeOverColor then
            button.background:setStrokeColor( unpack(newBackgroundStrokeColor) )
        end
        if button.imageOver then
            button.image.isVisible = not isPressed
            button.imageOver.isVisible = isPressed
        end


        button.isPressed = isPressed
    end



    -- creating the objects

    -- loads the image
    local scaleFactor = 1
    if imageURL then
        local rbd = require("rb-libs.rb-display")
        image = rbd.loadImageFromInternet{
            imageURL = imageURL,
            imageWidth = imageWidth,
            imageHeight = imageHeight,
            keepAspectRatio = true,
            aspectMode = "fit",
            allowSimultaneousDownloads = true,
            onComplete = function(e)
                --print("on compelted download")
                button.image = e.target
                if onImageDownloadComplete then
                    onImageDownloadComplete(e)
                end
            end
        }
        view:insert(image)
        button.image = image
        if imageRotation and imageRotation ~= 0 then
            error("[rb-newButton] Rotation not supported when using imageURL")
        end
    end
    print("imageFile=", imageFile)
    if imageFile then
        if imageWidth and imageHeight then
            image = display.newImageRect(view, imageFile, imageBaseDir, imageWidth, imageHeight)

        elseif imageWidth ~= nil and imageHeight == nil then
            image = display.newImage(view, imageFile)
            scaleFactor = imageWidth / image.contentWidth

        elseif imageWidth == nil and imageHeight ~= nil then
            image = display.newImage(view, imageFile)
            scaleFactor = imageHeight / image.contentHeight

        else
            error("Please specify 'imageHeight' and 'imageWidth'")
        end

        imageScaleX = imageScaleX * scaleFactor
        imageScaleY = imageScaleY * scaleFactor
        if image == nil then
            error("ERROR: image '" .. imageFile .."' not found!")
        end

        image:scale(imageScaleX, imageScaleY)
        image.rotation = imageRotation
        if imageColor then
            image:setFillColor( unpack(imageColor) )
        end
        button.image = image
    end
    if imageOverFile then
        imageOver = display.newImageRect(view, imageOverFile, imageBaseDir, imageWidth, imageHeight)
        imageOver:scale(imageScaleX, imageScaleY)
        image.rotation = imageRotation
        if imageOverColor then
            imageOver:setFillColor( unpack(imageOverColor) )
        end
        button.imageOver = imageOver
        imageOver.isVisible = false
    end
    if imageDisabledFile then
        imageDisabled = display.newImageRect(view, imageDisabledFile, imageBaseDir, imageWidth, imageHeight)
        imageDisabled:scale(imageScaleX, imageScaleY)
        image.rotation = imageRotation
        if imageDisabledColor then
            imageDisabled:setFillColor( unpack(imageDisabledColor) )
        end
        button.imageDisabled = imageDisabled
        imageDisabled.isVisible = false
    end


    -- creates the label
    if labelString then
        local labelMaxWidth = nil
        if width then
            labelMaxWidth = width - labelPadding.left - labelPadding.right
            if imageWidth then
                if independentPositions == false and (imagePosition == "left" or imagePosition == "right") then
                    labelMaxWidth = labelMaxWidth - image.width - imagePadding.left
                end
            end
        end
        local labelWidth = nil
        if reduceFontSizeToFitLabel or (labelWrap and not labelTruncate) then
            labelWidth = labelWidth and math.min(labelWidth, labelMaxWidth) or labelMaxWidth
        end
        if labelLineSpacing or reduceFontSizeToFitLabel then
            -- label = display.newText2{parent=view, text=labelString, font=labelFont, fontSize=labelFontSize, width=labelW, align=labelAlign, color=labelColor}
            -- label.anchorChildren = true
            -- label.anchorX = .5
            -- label.anchorY = .5
            if display.newText2 == nil then
                display.newText2 = require("rb-libs.rb-display").newText
            end
            label = display.newText2{parent=view, text=labelString, font=labelFont, fontSize=labelFontSize, width=labelWidth, align=labelAlign, _color=labelColor, _limitMode=_limitMode}
        else
            label = display.newText{parent=view, text=labelString, font=labelFont, fontSize=labelFontSize, width=labelWidth, align=labelAlign}
            label:setTextColor( unpack(labelColor) )
        end
        button.label = label

        if labelTruncate then
            if _G.AUX == nil or _G.AUX.adjustTextSize == nil then
                error("Function newButton: Please load aux library with adjustTextSize")
            end
            if labelLineSpacing then
                --print("Function newButton: labelTruncate cannot be used when labelLineSpacing is set load aux library with adjustTextSize")
                print("Function newButton: labelTruncate cannot be used when labelLineSpacing is set load aux library with adjustTextSize")
            else
                _G.AUX.adjustTextSize(label, labelMaxWidth)
            end

        end
    end

    -- positionate the objects
    local buttonW = nil
    local buttonH = nil

    if label == nil then
        -- button has only an image

        buttonW = imagePadding.left + imagePadding.right
        buttonH = height

        if image then
            buttonW = buttonW + image.contentWidth
            buttonH = math.max(buttonH, image.contentHeight)

            image.x = image.contentWidth*.5 + imagePadding.left - imagePadding.right
            image.y = buttonH*.5 + (imagePadding.top or 0 ) - (imagePadding.bottom or 0)
        end



    elseif image == nil then
        -- button has only text

        if labelWidth then
            label.x = label.contentWidth*.5
        else
            label.x = labelPadding.left + label.contentWidth*.5
        end
        buttonW = labelPadding.left + label.contentWidth + labelPadding.right

        buttonH = math.max(height, label.contentHeight)

        label.y = labelPadding.top - labelPadding.bottom
        if labelVerticalPosition == "center" then
            label.y = label.y + buttonH*.5

        elseif labelVerticalPosition == "top" then
            label.y = label.y + label.contentHeight*.5

        elseif labelVerticalPosition == "bottom" then
            label.y = label.y + buttonH - label.contentHeight*.5
        end



    else
        -- button has image and text

        if imagePosition == "left"  then
            image.x = image.contentWidth*.5 + imagePadding.left - imagePadding.right
            label.x = image.x + image.contentWidth*.5 + imagePadding.right + labelPadding.left + label.contentWidth*.5
            buttonW = imagePadding.left + image.contentWidth + imagePadding.right + labelPadding.left + label.contentWidth + labelPadding.right

            buttonH = math.max(height, image.contentHeight, label.contentHeight)

            image.y = buttonH*.5 + (imagePadding.top or 0 ) - (imagePadding.bottom or 0)
            label.y = buttonH*.5 + labelPadding.top - labelPadding.bottom


        elseif imagePosition == "right" then
            label.x = label.contentWidth*.5 + labelPadding.left
            if independentPositions then
                image.x = imagePadding.left + image.contentWidth*.5 - imagePadding.right
                buttonW = math.max(imagePadding.left + image.contentWidth - imagePadding.right, labelPadding.left + label.contentWidth - labelPadding.right)
            else
                image.x = label.x + label.contentWidth*.5 + labelPadding.right + imagePadding.left + image.contentWidth*.5 - imagePadding.right
                buttonW = imagePadding.left + image.contentWidth + imagePadding.right + labelPadding.left + label.contentWidth + labelPadding.right
            end



            buttonH = math.max(height, image.contentHeight, label.contentHeight)

            image.y = buttonH*.5 + imagePadding.top - imagePadding.bottom
            label.y = buttonH*.5 + labelPadding.top - labelPadding.bottom

        elseif imagePosition == "top" then
            buttonW = math.max(width, image.contentWidth, label.contentWidth)

            image.x = buttonW*.5 + imagePadding.left - imagePadding.right
            label.x = buttonW*.5 + labelPadding.left - labelPadding.right

            image.y = image.contentHeight*.5 + imagePadding.top - imagePadding.bottom
            label.y = image.y + image.contentHeight*.5 + imagePadding.top - imagePadding.bottom + labelPadding.top + label.contentHeight*.5 - labelPadding.bottom

            buttonH = image.contentHeight + imagePadding.top - imagePadding.bottom + labelPadding.top + label.contentHeight - labelPadding.bottom
            buttonH = math.max(height, buttonH)

        elseif imagePosition == "bottom" then
            buttonW = math.max(width, image.contentWidth, label.contentWidth)

            image.x = buttonW*.5 + imagePadding.left - imagePadding.right
            label.x = buttonW*.5 + labelPadding.left - labelPadding.right

            label.y = label.contentHeight*.5 + labelPadding.top - labelPadding.bottom
            image.y = label.y + label.contentHeight*.5 + labelPadding.top - labelPadding.bottom + imagePadding.top + image.contentHeight*.5 - imagePadding.bottom


            buttonH = image.contentHeight + imagePadding.top - imagePadding.bottom + labelPadding.top + label.contentHeight - labelPadding.bottom

        end
    end

    if imageOver then
        imageOver.x, imageOver.y = image.x, image.y
    end
    if imageDisabled then
        imageDisabled.x, imageDisabled.y = image.x, image.y
    end


    -- creates the button background
    buttonW = math.max(buttonW, width)
    local background
    if cornerRadius then
        background = display.newRoundedRect(button, buttonW*.5, buttonH*.5, buttonW, buttonH, cornerRadius)
    else
        background = display.newRect(button, buttonW*.5, buttonH*.5, buttonW, buttonH)
    end
    --local background = display.newRect(button, buttonW*.5, buttonH*.5, buttonW, buttonH)
    background:setFillColor( unpack(backgroundColor) )
    background.isHitTestable = true
    button.background = background
    background.strokeWidth = backgroundStrokeWidth
    background:setStrokeColor( unpack(backgroundStrokeColor) )

    -- adds the view (which has the image and label) to the button group
    button:insert(view)


    button.rotation = rotation

    -- the view group, when have label + text, it has the contentWidth == button. But the view.contentWidth may be not equal to to button.width because the group does not count empty space in the begining
    -- the view group when using only label, or only text, it usually have the label/text width.

    if alignX == "left" then
        view.x = 0
    elseif alignX == "center" then
        view.x = background.contentWidth*.5 - view.contentWidth*.5
    elseif alignX == "right" then
        view.x = background.contentWidth  - view.contentWidth
    end

    if alignY == "top" then
        view.y = - background.contentHeight*.5 + view.contentHeight*.5
    elseif alignY == "center" then
        view.y = 0
    elseif alignY == "bottom" then
        view.y = background.contentHeight*.5 - view.contentHeight*.5
    end


    -- positioning the button
    button.x = x or (left and (left + button.contentWidth*.5)) or (right and (right - button.contentWidth*.5))
    button.y = y or (top and (top + button.contentHeight*.5)) or (bottom and (bottom - button.contentHeight*.5))


    -- check if an event (x,y) is within the bounds of an object
    local function isWithinBounds( object, event )
        local bounds = object.contentBounds
        local x, y = event.x, event.y
        local isWithinBounds = true

        if "table" == type( bounds ) then
            if "number" == type( x ) and "number" == type( y ) then
                isWithinBounds = bounds.xMin <= x and bounds.xMax >= x and bounds.yMin <= y and bounds.yMax >= y
            end
        end

        return isWithinBounds
    end

    -- touch listener of the button
    local function touchListener(event)
        if button.isEnabled == false then return end

        local phase = event.phase

        if phase == "began" then
            button._initialStatus = button.isPressed

            setStatus( true )

            -- Set focus on the button
            button._isFocus = true
            display.getCurrentStage():setFocus( button, event.id )
        elseif button._isFocus then

            if phase == "moved"  then

                    local dy = math.abs( event.y - event.yStart )

                    if dy > 12 then
                        --print("scrollViewObj=", scrollViewObj)
                        if scrollViewObj then

                            local sv = scrollViewObj
                            if type(scrollViewObj) == "function" then
                                sv = scrollViewObj()
                            end
                            if sv == nil then return end

                            if keepPressed ~= true then
                                setStatus( false )
                            end
                            --print( sv.id)
                            if sv.id == "widget_tableView" then
                                display.getCurrentStage():setFocus(nil)
                                event.target = sv._view
                                event.phase = "began"
                                sv._view.touch(sv._view, event)
                            else
                                sv:takeFocus( event )
                            end

                            return
                        end
                    end

                    local dx = math.abs( event.x - event.xStart )
                    if dx > 12 then
                        --print("scrollViewObj=", scrollViewObj)
                        if scrollViewObj then

                            local sv = scrollViewObj
                            if type(scrollViewObj) == "function" then
                                sv = scrollViewObj()
                            end
                            if sv == nil then return end

                            if keepPressed ~= true then
                                setStatus( false )
                            end
                            --print( sv.id)
                            if sv.id == "widget_tableView" then
                                display.getCurrentStage():setFocus(nil)
                                event.target = sv._view
                                event.phase = "began"
                                sv._view.touch(sv._view, event)
                            else
                                sv:takeFocus( event )
                            end

                            return
                        end
                    end


                if isWithinBounds( button.background, event ) then
                    setStatus( true )
                else
                    if keepPressed ~= true then
                        setStatus( false )
                    end
                end


            elseif phase == "ended" or phase == "cancelled" then

                if keepPressed ~= true then
                    setStatus( false )
                end

                if isWithinBounds( button.background, event ) then
                    --print("button._initialStatus=", button._initialStatus)
                    if toggleMode and button._initialStatus then
                        --print(button._initialStatus)
                        setStatus(false)
                    end
                    if onRelease then
                        onRelease(event)
                    end
                end

                -- Remove focus from the button
                button._isFocus = false
                display.getCurrentStage():setFocus( nil )

            end

        end

        if onEvent then
            onEvent(event)
        end

        return true -- don't allowing touch event to propagate

    end

    local function tapListener(event)
        if button.isEnabled == false then return end
        setStatus( true )
        if keepPressed ~= true then
            timer.performWithDelay( 50, function() setStatus( false ) end)
        end

        if onTap then
            onTap(event)
        end

        return true -- don't allowing tap event to propagate
    end

    if onRelease then
        button:addEventListener( "touch", touchListener )
    end
    if onTap then
        button:addEventListener( "tap", tapListener )
    end

    button.setStatus = function(obj, value)
        setStatus(value)
    end

    function button:getLabel()
        return button.label.text

    end
    function button:setLabel(text)
        button.label.text = text

    end

    function button:setEnabled(isEnabled)

        if isEnabled == button.isEnabled then return end

        local newBackgroundColor = backgroundDisabledColor
        local newBackgroundStrokeColor = backgroundStrokeDisabledColor
        local newLabelColor = labelDisabledColor
        local newImageColor = imageDisabledColor
        local newImageFile = imageDisabled


        if isEnabled then
            newBackgroundColor = backgroundColor
            newBackgroundStrokeColor = backgroundStrokeColor
            newLabelColor = labelColor
            newImageColor = imageColor
            newImageFile = image
        end

        if newBackgroundColor then
            button.background:setFillColor( unpack(newBackgroundColor) )
        end
        if newBackgroundStrokeColor then
            button.background:setStrokeColor( unpack(newBackgroundStrokeColor) )
        end
        if newLabelColor and button.label then
            button.label:setTextColor( unpack(newLabelColor) )
        end
        if newImageColor and button.image then
            button.image:setFillColor( unpack(newImageColor) )
        end
        if newImageFile and button.image then
            button.image.isVisible = button.image == newImageFile
            if button.imageOver then
                button.imageOver.isVisible = button.imageOver == newImageFile
            end
            if button.imageDisabled then
                button.imageDisabled.isVisible = button.imageDisabled == newImageFile
            end
        end

        button.isEnabled = isEnabled

    end
    --------------------------------------------------------------
    -- The function and variable below are just to make this widget compatible with takeFocus function of the other Corona widgets - like scrollview
    --------------------------------------------------------------
    function button:_loseFocus()
        setStatus( false )

    end
    button._widgetType = "rbButton"



    return button

end

return rb


