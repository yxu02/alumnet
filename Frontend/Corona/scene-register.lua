local composer = require( "composer" )

local scene = composer.newScene()



function scene:create( event )

    local sceneGroup = self.view

    local title = display.newImageRect(sceneGroup, "images/logo.png", 238, 49)
    title.x,title.y = _G.CENTER_X, _G.SCREEN_H*.15
    local bottom = title.y + title.contentHeight*.5


    ------------------------------------------------------------------
    -- inputs

    local groupName, inputName = _G.FRAMES.newInputWithLabelGroup(sceneGroup, bottom + 20, "Name:")

    local groupEmail, inputEmail = _G.FRAMES.newInputWithLabelGroup(sceneGroup, groupName.y + groupName.contentHeight + 20, "E-mail:")

    local groupPassword, inputPassword = _G.FRAMES.newInputWithLabelGroup(sceneGroup, groupEmail.y + groupEmail.contentHeight + 20, "Password:", false, true)





    local checkRequiredFields = function(email, password)
        local result, errorCode = _G.AUX.validateString(email, "email", 4)
        if result == false then
            local msg = "Please enter your email"
            if errorCode > 1 then
                msg = "Email used is invalid"
            end
            _G.AUX.showAlert(msg)
            return false
        end

        local result, errorCode = _G.AUX.validateString(password, "password", 1)
        if result == false then
            local msg = "Please enter a password"
            if errorCode > 1 then
                msg = "Password used is invalid"
            end
            _G.AUX.showAlert(msg)
            return false
        end

        return true
    end


    local btRegisterHandler = function()
        native.setKeyboardFocus( nil )

        -- receiving inputs
        local name = inputName:getText()
        local email = inputEmail:getText()
        local password = inputPassword:getText()

        -- checking inputs
        -- if checkRequiredFields(email, password) == false then
        --     return
        -- end


        local pluginCognito = require "plugin-cognito"

        native.setActivityIndicator( true )
        pluginCognito.signup(name, email, password,
            function(e)
                native.setActivityIndicator( false )
                print("on signup success")
                print(require("json").encode(e))
                _G.USER.new(2357, email,name,email)
                _G.RB_A.showAlert("Account created with success! Please validate your email and proceed to login.")
                _G.BACK.goBack()
            end, function(e)
                print("on signup failed")
                native.setActivityIndicator( false )
                _G.RB_A.showAlert("Registration failed" .. (e.errorMessage and (" (" .. e.errorMessage .. ")") or ""))
            end)


        -- _G.SERVER.login(email, password,
        --     function()
        --         composer.gotoScene( "scene-main", {effect="slideLeft", time=400})
        --     end,
        --     function(errorMsg)
        --         _G.AUX.showAlert(errorMsg)
        --     end)

    end


    local btRegister = _G.RB_W.newButton {
        x = _G.CENTER_X,
        top = groupPassword.y + groupPassword.contentHeight + 20,
        width = 160,
        height = 44,
        backgroundColor = _G.COLORS.btBackground,
        backgroundOverColor = _G.COLORS.primaryOver,
        label = "Register",
        labelFontSize = 20,
        labelFont = _G.FONTS.btListenAudio,
        labelColor = _G.COLORS.btLabel,
        labelOverColor = _G.COLORS.overlay("white"),
        align = "center",
        onRelease = btRegisterHandler
    }
    sceneGroup:insert(btRegister)


    local btSettings = _G.RB_W.newButton {
        left = 10,
        bottom = _G.SCREEN_H,
        width = 50,
        height = 50,
        imageColor = {1,1,1},
        imageOverColor = {1,1,1,.3},
        imageFilename = "images/bt-back.png",
        imageWidth = 60,
        imageHeight = 22,
        onRelease = function()
            _G.BACK.goBack()
        end,
    }
    sceneGroup:insert(btSettings)



end



function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then


    elseif ( phase == "did" ) then


    end

end



function scene:hide( event )
    print("on scene hide")
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then


    elseif ( phase == "did" ) then


    end
end



function scene:destroy( event )
    print("on scene destroy")
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