local composer = require( "composer" )

local scene = composer.newScene()

function scene:create( event )

    local sceneGroup = self.view


    local imgLogo = display.newImageRect( sceneGroup, "images/logo.png", 238, 49)
    imgLogo.x = _G.CENTER_X
    imgLogo.y = _G.TOP_AFTER_STATUS_BAR + imgLogo.contentHeight*.5 + 20
    local bottom = imgLogo.contentBounds.yMax


    local buttons = {
        {id="scene-myClasses", imageFilename = "images/bt-my-classes.png"},
        {id="scene-myGroups", imageFilename = "images/bt-my-groups.png"},
        {id="scene-search", imageFilename = "images/bt-search.png"},
        {id="scene-newGroup", imageFilename = "images/bt-new-group.png"},
        {id="scene-invite", imageFilename = "images/bt-invite.png"},
    }


    local function onButtonRelease(e)
        print(e.target.id)
        if e.target.id then
            composer.go(e.target.id)
        end
    end

    local spacing = 10
    local groupButtons = display.newGroup()

    for i,b in ipairs( buttons ) do
        local btH = 125
        local buttonX = _G.SCREEN_W*0.25 + (i % 2 == 1 and 0 or _G.SCREEN_W*0.5)
        local buttonY = math.floor((i-1) / 2)*(btH + spacing)

        local button = _G.RB_W.newButton {
            id = b.id,
            x = buttonX,
            top = buttonY,
            width = btH,
            height = btH,
            imageColor = {1,1,1},
            imageOverColor = {1,1,1,.3},
            imageFilename = b.imageFilename,
            imageWidth = btH,
            imageHeight = btH,
            scrollViewParent = function() return sceneGroup.scrollView end,
            onRelease = onButtonRelease,
        }
        groupButtons:insert(button)
    end

    local widget = require("widget")
    local scrollViewTop = bottom
    local scrollViewHeight = _G.SCREEN_H - scrollViewTop
    local scrollView = widget.newScrollView({
        left = 0,
        top = scrollViewTop,
        with = _G.SCREEN_W,
        height = scrollViewHeight,
        horizontalScrollDisabled = true,
        --backgroundColor = _G.COLORS.lightSilver,
        hideBackground = true,
        bottomPadding = 50,
        topPadding = 20,
    })
    sceneGroup:insert(scrollView)
    sceneGroup.scrollView = scrollView

    scrollView:insert(groupButtons)




    local btSettings = _G.RB_W.newButton {
        right = _G.SCREEN_W,
        bottom = _G.SCREEN_H,
        width = 50,
        height = 50,
        imageColor = {1,1,1},
        imageOverColor = {1,1,1,.3},
        imageFilename = "images/ic-settings.png",
        imageWidth = 30,
        imageHeight = 31,
        onRelease = function()
            composer.gotoScene( "scene-account", {effect="slideRight", time=400} )
        end,
    }
    sceneGroup:insert(btSettings)

end


function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then


    elseif ( phase == "did" ) then
        composer.removeScene( "scene-login" )

    end
end


function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then


    elseif ( phase == "did" ) then


    end
end



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