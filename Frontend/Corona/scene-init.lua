local composer = require( "composer" )

local scene = composer.newScene()


function scene:create( event )

    local sceneGroup = self.view

    local logoCircle = display.newImageRect(sceneGroup, "images/logo-circle.png" , 116, 96)
    logoCircle.x = _G.CENTER_X
    logoCircle.y = _G.CENTER_Y
    local scaleFactor = 49/96
    local endLeft = _G.CENTER_X - 238/2




    transition.from(logoCircle,{alpha=0, time=3000,transition=easing.inOutExpo, onComplete=function()
        transition.to(logoCircle,{xScale=scaleFactor, yScale=scaleFactor, y=_G.SCREEN_H*.15, x=CENTER_X - 238/2 + 116*scaleFactor/2, time=300, onComplete=function()
            -- if _G.USER.token then
            --   composer.gotoScene("scene-main")

            -- else
               composer.gotoScene("scene-login", {effect="crossFade", time=400})
            -- end

        end})

    end})

end


-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then


    elseif ( phase == "did" ) then

        local hasAccessToCamera, hasCamera = media.hasSource( media.Camera )
        if hasAccessToCamera then
            print( "Has camera permission!" )
        end

        -- Make the actual request from the user.
        native.showPopup( "requestAppPermission", {
            appPermission = "Camera",
            urgency = "Critical",
            --rationaleTitle = reasonTitle,
            --rationaleDescription = reasonMessage,
            listener = function()

            end,
        } )


    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        Runtime:removeEventListener('internet', onInternet)
        Runtime:removeEventListener('download', onDownload)
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
