local composer = require( "composer" )

local scene = composer.newScene()

function scene:create( event )

    local sceneGroup = self.view

    local groupObj = event.params and event.params.groupObj

    -- if groupObj == nil then
    --     groupObj = require("class-group").new{id=1, name="SJSU"}
    -- end

    local topBar, bottom = _G.TOPBAR.new({parent=sceneGroup, title=groupObj.name})

    local margin = 10


    -------------------------
    -- MEMBERS
    -------------------------

    local sectionMembers, bottom = _G.FRAMES.newSectionHeader(sceneGroup, bottom+10, "Members")

    local btJoin, btLeave
    btJoin = _G.RB_W.newButton {
        right = _G.SCREEN_W,
        top = sectionMembers.y,
        width = 40,
        height = sectionMembers.contentHeight,
        backgroundColor = _G.COLORS.btBackground,
        backgroundOverColor = _G.COLORS.primaryOver,
        label = "join",
        labelFontSize = 16,
        labelFont = _G.FONTS.btListenAudio,
        labelColor = _G.COLORS.btLabel,
        labelOverColor = _G.COLORS.overlay("white"),
        align = "center",
        onRelease = function()
            _G.SERVER.joinGroup(groupObj.id,
            function()
                _G.RB_A.showAlert("Success! You now joined this group")
                sceneGroup.refreshMembers()
                btJoin.isVisible = false
                btLeave.isVisible = true
                sceneGroup.getGroupDetails()
            end,
            function()
                _G.RB_A.showAlert("A problem happened joining the group. Please try again later.")
            end)
        end
    }
    sceneGroup:insert(btJoin)
    btLeave = _G.RB_W.newButton {
        right = _G.SCREEN_W,
        top = sectionMembers.y,
        width = 40,
        height = sectionMembers.contentHeight,
        backgroundColor = _G.COLORS.btBackground,
        backgroundOverColor = _G.COLORS.primaryOver,
        label = "leave",
        labelFontSize = 16,
        labelFont = _G.FONTS.btListenAudio,
        labelColor = _G.COLORS.btLabel,
        labelOverColor = _G.COLORS.overlay("white"),
        align = "center",
        onRelease = function()
            _G.SERVER.leaveGroup(groupObj.id,
            function()
                _G.RB_A.showAlert("You left the group.")
                sceneGroup.refreshMembers()
                btJoin.isVisible = true
                btLeave.isVisible = false
            end,
            function()
                --_G.RB_A.showAlert("A problem happened leaving the group. Please try again later.")
                _G.RB_A.showAlert("You left the group.")
                composer.go("scene-main")
            end)
        end
    }
    sceneGroup:insert(btLeave)

    sceneGroup.refreshMembers = function()
        btJoin.isVisible = not _G.USER.amIMemberOfGroup(groupObj.id)
        btLeave.isVisible = _G.USER.amIMemberOfGroup(groupObj.id)
    end
    sceneGroup.refreshMembers()

    local widget = require "widget"

    local scrollViewTop = bottom
    local scrollViewHeight = 100
    local scrollView = widget.newScrollView({
        x = _G.CENTER_X,
        y = scrollViewTop + scrollViewHeight / 2,
        with = _G.SCREEN_W,
        height = scrollViewHeight,
        verticalScrollDisabled = true,
        backgroundColor = _G.COLORS.lightSilver,
        leftPadding = 20,
        rightPadding = 20
    })
    sceneGroup:insert(scrollView)
    sceneGroup.scrollView = scrollView
    bottom = scrollView.y + scrollView.contentHeight*.5

    local updateMembers = function(usersList)
        print(require("json").encode(usersList))
        display.remove(scrollView._groupContent)
        scrollView._groupContent = display.newGroup()
        sceneGroup.scrollView:insert(scrollView._groupContent)

        if #usersList == 0 then
            sceneGroup.lbNoMembers = display.newText{parent=scrollView._groupContent, text = "No members yet", x=_G.CENTER_X, y=scrollViewHeight*.5, fontSize=24, width=_G.SCREEN_W*.9, align="center" }
            sceneGroup.lbNoMembers.fill = _G.COLORS.brown
            return
        end

        for i, u in ipairs(usersList) do
            local person = require("class-person").new(u.user)
            local profile = person:getProfileGroup()
            print("photo=", profile)
            scrollView._groupContent:insert(profile)
            profile.x = (i==1) and 10 or scrollView._groupContent.contentWidth + 10
            profile.y = scrollViewHeight*.5 - profile.contentHeight*.5
        end


    end

    local a = {}
    a[#a+1] = require("class-person").new{name="Renato"}
    a[#a+1] = require("class-person").new{name="Gene"}
    a[#a+1] = require("class-person").new{name="Lin"}
    a[#a+1] = require("class-person").new{name="Renato"}
    a[#a+1] = require("class-person").new{name="Gene"}
    a[#a+1] = require("class-person").new{name="Lin"}

--    updateMembers(a)




    -------------------------
    -- POSTS
    -------------------------


    local sectionPosts, bottom = _G.FRAMES.newSectionHeader(sceneGroup, bottom, "Posts")
    local btNewPost= _G.RB_W.newButton {
        right = _G.SCREEN_W,
        top = sectionPosts.y,
        width = 40,
        height = sectionPosts.contentHeight,
        backgroundColor = _G.COLORS.btBackground,
        backgroundOverColor = _G.COLORS.primaryOver,
        label = "+",
        labelFontSize = 26,
        labelFont = _G.FONTS.btListenAudio,
        labelColor = _G.COLORS.btLabel,
        labelOverColor = _G.COLORS.overlay("white"),
        align = "center",
        onRelease = function()
            composer.go( "scene-newPost",{groupObj=groupObj})
        end
    }
    sceneGroup:insert(btNewPost)



    -------------------------

    local left = margin
    local tableViewData

    local widget = require( "widget" )

    local function onRowRender( event )

        local row = event.row
        local rowH = row.contentHeight

        local rowData = tableViewData[row.index]
        row._data = rowData

        local background = display.newRect(row, _G.CENTER_X, 0, _G.SCREEN_W, rowH-2)
        background.fill = _G.COLORS.yellow --_G.COLORS.white
        background.anchorY = 0
        background:addEventListener( "tap", function()
            background.alpha = .3
            timer.performWithDelay(40, function()
                background.alpha = 1
            end)
        end)

        local lbTitle = display.newText{parent=row, text=rowData.title, x=margin, y=4, font=_G.FONTS.regular, fontSize=20 }
        lbTitle:setTextColor(unpack(_G.COLORS.brown))
        lbTitle.anchorX = 0
        lbTitle.anchorY = 0

        local lbMessage = _G.RB_D.newText{parent=row, text=rowData.msg, x=margin, y=lbTitle.y + lbTitle.contentHeight + 4, font=_G.FONTS.regular, fontSize=12, maxWidth=SCREEN_W*0.96, limitMode="truncate" }
        lbMessage:setTextColor(unpack(_G.COLORS.brown))
        lbMessage.anchorX = 0
        lbMessage.anchorY = 0

    end

    -- Create the widget
    local tvTop = bottom
    local tvH = _G.SCREEN_H - tvTop
    local tableView = widget.newTableView{
            left = 0,
            top = tvTop,
            height = tvH,
            width = _G.SCREEN_W,
            hideBackground = true,
            backgroundColor = _G.COLORS.transparent,
            --noLines = true,
            hideScrollBar = true,
            onRowRender = onRowRender,
            onRowTouch = function(e)
                if e.phase == "tap" or e.phase == "release" then
                    --pt(e.row._data, "data=")
                    local rowData = e.row._data


                    return true
                end
            end,
            --listener = scrollListener,
            bottomPadding = 20,
        }
    sceneGroup:insert(tableView)
    sceneGroup.tableView = tableView



    ------------------------


    local updatePosts = function(data)
        display.remove( sceneGroup.lbNoData )

        tableViewData = data
        tableView:deleteAllRows()

        if #data==0 then
            sceneGroup.lbNoData = display.newText{parent=sceneGroup, text = "No posts on this group :(", x=_G.CENTER_X, y=tvTop + tvH*.5, fontSize=24, width=_G.SCREEN_W*.9, align="center" }
            sceneGroup.lbNoData.fill = _G.COLORS.brown
            return
        end


        for i = 1, #data do
            tableView:insertRow{
                rowHeight = 60,
                rowColor = { default={1,1,1,0}, over={1,0.5,0,0} },
            }
        end
    end


    sceneGroup.getGroupDetails = function()
        native.setActivityIndicator( true )


        _G.SERVER.getGroupMembers(groupObj.id,
            function(data)
                native.setActivityIndicator( false )
                updateMembers(data.groupUsers)
            end,
            function()
                native.setActivityIndicator( false )
                native.showAlert( "AlumNET", "Failed to get your classes. Please try again later.", "Ok" )
         end)


        _G.SERVER.getPostsFromGroup(groupObj.id,
            function(data)
                native.setActivityIndicator( false )
                updatePosts(data)
            end,
            function()
                native.setActivityIndicator( false )
                native.showAlert( "AlumNET", "Failed to get your classes. Please try again later.", "Ok" )
         end)
    end


    -- local a = {}
    -- a[#a+1] = require("class-post").new{title="Soccer tomorrow", message="Lorem ipsum magnum rosevarium"}
    -- a[#a+1] = require("class-post").new{title="Reunion", message="Lorem ipsum magnum rosevarium"}
    -- a[#a+1] = require("class-post").new{title="Graduation party", message="Lorem ipsum magnum rosevarium ipsum magnum rosevarium ipsum magnum rosevarium"}
    -- a[#a+1] = require("class-post").new{title="My new phone", message="Hi. Just want to inform that I got a new phone"}


    -- updatePosts(a)

end


function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then


    elseif ( phase == "did" ) then
        sceneGroup.getGroupDetails()
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