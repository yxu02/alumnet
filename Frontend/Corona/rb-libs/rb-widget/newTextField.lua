local rb = {}
---------------------------------
--
--  Red Beach NewTextField/Box
--  v26
--
--
---------------------------------
-- versions:
--
-- v26: fixed onStopTyping to be called only during on "editing" phase; added onFocus() callback
-- v25: standarized to all listener functions (onRelase, onStopTyping,..) to return as the first param the textField group.
-- v24: added hasNonEmptyText(); added hasNonEmptyTextWithMinimumLength()
-- v23: setText() now updated fakeLabel also; replaced onRelease with onStopTyping & added onRelease ;
-- v22: added text initialization; fixed when useFakeLabel == false; added onRelease; added align to fake label; forcing to have backgroundColor when using useFakeLabel; set useFakeLabel to true as default, added useFakeLabel options; fixed autocapitalization; added useTextBox; added card formattype;  fixed 'words' autocapitalization; added formatType 'date'; fixed isDeleting with formatType; added bottomLineColor, bottomLineWidth; added parentGroupToMove, updated setAlpha, added hasBackground, added background,  added more format types, added left/right label; added autocapitalizationType;  added nextInput, isSecure e align; added brazilian phone validation)

---------------------------------------------------------------------------------
-- extension functions for COMPOSER
rb._dicSceneNameToTextFields = {}

local composer = require("composer")
local function getInputsFromCurrentScene()
    local sceneName = composer.getSceneName( "current" )
    if sceneName then
        return (rb._dicSceneNameToTextFields[sceneName] or {})
    end
end
composer._hideInputs = function()
    --print("on composer._hideInputs")
    --pt(rb._dicSceneNameToTextFields, "rb._dicSceneNameToTextFields=")
    local listInputs = getInputsFromCurrentScene()
    for _,v in ipairs(listInputs) do
        --print("#listInputs=", #listInputs)
        if v:getVisibility() then
            v:setVisibility(false)
            v._hiddenByRB = true
        end
    end

end
composer._destroyInputs = function()

end
composer._showInputs = function()

    local listInputs = getInputsFromCurrentScene()
    for _,v in ipairs(listInputs) do
        if v._hiddenByRB then
            v:setVisibility(true)
            v._hiddenByRB = nil
        end
    end
end

------------------------------------------------------------------------------------------------------------


rb.new = function(options)

    -- receiving params
    local x = options.x
    local left = options.left
    local y = options.y
    local top = options.top
    local w = options.w or options.width or 170
    local h = options.h or options.height or 30


    local placeholder = options.placeholder
    local placeholderColor = options.placeholderColor or {1,1,1}
    local text = options.text
    local textColor = options.textColor or {0,0,0}
    local font = options.font or (myGlobals and myGlobals.fontTextLabel)
    local fontSize = options.fontSize or 20
    local returnKey = options.returnKey or (options.nextInput and "next" ) or "done"
    local inputType = options.inputType or "default"  -- values are:  number, decimal, phone, url, email     -- https://docs.coronalabs.com/api/type/TextField/inputType.html
    local hasBackground = options.hasBackground  -- default is false (defined later)

    local forceUpperCase = options.forceUpperCase
    local autocapitalizationType = options.autocapitalizationType  -- "all", "sentences", "words"
    local maxChars = options.maxChars           -- make sure to include any char added by the format type option
    local invalidChars = options.invalidChars   -- string ex:  "abc". If it is a non-alphanumeric, escape using %  (eg.: "abc%^%[%%")  invalid chars here are a,b,c,^,[ and%

    local autocorrectionType  = options.autocorrectionType or options.autoCorrectionType or "UITextAutocorrectionTypeDefault"  -- values are:  "UITextAutocorrectionTypeDefault or "UITextAutocorrectionTypeYes", "UITextAutocorrectionTypeNo"


    local listener = options.listener
    local onStopTyping = options.onStopTyping -- function that is called after the user stopped typing for onStopTypingTime seconds
    local onStopTypingTime = options.onStopTypingTime or 1.2 -- time that widget will wait before calling onStopTyping. If any key is typed during the wait time, the timer resets.
    local onRelease = options.onRelease -- called when input lost focus
    local onFocus = options.onFocus     -- called when the user just selected the textfield

    local parent = options.parent
    local id = options.id
    local index = options.index

    local formatType = options.formatType
    local align = options.align or "left"
    local isSecure = options.isSecure or false
    local nextInput = options.nextInput


    local leftLabel = options.leftLabel
    local rightLabel = options.rightLabel

    local backgroundColor = options.backgroundColor
    local backgroundCornerRadius = options.backgroundCornerRadius
    local backgroundStrokeColor = options.backgroundStrokeColor
    local backgroundStrokeWidth = options.backgroundStrokeWidth


    local bottomLineColor = options.bottomLineColor or {0,0,0,.3}
    local bottomLineWidth = options.bottomLineWidth

    local parentGroupToMove = options.parentGroupToMove


    local useTextBox = options.useTextBox

    local useFakeLabel = options.useFakeLabel  -- default is true (defined later)

    if hasBackground == nil then
        hasBackground = false
    end
    if useFakeLabel == nil then
        useFakeLabel = true
    end
    --print("useFakeLabel=", useFakeLabel)
    -- when using fake label, we need a background, so let's force a invisible one if not specified
    if useFakeLabel then
        backgroundColor = backgroundColor or {1,1,1,0}
    end


    local DEVICE = _G.DEVICE or _G.RB_DEVICE
    if DEVICE.isAndroid then
        h = h + 4
        if fontSize and DEVICE.isAndroid then
            fontSize = fontSize - 2
        end

    end


    autocapitalizationType = (forceUpperCase and "all") or autocapitalizationType

    local autocapitalizationTypeOptions = {["all"] = 1, ["sentences"]=2, ["words"]=3}
    autocapitalizationType = autocapitalizationTypeOptions[autocapitalizationType]


    -- creating pattern for invalid chars
    local pattern = "["
    if invalidChars then
        for i=1,#invalidChars do
            local chr = invalidChars:sub(i,i)
            if chr:match("%W") then  -- if not alphanumeric
                pattern = pattern .. "%" .. chr
            else
                pattern = pattern .. chr
            end

        end
    end
    pattern = pattern.."]"


    ----------------------------------------------------
    -- format type functions

    local format={}

    format["zipcode"] = function(text, removeFormat)

        if text == nil or #text == 0 then
            return ""
        end

        --text = text:gsub("-","")
        text = text:gsub("[^0-9]","") -- removing everything that is not number
        if removeFormat then
            return text
        end

        local firstPart = text:sub(1,5)
        local secondPart = text:sub(6,8)

        if secondPart ~= "" then
            return firstPart .. "-" .. secondPart
        end

        return firstPart
    end

    format["phone-br"] = function(text, removeFormat)

        if text == nil or #text == 0 then
            return ""
        end

        text = text:gsub("[^0-9]","") -- removing everything that is not number
        if removeFormat then
            return text
        end

        local firstPart = text:sub(1,2) -- ddd
        local secondPart = text:sub(3,6) -- first digits
        local thirdPart = text:sub(7,10) -- last digits
        if #text >= 11 then
            secondPart = text:sub(3,7)
            thirdPart = text:sub(8,11)
        end

        if secondPart ~= "" and thirdpart ~= "" then
            return "(" .. firstPart .. ")" .. secondPart .. "-" .. thirdPart
        elseif secondPart ~= "" then
            return "(" .. firstPart .. ")" .. secondPart
        end

        return "(" .. firstPart .. ")"
    end

    format["currency-br"] = function(text, removeFormat)

        if text == nil or #text == 0 then
            return ""
        end

        text = text:gsub("[^0-9%,.]","") -- removes the R$
        text = text:gsub("[%,]","%.")   -- replaces the "," with "."
        text = tonumber(text)
        if removeFormat then
            return text -- return the currency as a number in decimal US format
        end

        text = string.format("R$ %.2f", text)
        text = text:gsub("[%.]","%,")   -- replaces the "." with ","
        return text
    end

    -- MM/DD/YYYY or DD/MM/YYYY
    format["date"] = function(text, removeFormat)

        if text == nil or #text == 0 then
            return ""
        end

        text = text:gsub("[^0-9]","") -- removing everything that is not number
        if removeFormat then
            return text
        end

        local firstPart = text:sub(1,2)
        local secondPart = text:sub(3,4)
        local thirdPart = text:sub(5,8)

        if thirdPart ~= "" then
            return firstPart .. "/" .. secondPart .. "/" .. thirdPart
        end
        if secondPart ~= "" then
            return firstPart .. "/" .. secondPart
        end

        return firstPart
    end



    -- credit/debit card
    format["card"] = function(text, removeFormat)

        if text == nil or #text == 0 then
            return ""
        end

        text = text:gsub("[^0-9]","") -- removing everything that is not number
        if removeFormat then
            return text
        end

        local firstPart = text:sub(1,4)
        local secondPart = text:sub(5,8)
        local thirdPart = text:sub(9,12)
        local fourthPart = text:sub(13,16)

        if fourthPart ~= "" then
            return firstPart .. "-" .. secondPart .. "-" .. thirdPart .. "-" .. fourthPart
        end
        if thirdPart ~= "" then
            return firstPart .. "-" .. secondPart .. "-" .. thirdPart
        end
        if secondPart ~= "" then
            return firstPart .. "-" .. secondPart
        end

        return firstPart
    end





    local group = display.newGroup()


    local lbLeft = nil
    local lbLeftW = 0
    local lbRight = nil
    local lbRightW = 0

    -- labels
    if leftLabel then
        lbLeft = display.newText{x=0, y=0, text=leftLabel,font=font, fontSize=fontSize}
        lbLeft.anchorX = 0
        lbLeftW = lbLeft.contentWidth

    end
    if rightLabel then
        lbRight = display.newText{x=0, y=0, text=rightLabel,font=font, fontSize=fontSize}
        lbRight.anchorX = 0
        lbRightW = lbRight.contentWidth

    end

    local input
    local lastChar = nil
    local function textListener( event )
        print( "on textListener - ", event.phase )

        local target = event.target
        --pt(event,target.text)
          ----print( target.text )

        -- moving sceneGroup if neeed and also removing the placeholder
        if ( event.phase == "began" ) then

            if parentGroupToMove and event.target.contentBounds.yMax > display.contentCenterY then
                print("NEED TO MOVE UP!!")
                parentGroupToMove._rbTextFieldY = parentGroupToMove.y
                parentGroupToMove.y = parentGroupToMove.y - (event.target.contentBounds.yMax - display.contentCenterY)

            end
            -- user begins editing defaultField
            target:setTextColor( unpack(textColor) )
            if placeholderColor and target.text == placeholder then
                target.text = ""
            end

            if onFocus then
                onFocus(group)
            end

        -- moving back the sceneGroup to original position, showing placeholder (if the case) and selecting next input (if the case)
        elseif ( event.phase == "ended" or event.phase == "submitted" ) then


            if parentGroupToMove and parentGroupToMove._rbTextFieldY then
                parentGroupToMove.y = parentGroupToMove._rbTextFieldY
                parentGroupToMove._rbTextFieldY = nil
            end
            print(event.phase )
            if useFakeLabel and group._setFakeLabel then
                group._setFakeLabel(target.text)
                group._showFakeLabel()
            end

            if placeholderColor and target.text == "" then
                target.text = placeholder
                target:setTextColor( unpack(placeholderColor) )
            end

            -- setting focus on next input
            if ( event.phase == "submitted" ) then
                if type(nextInput) == "function" then
                    nextInput = nextInput()
                end
                if nextInput and nextInput._hideFakeLabel then
                    nextInput._hideFakeLabel()  -- hideFakeLabel already gives focus to the input
                else
                    nextInput = (nextInput and nextInput.input) or nextInput
                    native.setKeyboardFocus(nextInput)
                end
            end

            --print("onRelease=", onRelease)
            if onRelease then
                onRelease(group)
            end

        elseif ( event.phase == "editing" ) then

            if onStopTyping then
                if group._onStopTypingTimerId then
                    timer.cancel( group._onStopTypingTimerId )
                    group._onStopTypingTimerId = nil
                end
                group._onStopTypingTimerId = timer.performWithDelay(onStopTypingTime * 1000, function()
                    if onStopTyping then
                        onStopTyping(group, event)
                    end
                end)
                print("group._onStopTypingTimerId =", group._onStopTypingTimerId, event.text, event.newCharacters )
            end

            -- android is supper laggy when handling the text on the spot, so let's not do all processing
            if DEVICE.isAndroid then
                if autocapitalizationType and event.startPosition == 1  then
                    local currText = event.target.text
                    input.text = string.upper(currText:sub(1,1)) .. (currText:sub(2) or "")
                end
                if listener then listener(group, event) end
                return

            end -- android is showing too much lag if doing the processing below. Let's stop it here



            --print("event.startPosition=", event.startPosition)
            ----print("autocapitalizationType=", autocapitalizationType)

            if maxChars then
                print("event.text befr= ", event.text)
                event.target.text = string.sub(event.text,1,maxChars)
                print("event.text after= ", event.target.text)
            end
           ----print("event.newCharacters=",event.newCharacters)
           ----print("invalidChars:find(event.newCharacters)=",invalidChars:find(event.newCharacters))
            --if invalidChars and invalidChars:find("[%" .. event.newCharacters .. "]") then
            if invalidChars and event.newCharacters:find(pattern) then
                input.text = string.sub(event.text,1,#event.text - 1)
            end

            if autocapitalizationType == 1 then
                input.text = string.upper(event.target.text)

            elseif event.startPosition == 1 and autocapitalizationType == 2 then
                input.text = string.upper(event.target.text)

            elseif autocapitalizationType == 3 and (lastChar == nil or lastChar == " ") then
                input.text = string.sub(event.text,1,#event.text - 1) .. string.upper( event.newCharacters )
            end

            if forceUpperCase then
                input.text = string.upper(event.target.text)
            end

            if event.target.text then
                if format[formatType] then
                    print("event.newCharacters=", event.newCharacters)
                    local isDeleting = (event.newCharacters == "")
                    print("isDeleting=", isDeleting)
                    if not isDeleting then
                        local formattedText = format[formatType](event.target.text)
                        event.target.text = formattedText

                        -- when adding the format, we may ended up adding extra chars and the textfield does not automatically adjust to that.
                        -- so we need to manually repositionate the cursor to its correct position
                        local charBefore = string.sub(formattedText, event.startPosition, event.startPosition )
                        local charAfter
                        if event.startPosition+1 <= #formattedText then
                            charAfter = string.sub(formattedText, event.startPosition+1,event.startPosition+1)
                        end
                        if DEVICE.isAndroid and (isDeleting == false) and (charBefore ~= event.newCharacters and charAfter == event.newCharacters) then
                            event.target:setSelection( event.startPosition+1, event.startPosition+1 )
                            ----print("moved cursor")
                        end
                    end



                end

            end
            lastChar = event.newCharacters
        end

        if listener then listener(group, event) end
    end
    local inputW = w - lbLeftW - lbRightW
    if useTextBox then
        -- local defaultBox = native.newTextBox( 200, 200, 280, 140 )
        input = native.newTextBox( inputW*.5 + lbLeftW, -2000, inputW, h ) -- starting the textfield out of screen to avoid the textfield blinking at 0,0 position on Android devices.
        input.isEditable = true
    else
        input = native.newTextField( inputW*.5 + lbLeftW, -2000, inputW, h ) -- starting the textfield out of screen to avoid the textfield blinking at 0,0 position on Android devices.
        --input = native.newTextField( -2000, -2000, inputW, h )  -- comment a: if we change the x position, we need to reposition it below (as already commented below)
    end
    input.isSecure = isSecure
    input.hasBackground = hasBackground
    input.font = native.newFont( font, fontSize )

    if placeholderColor == nil then  -- we cannot customize the placeholder color, so when specified, let's use the placeholder as normal text and the library will handle the automatic replace
        input.placeholder = placeholder
        input:setTextColor( unpack(textColor) )
    else
        input.text = placeholder
        input:setTextColor( unpack(placeholderColor) )  -- the textColor wll be used when the .text is equal to real text (not the placeholder text)
    end
    input:addEventListener( "userInput", textListener )
    input:setReturnKey( returnKey )
    input.inputType = inputType
    input.align = align
    input.autocorrectionType = autocorrectionType

    input.id = id
    input.index = index

    group:insert(input)
    group.input = input


    if lbLeft then
        group:insert(lbLeft)
        lbLeft.x = 0
        --input.x = lbLeft.x + lbLeft.contentWidth + inputW*.5  -- comment (a) above
        lbLeft.y = input.y

    end

    if lbRight then
        group:insert(lbRight)
        lbRight.x = input.x + inputW*.5
        lbRight.y = input.y

    end

    -- adding the line below the textfield
    if bottomLineWidth then
        local lineY = input.y + input.contentHeight*.5
        local lineLeft = input.x - input.contentWidth*.5
        local line = display.newLine(lineLeft, lineY , lineLeft + input.contentWidth, lineY)
        line.strokeWidth = bottomLineWidth
        line:setStrokeColor( unpack(bottomLineColor) )
        group:insert(line)
    end


    -- adding the background
    local background
    if backgroundCornerRadius then
        background = display.newRoundedRect(group, input.x, input.y, inputW, h,backgroundCornerRadius)
    end
    if backgroundColor then
        background = background or display.newRect(group, input.x, input.y, inputW, h)
        background:setFillColor( unpack(backgroundColor) )
    end
    if backgroundStrokeWidth then
        background = background or display.newRect(group, input.x, input.y, inputW, h)
        background:setStrokeColor( unpack(backgroundStrokeColor) )
        background.strokeWidth = backgroundStrokeWidth
    end
    if background then
        input.hasBackground = false

    end




    if parent then
        parent:insert(group)
    end



    group.anchorChildren = true  -- this automatically reposition the textfield inside the group
    group.x = x or (left + w*.5)
    group.y = y or (top + h*.5)




    ------------------------
    -- public functions

    function group:setText(text)
        text = text or ""
        if format[formatType] then
            text = format[formatType](text)
        end
        if placeholder and text == "" then
            input.text = placeholder
            input:setTextColor( unpack(placeholderColor) )

        else
            input.text = text
            input:setTextColor( unpack(textColor) )

        end

        if useFakeLabel and group._setFakeLabel then
            group._setFakeLabel(text)
        end
    end

    function group:getText()
        local text = input.text
        if format[formatType] then
            text = format[formatType](text, true)
        end
        if placeholderColor and text == placeholder then
            text = ""
        end
        return text
    end


    function group:hasNonEmptyText()
        local currText = group:getText()
        return (currText ~= nil and currText ~= "")
    end

    function group:hasNonEmptyTextWithMinimumLength(minLength)
        local currText = group:getText()
        if currText == nil or text == "" then
            return false, 1
        end

        if string.len( text ) < minLength then
            return false, 2
        end

        return true
    end

    function group:setPlaceholder(newText)
        if placeholderColor == nil then
            input.placeholder = newText
        elseif input.text == placeholder then
            input.text = newText
        end
        placeholder = newText
        --print("updated placeholder to ", text)
    end

    function group:getPlaceholder()
        return input.placeholder
    end

    function group:setVisibility(isVisible)
        --group.isVisible = isVisible  -- commented this out to allow the background to keep on screen
        input.isVisible = isVisible
    end

    function group:getVisibility()
        return input.isVisible
    end

    function group:setAlpha(finalAlpha, duration, onComplete)
        if duration == nil then
            group.alpha = finalAlpha
            input.alpha = finalAlpha
            return
        end
        transition.to(group, {alpha=finalAlpha, time = duration})
        transition.to(input, {alpha=finalAlpha, time = duration, onComplete=onComplete})
    end

    function group:remove()
        display.remove(input); input = nil
        display.remove( group ); group = nil
    end

    group.getFocus = function()
        native.setKeyboardFocus(input)
    end


    -- initial text (if any)
    if text then
        group:setText(text)
    end


    -------------------------------------------------------
    -- composer auto hide/show and setting  parentGroupToMove

    -- storing scene name of this textfield so we can hide/show all textfields of a scene by calling composer._hideInputs, composer._showInputs
    local sceneName = composer.getSceneName( "current" )
    if sceneName then
        rb._dicSceneNameToTextFields[sceneName] = rb._dicSceneNameToTextFields[sceneName] or {}
        table.insert( rb._dicSceneNameToTextFields[sceneName], group)
    end


    local function showInputDueToComposer()
        --print("on showInputDueToComposer")
        if group._hiddenByRB then
            group:setVisibility(true)
            group._hiddenByRB = nil
        end
    end
    local function hideInputDueToComposer()
        --print("on hideInputDueToComposer")
        if group:getVisibility() then
            group:setVisibility(false)
            group._hiddenByRB = true
        end
    end
    local function destroyInputDueToComposer()
        --print("on destroyInputDueToComposer")
        group:remove()
    end








    -- storing scene name of this textfield so it can automatically handle show/hide/destroy
    local composer = require("composer")
    local sceneName = composer.getSceneName( "current" )
    local scene = composer.getScene( sceneName )

    parentGroupToMove = parentGroupToMove or scene.view

    function trap_event(event)
        --print(composer.getSceneName( "current" ), "trap - ", event.name, event.phase)

        if event.name == "show" and  event.phase == "did" then
            showInputDueToComposer()
        elseif event.name == "hide" and  event.phase == "will" then
            hideInputDueToComposer()
        elseif event.name == "destroy" then
            destroyInputDueToComposer()
        end

    end

    if not useFakeLabel then -- if we are using fakeLabel, no need to use this composer auto hide/show
        scene:addEventListener( "show", trap_event )
        scene:addEventListener( "hide", trap_event )
    end







    -------------------------------------------------------
    -- fake label (replace the native input with a newText when the input is not on focus)

    if useFakeLabel then

        input.isVisible = false -- hiding input since it the fake label is the one visible
        background.isHitTestable = true
        background:addEventListener( "tap", function()
            group._hideFakeLabel()
        end)
        local rbAux = require("rb-libs.rb-aux")
        if rbAux == nil then
            error("rb-widget.newTextField with useFakeLabel enabled requires the rb-libs.rb-aux lib with adjustTextSize function")
        end
        local adjustTextSize = require("rb-libs.rb-aux").adjustTextSize
        local lbFake = display.newText{parent=group, text="", x=background.x, y=background.y, font=font, fontSize=fontSize }
        lbFake:setTextColor(1,0,0)
        --TODO: add align support (left, center, right). Now we are just supporting center.
        if align == "left" then
            lbFake.anchorX = 0
            lbFake.x = background.x - background.contentWidth*.5
        elseif align == "right" then
            lbFake.anchorX = 1
            lbFake.x = background.x + background.contentWidth*.5
        end

        group._setFakeLabel = function(value)
            --print("on _setFakeLabel - ", value, placeholder, value == "", value == " ")
            local isPlaceholder = placeholderColor and placeholder and (value == nil or value == placeholder or value == "")
            if isPlaceholder then
                lbFake.text = placeholder
                lbFake:setTextColor( unpack(placeholderColor) )
            else
                lbFake.text = value
                lbFake:setTextColor( unpack(textColor) )
            end
            adjustTextSize(lbFake, background.contentWidth)
        end

        group._showFakeLabel = function()
            --print("_showFakeLabel")
            lbFake.isVisible = true
            input.isVisible = false
        end

        group._hideFakeLabel = function()
            lbFake.isVisible = false
            input.isVisible = true
            timer.performWithDelay(10, function()
                native.setKeyboardFocus( input )
            end)
        end

        group._setFakeLabel(text)
    end



    return group


end


return rb


