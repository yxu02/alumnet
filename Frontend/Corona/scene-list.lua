local composer = require( "composer" )
local widget = require("widget")

local scene = composer.newScene()


function scene:create( event )


    local featuredPOIObj = _G.APPDATA.pointsOfInterest[1]

    local sceneGroup = self.view

    local background = display.newRect(sceneGroup, _G.CENTER_X, _G.CENTER_Y, _G.SCREEN_W, _G.SCREEN_H)
    background.fill = _G.COLORS.lightSilver

    local btSearchSize = 40
    local margin = 15
    local btSearch = _G.RB_W.newButton {
        x = _G.SCREEN_W - margin - btSearchSize/2,
        y = margin + btSearchSize/2,
        width = btSearchSize,
        height = btSearchSize,
        backgroundColor = _G.COLORS.transparent,
        backgroundOverColor = _G.COLORS.silver2,
        imageFilename = "images/ic-search.png",
        imageWidth = 22,
        imageHeight = 22,
        imagePos = "center",
        align = "center",
        cornerRadius = btSearchSize / 2,
        onRelease = function()
            composer.gotoScene("scene-search")
        end
    }
    sceneGroup:insert(btSearch)

    local scrollViewTopMargin = 5 + margin + btSearchSize
    local scrollViewHeight = _G.SCREEN_H - scrollViewTopMargin
    local scrollView = widget.newScrollView({
        x = _G.CENTER_X,
        y = scrollViewTopMargin + scrollViewHeight / 2,
        with = _G.SCREEN_W,
        height = scrollViewHeight,
        horizontalScrollDisabled = true,
        backgroundColor = _G.COLORS.lightSilver,
        bottomPadding = 50 + margin
    })
    sceneGroup:insert(scrollView)
    sceneGroup.scrollView = scrollView

    -- Featured Card --
    local primaryCardHeight = math.max(373, _G.SCREEN_H * 0.5)
    local primaryCardBottomHeight = 150
    local primaryCardImageHeight = primaryCardHeight - primaryCardBottomHeight - 6
    -- local primaryCardBottomHeight = 83

    local primaryCardWidth = _G.SCREEN_W - 2 * margin
    local primaryCardTop = 6
    local primaryCard = display.newRect(
        _G.CENTER_X,
        primaryCardTop + primaryCardHeight / 2,
        primaryCardWidth,
        primaryCardHeight)
    -- primaryCard.fill = { filename="images/card-background-shadow.png", type="image" }
    primaryCard.fill = _G.COLORS.white
    scrollView:insert(primaryCard)

    -- local primaryCardImage = _G.RB_D.newImage({
    --     x = _G.CENTER_X,
    --     y = primaryCardTop + primaryCardImageHeight / 2,
    --     width = primaryCardWidth,
    --     height = primaryCardImageHeight,
    --     filename = featuredPOIObj.mainImage, -- "images/z/img-PlaceFeatured.png", --TODO: Update gere with featuredPOIObj
    --     aspectMode = "fill",
    --     cropBoundaries = true
    -- })
    -- scrollView:insert(primaryCardImage)

    local primaryCardImage = _G.RB_D.loadImageFromInternet{
        parent = scrollView,
        imageURL = featuredPOIObj.mainImage,
        imageWidth = primaryCardWidth,
        imageHeight = primaryCardImageHeight,
        --placeholderImageFilename  -- with path
        --placeholderBackgroundColor = {.2,.2,.2, 1},
        --keepAspectRatio = true,
        aspectMode = "fit",
        initialAlpha = 0,
        allowSimultaneousDownloads = true,
        onComplete = function(e)
            if sceneGroup.triangle then
                sceneGroup.triangle:toFront()
            end
            if sceneGroup.btPlay then
                sceneGroup.btPlay:toFront()
            end
            if not e.wasCached then
                transition.to(e.target,{alpha = 1, time=400})
            else
                e.target.alpha = 1
            end
        end
    }
    primaryCardImage.x = _G.CENTER_X
    primaryCardImage.y = primaryCardTop + primaryCardImageHeight / 2


    local triangleHeight = 83 * primaryCardWidth / 312
    local triangle = _G.RB_D.newImage({
        x = _G.CENTER_X,
        y = primaryCardImage.y + primaryCardImage.contentHeight / 2 -  triangleHeight / 2 + 1,
        width = primaryCardWidth,
        height = triangleHeight,
        filename = "images/rect-featuredBottom.png",
        aspectMode = "fill"
    })
    scrollView:insert(triangle)
    sceneGroup.triangle = triangle

    local btPlay = _G.RB_W.newButton {
        x = _G.CENTER_X,
        y = primaryCardImageHeight - triangleHeight / 2,
        width = 190,
        height = 55,
        backgroundColor = _G.COLORS.primary,
        backgroundOverColor = _G.COLORS.primaryOver,
        label = _G.I18N.playAudio,
        labelFontSize = 20,
        labelFont = _G.FONTS.btListenAudio,
        labelColor = _G.COLORS.white,
        labelOverColor = _G.COLORS.overlay("white"),
        imageFilename = "images/ic-music.png",
        imageWidth = 15,
        imageHeight = 18,
        imagePos = "right",
        imagePadding = { left = 10 },
        align = "center",
        cornerRadius = 10,
        onRelease = function()
            -- composer.gotoScene("scene-list")
            _G.PLAYER.playAudioFromPOI(featuredPOIObj)
        end
    }
    scrollView:insert(btPlay)
    sceneGroup.btPlay = btPlay

    local lbTitle = display.newText {
        text = featuredPOIObj[_G.LANG].title,
        x = _G.CENTER_X,
        y = primaryCardTop + primaryCardHeight - 118,
        fontSize = 22,
        width = primaryCardWidth * .98,
        align = "center"
    }
    lbTitle:setTextColor(unpack(_G.COLORS.navy))
    scrollView:insert(lbTitle)

    local dividerY = primaryCardTop + primaryCardHeight - 80
    local divider = display.newLine(margin, dividerY, _G.SCREEN_W - margin, dividerY)
    divider:setStrokeColor(unpack(_G.COLORS.lightSilver))
    divider.strokeWidth = 2
    scrollView:insert(divider)

     local btnRoute = _G.RB_W.newButton {
        x = _G.CENTER_X,
        y = primaryCardTop + primaryCardHeight - 39,
        width = 190,
        height = 55,
        backgroundColor = _G.COLORS.transparent,
        backgroundOverColor = _G.COLORS.silver2,
        backgroundStrokeWidth = 1,
        backgroundStrokeColor = _G.COLORS.lightBlue,
        backgroundStrokeOverColor = _G.COLORS.lightBlue,
        label = _G.I18N.list.route,
        labelFontSize = 20,
        labelFont = _G.FONTS.btListenAudio,
        labelColor = _G.COLORS.lightBlue,
        labelOverColor = _G.COLORS.overlay("lightBlue"),
        imageFilename = "images/ic-route.png",
        imageWidth = 29,
        imageHeight = 29,
        imagePos = "right",
        imagePadding = { left = 10 },
        align = "center",
        cornerRadius = 10,
        scrollViewParent = function() return sceneGroup.scrollView end,
        onRelease = function()
            _G.MAPS.openRouteToPOIObj(featuredPOIObj)
        end
    }
    scrollView:insert(btnRoute)


    local cardSpacing = 10
    local cardWidth = (_G.SCREEN_W - 2 * margin - cardSpacing) / 2
    local cardImageHeight = 150
    local cardHeight = 200


    local function isWithinBounds(object, event)
        local bounds = object.contentBounds
        local x, y = event.x, event.y
        local isWithinBounds = true

        if "table" == type(bounds) then
            if "number" == type(x) and "number" == type(y) then
                isWithinBounds = bounds.xMin <= x and bounds.xMax >= x and bounds.yMin <= y and bounds.yMax >= y
            end
        end

        return isWithinBounds
    end

    -- CARDS --
    local createCard = function(imageFileName, title, sceneParams, parent)

        local group = display.newGroup()

        local rect = display.newRect(cardWidth / 2, cardHeight / 2, cardWidth, cardHeight)
        rect.fill = _G.COLORS.white
        group:insert(rect)

        -- local image = _G.RB_D.newImage({
        --     x = cardWidth / 2,
        --     y = cardImageHeight / 2,
        --     width = cardWidth,
        --     height = cardImageHeight,
        --     filename = imageFileName,
        --     aspectMode = "fill",
        --     cropBoundaries = true
        -- })
        -- group:insert(image)

       local image = _G.RB_D.loadImageFromInternet{
            parent = group,
            imageURL = imageFileName,
            imageWidth = cardWidth,
            imageHeight = cardImageHeight,
            --placeholderImageFilename  -- with path
            --placeholderBackgroundColor = {.2,.2,.2, 1},
            keepAspectRatio = true,
            aspectMode = "fit",
            allowSimultaneousDownloads = true,
            initialAlpha = 0,
            onComplete=function(e)
                if not e.wasCached then
                    transition.to(e.target,{alpha = 1, time=400})
                else
                    e.target.alpha = 1
                end
            end
        }
        image.x = cardWidth / 2
        image.y = cardImageHeight / 2


        local text = display.newText {
            parent = group,
            text = title,
            x = cardWidth / 2,
            y = cardImageHeight + 24,
            fontSize = 16,
            width = cardWidth * .98,
            align = "center"
        }
        text:setTextColor(unpack(_G.COLORS.gray))

        local overLayer = display.newRect(cardWidth / 2, cardHeight / 2, cardWidth, cardHeight)
        overLayer.fill = {0,0,0,0.2}
        overLayer.isVisible = false
        group:insert(overLayer)

        if parent then
            parent:insert(group)
        end

        group._isFocus = false

        local function setFocus(val)
            group._isFocus = val
            overLayer.isVisible = val
        end

        local function touchListener(event)
            local phase = event.phase

            if phase == "began" then
                setFocus(true)
            elseif group._isFocus then
                if phase == "moved"  then
                    local dy = math.abs( event.y - event.yStart )

                    if dy > 12 then
                        setFocus(false)
                        event.target = scrollView._view
                        event.phase = "began"
                        scrollView._view.touch(scrollView._view, event)
                        return
                    end
                    local dx = math.abs( event.x - event.xStart )
                    if dx > 12 then
                        setFocus(false)
                        event.target = scrollView._view
                        event.phase = "began"
                        scrollView._view.touch(scrollView._view, event)
                        return
                    end

                    if isWithinBounds(rect, event) then
                        setFocus(true)
                    else
                        setFocus(false)
                    end
                elseif phase == "ended" or phase == "cancelled" then
                    setFocus(false)
                    if isWithinBounds(rect, event) then
                        composer.gotoScene("scene-internal", { params = sceneParams })
                    end
                end
            end

            return true
        end

        group:addEventListener("touch", touchListener)

        return group
    end

    local top = primaryCardTop + primaryCardHeight + 30
    for i, v in ipairs(_G.APPDATA.pointsOfInterest) do
        local card = createCard(v.mainImage, v[_G.LANG].title, v, scrollView)
        card.x = margin + ((i - 1) % 2) * (cardSpacing + cardWidth)
        card.y = top

        top = top + ((i - 1) % 2) * (cardHeight + cardSpacing)
    end

end


-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

        _G.TABBAR.show(true) -- showing (just in case it was hided before. True means to show it using animation)

    elseif ( phase == "did" ) then

        _G.TABBAR.update()
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then

    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene
