local composer = require( "composer" )

local scene = composer.newScene()

function scene:create( event )

    local sceneGroup = self.view

    local groupObj = event.params.groupObj or {}

    local topBar, bottom = _G.TOPBAR.new({parent=sceneGroup, title="New Post"})

    local lbXYZ = display.newText{parent=sceneGroup, text="Group: " .. groupObj.name, x=CENTER_X, y=bottom + 20, font=_G.FONTS.regular, fontSize=24, width=_G.SCREEN_W*.8, align="left" }
    lbXYZ:setTextColor(unpack(_G.COLORS.brown))
    lbXYZ.anchorY = 0
    bottom = lbXYZ.y + lbXYZ.contentHeight

    local groupTitle, inputTitle = _G.FRAMES.newInputWithLabelGroup(sceneGroup, bottom + 20, "Title:")

    local groupMessage, inputMessage = _G.FRAMES.newInputWithLabelGroup(sceneGroup, groupTitle.y + groupTitle.contentHeight + 20, "Message:", true)

    local btSubmit = _G.RB_W.newButton {
        x = _G.CENTER_X,
        top = groupMessage.y + groupMessage.contentHeight + 20,
        width = 160,
        height = 44,
        backgroundColor = _G.COLORS.btBackground,
        backgroundOverColor = _G.COLORS.primaryOver,
        label = "Submit",
        labelFontSize = 20,
        labelFont = _G.FONTS.btListenAudio,
        labelColor = _G.COLORS.btLabel,
        labelOverColor = _G.COLORS.overlay("white"),
        align = "center",
        onRelease = function()
            -- composer.gotoScene("scene-list")
            local title = inputTitle:getText()
            local msg = inputMessage:getText()

            _G.SERVER.newPost(groupObj.id, title, msg,
                function()
                    native.showAlert( "AlumNET", "Post submitted!", "Ok" )
                    _G.BACK.goBack()
                end,
                function()
                    native.showAlert( "AlumNET", "An Error happened sending the post. Please try again later.", "Ok" )
                end)
        end
    }
    sceneGroup:insert(btSubmit)


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