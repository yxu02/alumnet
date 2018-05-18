local rb = {}

-- v1

--
-- an improved version of Corona display.newImage.
--



rb.new = function(options)
     -- position
    local x = options.x
    local y = options.y
    local left = options.left
    local top = options.top

    -- size
    local width = options.w or options.width
    local height = options.h or options.height


    -- source
    local filename = options.filename
    local baseDir = options.baseDir or system.ResourceDirectory


    -- display
    local aspectMode = options.aspectMode or "fit"      -- "fit", "fill",
    local cropBoundaries = options.cropBoundaries       -- true or false
    local doNotKeepAspectRatio = options.doNotKeepAspectRatio -- true or false
    local backgroundColor = options.backgroundColor or {1,1,1,0}



    local group = display.newGroup()


    local image
    local imgW, imgH

    if doNotKeepAspectRatio then
        imgW, imgH = width, height
    else
        -- retrieving the image width and size
        local tmp = display.newImage(filename, baseDir)
        imgW, imgH = tmp.contentWidth, tmp.contentHeight
        display.remove(tmp); tmp = nil

    end

    local scaleFactor = 1
    if aspectMode == "fit" then
        scaleFactor = math.min(width/imgW, height/imgH)
    elseif aspectMode == "fill" then
        scaleFactor = math.max(width/imgW, height/imgH)
    end

    image = display.newImageRect( group, filename, baseDir, imgW*scaleFactor, imgH*scaleFactor )
    image.x, image.y = width*.5, height*.5


    -- background
    local background = display.newRect(width*.5, height*.5, width, height)
    background.fill = backgroundColor
    group:insert(1, background)


    -- positioning group
    group.x = left or (x - width*.5)
    group.y = top or (y - height*.5)


    if cropBoundaries then
        local currGroup = group
        local container = display.newContainer( width, height )
        container.x = x or (left + width*.5)
        container.y = y or (top + height*.5)
        container:insert(currGroup, true)

        -- container requires us to reset the position of its children
        background.x, background.y = 0, 0
        image.x, image.y = 0, 0

        group = container
    end


    return group
end

return rb