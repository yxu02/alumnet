local composer = require( "composer" )

local scene = composer.newScene()



function scene:create( event )

    local sceneGroup = self.view

    local title = display.newImageRect(sceneGroup, "images/logo.png", 238, 49)
    title.x,title.y = _G.CENTER_X, _G.SCREEN_H*.15
    local bottom = title.y + title.contentHeight*.5
    sceneGroup.title = title

    ------------------------------------------------------------------
    -- inputs

    local groupEmail, inputEmail = _G.FRAMES.newInputWithLabelGroup(sceneGroup, bottom + 20, "E-mail:")

    local groupPassword, inputPassword = _G.FRAMES.newInputWithLabelGroup(sceneGroup, groupEmail.y + groupEmail.contentHeight + 20, "Password:", false, true)
    local bottom = groupPassword.y + groupPassword.contentHeight
    local btForgotPassword = _G.RB_W.newButton {
        x = _G.CENTER_X,
        top = bottom,
        width = 160,
        height =30,
        backgroundColor = _G.COLORS.transparent,
        backgroundOverColor = _G.COLORS.transparent,
        label = "Forget password?",
        labelFontSize = 14,
        labelFont = _G.FONTS.btListenAudio,
        labelColor = _G.COLORS.btLabel,
        labelOverColor = _G.COLORS.overlay("white"),
        align = "center",
        onRelease = function()
            if inputEmail:getText() == "" then
                _G._G.RB_A.showAlert("Please enter your e-mail in the specified field and press Forget Password again")
                return
            end
            _G._G.RB_A.showAlert("A new password reset link was sent to your email.")
        end
    }
    sceneGroup:insert(btForgotPassword)
    bottom = btForgotPassword.y + btForgotPassword.contentHeight*.5


    local checkRequiredFields = function(email, password)
        local result, errorCode = _G.RB_A.validateString(email, "email", 4)
        if result == false then
            local msg = "Please enter your email"
            if errorCode > 1 then
                msg = "Email used is invalid"
            end
            _G.RB_A.showAlert(msg)
            return false
        end

        local result, errorCode = _G.RB_A.validateString(password, "password", 1)
        if result == false then
            local msg = "Please enter a password"
            if errorCode > 1 then
                msg = "Password used is invalid"
            end
            _G.RB_A.showAlert(msg)
            return false
        end

        return true
    end


    local btLoginHandler = function()

        -- receiving inputs
        local email = inputEmail:getText()
        local password = inputPassword:getText()

        -- checking inputs
        -- if checkRequiredFields(email, password) == false then
        --     return
        -- end
        if email == "" then
            email = "genexu"
        end
        if password == "" then
            password = "Cmpe282@sjsu"
        end

        local pluginCognito = require "plugin-cognito"
        native.setActivityIndicator( true )
        pluginCognito.login(email, password,
            function(e)
                --print("on Corona side")
                --print(require("json").encode(e))
                pluginCognito.getUserDetails(function(userDetails)
                    native.setActivityIndicator( false )
                    print("on get user details")
                    print(require("json").encode(userDetails))
                    -- _G.USER.new(2370, userDetails.email,userDetails.name,userDetails.email)
                    -- composer.gotoScene( "scene-main", {effect="slideLeft", time=400})

                    _G.SERVER.login(email,
                        function(data)
                            native.setKeyboardFocus( nil )
                            print("on login callback")
                            print(require("json").encode(data))
                            _G.USER.new(data.id, email, userDetails.name, email)
                            composer.gotoScene( "scene-main", {effect="slideLeft", time=400})

                        end,
                        function(errorMsg)
                            native.setActivityIndicator( false )
                            _G.RB_A.showAlert(errorMsg or "Login failed")
                        end)


                end)

            end,
            function(e)
                native.setActivityIndicator( false )
                _G.RB_A.showAlert(e and e.errorMessage or "Login failed")
            end)

        if true then return end



        -- _G.SERVER.login(email, password,
        --     function()
        --         composer.gotoScene( "scene-main", {effect="slideLeft", time=400})
        --     end,
        --     function(errorMsg)
        --         _G.RB_A.showAlert(errorMsg)
        --     end)

    end


    local btLogin = _G.RB_W.newButton {
        x = _G.CENTER_X,
        top = bottom + 20,
        width = 160,
        height = 44,
        backgroundColor = _G.COLORS.btBackground,
        backgroundOverColor = _G.COLORS.primaryOver,
        label = "Login",
        labelFontSize = 20,
        labelFont = _G.FONTS.btListenAudio,
        labelColor = _G.COLORS.btLabel,
        labelOverColor = _G.COLORS.overlay("white"),
        align = "center",
        onRelease = btLoginHandler
    }
    sceneGroup:insert(btLogin)


    local btRegister = _G.RB_W.newButton {
        x = _G.CENTER_X,
        bottom = _G.SCREEN_H,
        width = 160,
        height = 44,
        backgroundColor = _G.COLORS.transparent,
        backgroundOverColor = _G.COLORS.transparent,
        label = "Need an account?",
        labelFontSize = 20,
        labelFont = _G.FONTS.btListenAudio,
        labelColor = _G.COLORS.btLabel,
        labelOverColor = _G.COLORS.overlay("white"),
        align = "center",
        onRelease = function()
            composer.gotoScene("scene-register", {effect="slideLeft", time=400})
        end
    }
    sceneGroup:insert(btRegister)

    -- local btLoginSS = _G.RB_W.newButton {
    --     x = _G.CENTER_X,
    --     bottom = _G.SCREEN_H,
    --     width = 160,
    --     height = 44,
    --     backgroundColor = _G.COLORS.transparent,
    --     backgroundOverColor = _G.COLORS.transparent,
    --     label = "SSO Login here",
    --     labelFontSize = 20,
    --     labelFont = _G.FONTS.btListenAudio,
    --     labelColor = _G.COLORS.btLabel,
    --     labelOverColor = _G.COLORS.overlay("white"),
    --     align = "center",
    --     onRelease = function()
    --         local pluginCognito = require "plugin-cognito"
    --         print("calling loginSSO")
    --         pluginCognito.loginSSO(
    --             function(e)
    --                 print("SSO Login callback!!!")
    --                 print(require("json").encode(e))
    --             end
    --         )


    --     end
    -- }
    -- sceneGroup:insert(btRegister)



end



function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then


    elseif ( phase == "did" ) then


        composer.removeScene( "scene-account" )
        composer.removeScene( "scene-search" )
        composer.removeScene( "scene-myClasses" )
        composer.removeScene( "scene-myGroups" )
        composer.removeScene( "scene-invite" )
        composer.removeScene( "scene-group-inside" )


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