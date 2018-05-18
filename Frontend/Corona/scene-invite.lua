local composer = require( "composer" )

local scene = composer.newScene()

function scene:create( event )

    local sceneGroup = self.view

    local topBar, bottom = _G.TOPBAR.new({parent=sceneGroup, title="Invite"})

    local groupEmail, inputEmail = _G.FRAMES.newInputWithLabelGroup(sceneGroup, bottom + 20, "E-mail:")

    local groupMessage, inputMessage = _G.FRAMES.newInputWithLabelGroup(sceneGroup, groupEmail.y + groupEmail.contentHeight + 20, "Message:", true)

    local btInvite = _G.RB_W.newButton {
        x = _G.CENTER_X,
        top = groupMessage.y + groupMessage.contentHeight + 20,
        width = 160,
        height = 44,
        backgroundColor = _G.COLORS.btBackground,
        backgroundOverColor = _G.COLORS.primaryOver,
        label = "Invite",
        labelFontSize = 20,
        labelFont = _G.FONTS.btListenAudio,
        labelColor = _G.COLORS.btLabel,
        labelOverColor = _G.COLORS.overlay("white"),
        align = "center",
        onRelease = function()
            -- composer.gotoScene("scene-list")

            local email = inputEmail:getText()
            local msg = inputMessage:getText()


            -- Email popup with one file attachment
            local options =
            {
               to = email,
               subject = _G.USER.name .. " has invited you to join AlumNET",
               body = msg,
            }
            native.showPopup( "mail", options )

            -- _G.SERVER.invite(email, msg,
            --     function()
            --         native.showAlert( "AlumNET", "Invitation sent!", "Ok" )
            --     end,
            --     function()
            --         native.showAlert( "AlumNET", "An Error happened sending the invitation. Please try again later.", "Ok" )
            --     end)
        end
    }
    sceneGroup:insert(btInvite)


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