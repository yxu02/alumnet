local composer = require( "composer" )

local scene = composer.newScene()

function scene:create( event )

    local sceneGroup = self.view

    local topBar, bottom = _G.TOPBAR.new({parent=sceneGroup, title="Search Groups"})

    local margin = 10

    local inputSearch = _G.RB_W.newTextField{parent=sceneGroup, left=margin, top=bottom + 10, width=_G.SCREEN_W*0.8, height=46, hasBackground=true, backgroundColor=_G.COLORS.white}
    local btSearch = _G.RB_W.newButton {
        left = inputSearch.x + inputSearch.contentWidth*.5 + 4,
        y = inputSearch.y,
        width = 46,
        height = 46,
        imageFilename = "images/bt-search-mini.png",
        imageWidth = 46,
        imageHeight = 46,
        imagePos = "center",
        align = "center",
        onRelease = function()
            sceneGroup.search(inputSearch:getText())
        end
    }
    sceneGroup:insert(btSearch)
    bottom = btSearch.y + btSearch.contentHeight*.5

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
        background.anchorY=0
        background:addEventListener( "tap", function()
            background.alpha = .3
            timer.performWithDelay(40, function()
                background.alpha = 1
                composer.removeScene("scene-group-inside")
                composer.go("scene-group-inside", {groupObj=rowData})
            end)
        end)
        local txt = rowData.name
        if txt then
            txt = txt .. (rowData.mail and (" (" .. rowData.mail .. ")") or "")
        else
            txt = "[private]"
        end
        local lb = display.newText{parent=row, text=txt, x=margin, y=rowH*.5, font=_G.FONTS.regular, fontSize=20 }
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
            sceneGroup.lbNoData = display.newText{parent=sceneGroup, text = "No products found.", x=CENTER_X, y=CENTER_Y, fontSize=24, width=SCREEN_W*.9, align="center" }
            sceneGroup.lbNoData.fill = _G.COLORS.black
        end


        for i = 1, #data do
            tableView:insertRow{
                --rowHeight = 100,
                rowHeight = 40,
                rowColor =  { default={1,1,1,0}, over={1,0.5,0,0} },
            }
        end
    end


    sceneGroup.search = function(txt)
        native.setActivityIndicator( true )
        local searchType = "group"
        _G.SERVER.search(searchType, txt,
            function(data)
                native.setActivityIndicator( false )
                updateTableViewData(data)
            end,
            function()
                native.setActivityIndicator( false )
                native.showAlert( "AlumNET", "Failed to search product. Please try again later.", "Ok" )
         end)
    end



--sceneGroup.search(inputSearch:getText())

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