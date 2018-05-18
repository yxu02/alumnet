local composer = require( "composer" )

local scene = composer.newScene()


function scene:create( event )

    local sceneGroup = self.view

    local topBar = require("module-topBar").new{
        title="Account Info",
        parent=sceneGroup,
        isHidden=false
    }
    local bottom = topBar.contentBounds.yMax

    local function loadUserPhoto()
        display.remove(sceneGroup.photo)
        sceneGroup.photo = nil

        local imageH = 100
        local photo = _G.RB_D.loadImageFromInternet{
            parent = sceneGroup,
            imageBaseDir = system.TemporaryDirectory,
            imageFilename = _G.USER:getPhotoFilename(),
            imageURL = _G.USER:getPhotoUrl(),
            imageWidth = imageH,
            imageHeight = imageH,
            --placeholderImageFilename  -- with path
            placeholderBackgroundColor = {.2,.2,.2, 1},
            keepAspectRatio = true,
            aspectMode = "fit",
            initialAlpha = 0,
            allowSimultaneousDownloads = true,
            onComplete = function(e)
                if not e.wasCached then
                    transition.to(e.target,{alpha = 1, time=400})
                else
                    e.target.alpha = 1
                end
            end
        }
        photo.x = _G.CENTER_X
        photo.y = topBar.contentBounds.yMax + imageH*.5 + 10
        sceneGroup.photo = photo
        bottom = photo.y + photo.contentHeight*.5
        return photo, bottom
    end
    local photo, bottom = loadUserPhoto()

    local backgroundInvisible = display.newRect(sceneGroup, _G.CENTER_X, photo.y, _G.SCREEN_W, photo.contentHeight)
    backgroundInvisible.fill = _G.COLORS.transparent
    backgroundInvisible.isHitTestable = true
    backgroundInvisible:addEventListener( "tap" , function()



        local function onComplete( event )
           print(require("json").encode(event))
           if event.completed then
                _G.SERVER.uploadPhoto(_G.USER:getPhotoFilename(),
                    function()
                        display.remove(sceneGroup.photo)
                        sceneGroup.photo = nil
                        _G.RB_A.showAlert("Photo updated with success!")
                        --loadUserPhoto()
                        timer.performWithDelay(300, loadUserPhoto)
                    end,
                    function()
                        _G.RB_A.showAlert("Photo upload failed!")
                    end
                    )
           else
                _G.RB_A.showAlert("This device does not have a Camera.")
           end
        end
        if media.hasSource( media.Camera ) then
           media.capturePhoto( {listener=onComplete, destination={filename=_G.USER:getPhotoFilename(), baseDir=system.TemporaryDirectory} } )
        else
           _G.RB_A.showAlert("This device does not have a Camera")
        end

    end)

    local lbLeft = 20
    local lbWidth = _G.SCREEN_W*0.9

    local lbName = display.newText{parent=sceneGroup, text="Name: " .. tostring(_G.USER.name), x=lbLeft, y=bottom + 40, font=FONTS.regular, fontSize=18, width=lbWidth, align="left" }
    lbName:setTextColor(unpack(_G.COLORS.brown))
    lbName.anchorX = 0
    lbName.anchorY = 0

    local lbEmail = display.newText{parent=sceneGroup, text="E-mail: " .. tostring(_G.USER.email), x=lbLeft, y=lbName.y + lbName.contentHeight*.5 + 30, font=FONTS.light, fontSize=18, width=lbWidth, align="left" }
    lbEmail:setTextColor(unpack(_G.COLORS.brown))
    lbEmail.anchorX = 0
    lbEmail.anchorY = 0

    bottom = lbEmail.contentBounds.yMax

    local btLogout = _G.RB_W.newButton {
        top = bottom + 20,
        x = _G.CENTER_X,
        width = 160,
        height = 44,
        backgroundColor = _G.COLORS.btBackground,
        backgroundOverColor = _G.COLORS.primaryOver,
        label = "Logout",
        labelFontSize = 20,
        labelFont = _G.FONTS.btListenAudio,
        labelColor = _G.COLORS.btLabel,
        labelOverColor = _G.COLORS.overlay("white"),
        align = "center",
        onRelease = _G.USER.logout,
    }
    sceneGroup:insert(btLogout)





end



function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

     elseif ( phase == "did" ) then



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