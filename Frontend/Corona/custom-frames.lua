local cf = {}

cf.newInputWithLabelGroup = function(parent, top, labelText, useTextBox, isSecure)

	local group = display.newGroup()

    local label = display.newText{parent=group, text=labelText or "[Label]", x=0, y=0, font=_G.FONTS.regular, fontSize=20, align="left" }
    label:setTextColor(unpack(_G.COLORS.brown))
    label.anchorX = 0
    label.anchorY = 0

    local input = _G.RB_W.newTextField{parent=group, left=0, top=label.y + label.contentHeight + 4, width=_G.SCREEN_W*0.8, height=40 + (useTextBox and 140 or 0), hasBackground=true, backgroundColor=_G.COLORS.white, useTextBox=useTextBox, isSecure=isSecure}

    if parent then
        parent:insert(group)
    end

    group.y = top
    group.x = _G.CENTER_X - group.contentWidth*.5

    return group, input
end


cf.newSectionHeader = function(parent, top, labelText)

    local data = {}
    data["Members"] = {iconFilename = "images/ic-members.png", iconW = 20, iconH = 21}
    data["Posts"] =   {iconFilename = "images/ic-posts.png",   iconW = 18, iconH = 21}

    local group = display.newGroup()

    local background = display.newRect(group, _G.CENTER_X, 20, _G.SCREEN_W, 40)
    background.fill = _G.COLORS.gray

    local iconData = data[labelText]
    local icon = display.newImageRect(group, iconData.iconFilename, iconData.iconW, iconData.iconH)
    icon.anchorX = 0
    icon.x = 10
    icon.y = background.y

    local label = display.newText{parent=group, text=labelText, x=icon.x + icon.contentWidth + 10, y=background.y, font=_G.FONTS.regular, fontSize=24, width=_G.SCREEN_W*.98, align="left" }
    label:setTextColor(unpack(_G.COLORS.brown))
    label.anchorX = 0


    if parent then
        parent:insert(group)
    end

    group.y = top

    return group, (group.y + group.contentHeight)

end


return cf