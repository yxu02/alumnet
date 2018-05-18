local composer = require( "composer" )

local scene = composer.newScene()

function scene:create( event )

    local sceneGroup = self.view

    local topBar, bottom = _G.TOPBAR.new({parent=sceneGroup, title="My Groups"})

    local margin = 10


    -------------------------

    local left = margin
    local tableViewData

    local widget = require( "widget" )

    local function onRowRender( event )

        local row = event.row
        local rowH = row.contentHeight

        local rowData = tableViewData[row.index].group
        row._data = rowData

        local background = display.newRect(row, _G.CENTER_X, 0, _G.SCREEN_W, rowH-2)
        background.fill = _G.COLORS.yellow --_G.COLORS.white
        background.anchorY=0
        background:addEventListener( "tap", function()
            background.alpha = .3
            timer.performWithDelay(40, function()
                background.alpha = 1
                composer.removeScene("scene-group-inside")
                composer.go("scene-group-inside", {groupObj=rowData})
            end)
        end)

        local lb = display.newText{parent=row, text=rowData.name, x=margin, y=rowH*.5, font=_G.FONTS.regular, fontSize=20 }
        lb:setTextColor(unpack(_G.COLORS.brown))
        lb.anchorX = 0

    end

    -- Create the widget
    local tvTop = bottom + 10
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
                    --TODO here:

                    return true
                end
            end,
            --listener = scrollListener,
            topPadding = 10,
            bottomPadding = 50,
        }
    sceneGroup:insert(tableView)
    sceneGroup.tableView = tableView



    ------------------------


    local updateTableViewData = function(data)
        display.remove( sceneGroup.lbNoData )

        tableViewData = data
        tableView:deleteAllRows()


        if #data==0 then
            sceneGroup.lbNoData = display.newText{parent=sceneGroup, text = "No groups found", x=_G.CENTER_X, y=_G.CENTER_Y, fontSize=24, width=_G.SCREEN_W*.9, align="center" }
            sceneGroup.lbNoData.fill = _G.COLORS.white
        end


        for i = 1, #data do
            tableView:insertRow{
                --rowHeight = 100,
                rowHeight = 40,
                rowColor =  { default={1,1,1,0}, over={1,0.5,0,0} },
            }
        end
    end


    sceneGroup.getMyGroups = function()
        native.setActivityIndicator( true )

        _G.SERVER.getMyClassesAndGroups(
            function()
                native.setActivityIndicator( false )
                print("_G.USER.groups=")
                print(require("json").encode(_G.USER.groups))
                updateTableViewData(_G.USER.groups)
            end,
            function()
                native.setActivityIndicator( false )
                native.showAlert( "AlumNET", "Failed to get your classes. Please try again later.", "Ok" )
         end)
    end


end


function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then


    elseif ( phase == "did" ) then
        sceneGroup.getMyGroups()
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