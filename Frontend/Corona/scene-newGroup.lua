local composer = require( "composer" )

local scene = composer.newScene()

function scene:create( event )

    local sceneGroup = self.view

    local topBar, bottom = _G.TOPBAR.new({parent=sceneGroup, title="New Group"})

    local groupName, inputName = _G.FRAMES.newInputWithLabelGroup(sceneGroup, bottom + 20, "Name:")

    local groupDescription, inputDescription = _G.FRAMES.newInputWithLabelGroup(sceneGroup, groupName.y + groupName.contentHeight + 20, "Description:", true)

    local btCreate = _G.RB_W.newButton {
        x = _G.CENTER_X,
        top = groupDescription.y + groupDescription.contentHeight + 20,
        width = 160,
        height = 44,
        backgroundColor = _G.COLORS.btBackground,
        backgroundOverColor = _G.COLORS.primaryOver,
        label = "Create",
        labelFontSize = 20,
        labelFont = _G.FONTS.btListenAudio,
        labelColor = _G.COLORS.btLabel,
        labelOverColor = _G.COLORS.overlay("white"),
        align = "center",
        onRelease = function()
            -- composer.gotoScene("scene-list")

            local name = inputName:getText()
            local description = inputDescription:getText()

            _G.SERVER.createGroup(name, description,
                function(data)
                    native.showAlert( "AlumNET", "Group created with success!", "Ok" )
                    local gid = data.id
                    _G.SERVER.joinGroup(gid,
                        function()
                            composer.go( "scene-myGroups")
                        end,
                        function()

                        end
                    )
                end,
                function()
                    native.showAlert( "AlumNET", "An Eeror happened creating the group. Please try again later.", "Ok" )
                end)
        end
    }
    sceneGroup:insert(btCreate)


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