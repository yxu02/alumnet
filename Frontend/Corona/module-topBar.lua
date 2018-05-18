---------------------
--
-- Red Beach
--
-- Module Top Bar / Nav Bar
--
-- v1
--
---------------------


local nb = display.newGroup()



nb.new = function(options)


    -- receiving params
    local titleText = options.title or "Editar Dados"
    local leftButtonHandler = options.leftButtonHandler
    local rightButtonHandler = options.rightButtonHandler
    local useCloseRightButton = options.useCloseRightButton
    local parent = options.parent
    local isHidden = options.isHidden or false

    local areButtonsDisabled = false





    local navBar = display.newGroup()



    local background = display.newRect(navBar, _G.SCREEN_W*.5, 44*.5, _G.SCREEN_W, 44)
    background:setFillColor( 124/255,171/255,153/255 )


    local btLeftW = background.width*0.15
    local btLeft = _G.RB_W.newButton{
        width = btLeftW,
        height = background.contentHeight,
        --backgroundColor = { 1,0,1},
        y = background.y,
        --x = 0,
        left = 0,
        imageFile = "images/ic-back.png",
        imageWidth = 24,
        imageHeight = 19,
        imagePadding = {left=8},
        imageColor = {1,1,1,1},
        imageOverColor = {1,1,1,.3},
        onRelease = function(e) if leftButtonHandler and areButtonsDisabled == false then leftButtonHandler(e) end end ,
    }
    --b.x = b.contentWidth*.5
    navBar:insert(btLeft)
    if leftButtonHandler == nil then
        btLeft.isVisible = false
    end


    local btBack = _G.RB_W.newButton{
        width = btLeftW,
        height = background.contentHeight,
        --backgroundColor = { 1,0,1},
        y = background.y,
        --x = 0,
        left = 0,
        imageFile = "images/ic-back.png",
        imageWidth = 12,
        imageHeight = 21,
        imagePadding = {left=8},
        imageColor = {1,1,1,1},
        imageOverColor = {1,1,1,.3},
        onRelease = function()
			if areButtonsDisabled == false then
				if _G.BACK then
					_G.BACK.goBack()
				else
					print("[module-topBar] no RB-BACK library found on _G.BACK")
				end
			end
        end,
    }
    --b.x = b.contentWidth*.5
    navBar:insert(btBack)
    btBack.isVisible = noBackButton ~= true


    local btRightImageFile = "images/ic-back.png"
    local btRightImageWidth = 24
    local btRightImageHeight = 19

    if useCloseRightButton then
        btRightImageFile = "images/ic-close.png"
        btRightImageWidth = 20
        btRightImageHeight = 21
    end
    local btRightW = math.min(background.width*0.15, 60)
    local btRight = _G.RB_W.newButton{
        width = btRightW,
        height = background.contentHeight,
        --backgroundColor = { 1,0,1},
        y = background.y,
        right = _G.SCREEN_W,
        imageFile = btRightImageFile,
        imageWidth = btRightImageWidth,
        imageHeight = btRightImageHeight,
        imagePadding = {left=btRightW - 12 - 20},
        imageColor = {1,1,1,1},
        imageOverColor = {1,1,1,.3},
        imageRotation = 180,
        onRelease = function(e) if rightButtonHandler and areButtonsDisabled == false then timer.performWithDelay( 10, function() rightButtonHandler(e) end) end return true end ,
        onTap = function() return true end;
    }
    navBar:insert(btRight)


    if rightButtonHandler == nil then
        btRight.isVisible = false
    end

    local titleW = background.width*.8
    if btLeft.isVisible then
        titleW = titleW - btLeft.contentWidth - 4
    end
    if btRight.isVisible then
        titleW = titleW - btRight.contentWidth - 4
    end

    local title = display.newText{parent=navBar, text=titleText, font=_G.FONTS.topBarTitle, fontSize=24, width=titleW, align="center"}
    title.x,title.y = background.x, background.y
    title:setTextColor(unpack(_G.COLORS.navBarLabel))


    -- hiding the bar
    if isHidden then
        navBar.y = -navBar.contentHeight  --_G.TOP_AFTER_STATUS_BAR
    else
        navBar.y = _G.TOP_AFTER_STATUS_BAR
    end


    if parent then
        parent:insert(navBar)
    end





    ------------------------
	-- Public functions


    navBar.hide = function(animated)

        if navBar.y == (-navBar.contentHeight) then
            return
        end

        animated = animated or false

        local duration = 200
        if animated == false then
            duration = 0
        end
        transition.to(navBar, {y=-navBar.contentHeight, time=duration})


    end

    navBar.show = function(animated)

        if navBar.y == _G.TOP_AFTER_STATUS_BAR then
            return
        end

        animated = animated or false

        local duration = 200
        if animated == false then
            duration = 0
        end
        transition.to(navBar, {y=_G.TOP_AFTER_STATUS_BAR, time=duration})

    end

    navBar.setTitle = function(obj, newTitle)
        newTitle = newTitle or obj
        title.text = newTitle

    end

    navBar.hideRightButton = function()
        btRight.isVisible = false
    end

    navBar.showRightButton = function()
        btRight.isVisible = true
    end


    navBar.hideLeftButton = function()
        btLeft.isVisible = false
    end

    navBar.showLeftButton = function()
        btLeft.isVisible = true
    end


    navBar.setLeftButtonHandler = function(handler)
        leftButtonHandler = handler
        if handler then
            navBar.showLeftButton()
        else
            navBar.hideLeftButton()
        end
    end

    navBar.enableButtons = function()
        areButtonsDisabled = false
    end

    navBar.disableButtons = function()
        areButtonsDisabled = true
    end

    return navBar, (_G.TOP_AFTER_STATUS_BAR + navBar.contentHeight)


end



return nb