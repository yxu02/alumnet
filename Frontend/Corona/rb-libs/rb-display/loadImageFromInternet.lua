------------------------------------------------------------
-- Load Image From Internet
--
--  v19 *    (using imageBaseDir as default to DocumentsDirectory insteaf of TemporaryDirectory)
--
--
-- v19: added "wasCached=true" to onComplete callback to indicate when an image was loaded locally (instead of downloaded)
-- v18: trapping setFillColor calls to groupPlaceholder
-- v17: added .id property; converted onComplete to receive {target=}
--
--
------------------------------------------------------------


local rb = {}

local hasAlreadyRetried = {} -- table that will store the download retries made, in order to allow only 1 retry
local inDownload = {} -- table that will store the images being downloaded, so we don't download it again


rb.new = function(options)
    local group = options.parent
    local id = options.id
    local zIndex = options.zIndex or options.childIndex
    local imageURL = options.imageURL
    local imageWidth = options.imageWidth
    local imageHeight = options.imageHeight
    local showOnlyPlaceholder = options.showOnlyPlaceholder
    local doNotShowPlaceholder = options.doNotShowPlaceholder
    local placeholderImageFilename = options.placeholderImageFilename  -- with path
    local placeholderImageScaleFactor =  options.placeholderImageScaleFactor or 1
    local placeholderBackgroundColor = options.placeholderBackgroundColor or {1,1,1,0.3}
    local showSpinner = options.showSpinner
    local keepAspectRatio = options.keepAspectRatio
    local aspectMode = options.aspectMode or "fit" -- "fit", "fill"
    local ignoreCache = options.ignoreCache
    local onComplete = options.onComplete
    local ignoreSizeCheck = options.ignoreSizeCheck
    local allowSimultaneousDownloads = options.allowSimultaneousDownloads  -- if not true, only the  network listener of the last call will be called when download is completed

    local imageFilename = options.imageFilename  -- optional: if not specified, it will use a md5 of the url
    local imageBaseDir = options.imageBaseDir or system.DocumentsDirectory

    local disableiCloudSync = options.disableiCloudSync or disableICloudSync or disableIcloudSync
    local initialAlpha = options.initialAlpha

    if initialAlpha == nil then
    initialAlpha = 1
    end

    local composer = require("composer");
    local currentScene = composer.getSceneName( "current" )


    local url = imageURL
    local destFilename

    if url == nil or url == false then
      showOnlyPlaceholder = true
      --print("ATTENTION: NO IMAGE URL SPECIFIED!!")
    else
      destFilename = url:match( "([^/]+)$" )

      local imgFilename = destFilename
      local imgExtension = imgFilename:sub(#imgFilename - 3)
      if imgExtension:sub(1,1) == "." then imgExtension = imgExtension:sub(2) end

      -- let's use MD5 to create a unique filename based on the URL if not specified the destination filename
      destFilename = imageFilename or require( "crypto" ).digest( crypto.md5, url ) .. "." .. imgExtension

    end


    if imageWidth == nil then
      --print("ATTENTION: NO IMAGE WIDTH SPECIFIED!!")
      imageWidth = 80
    end
    if imageHeight == nil then
      --print("ATTENTION: NO IMAGE HEIGHT SPECIFIED!!")
      imageHeight = 50
    end

    -- let's try to load the image locally
    local image
    if destFilename and ignoreCache ~= true then
        image = display.newImage(destFilename, imageBaseDir)
    end
    if image then
      ----print("imaged already available locally")
      local scaleFactorW, scaleFactorH = imageWidth/image.contentWidth,imageHeight/image.contentHeight
      --image:scale(imageWidth/image.contentWidth,imageHeight/image.contentHeight)

      if keepAspectRatio then
         local scaleF
         if aspectMode == "fit" then
            scaleF = math.min(scaleFactorW, scaleFactorH)
         else
            scaleF = math.max(scaleFactorW, scaleFactorH)
         end
         image:scale(scaleF,scaleF)
      else
         image:scale(scaleFactorW, scaleFactorH)
      end

      if group then
         group:insert(image)
      end
      if onComplete then
        image.id = id
        onComplete({target=image, wasCached=true})
      end

      return image

    end


    -- image is not available locally, let's create a temporary placeholder for the image
    local groupPlaceholder = display.newGroup()
    groupPlaceholder.anchorChildren = true
    groupPlaceholder.anchorX, groupPlaceholder.anchorY = .5, .5


    local placeholder = display.newRect(groupPlaceholder, imageWidth*.5,imageHeight*.5, imageWidth, imageHeight )
    placeholder.fill = placeholderBackgroundColor
    groupPlaceholder.placeholder = placeholder
    if placeholderImageFilename then

      local imgPlaceholder = display.newImage(groupPlaceholder, placeholderImageFilename)
      --print("placeholder.contentWidth=", placeholder.contentWidth)
      imgPlaceholder:scale(placeholderImageScaleFactor,placeholderImageScaleFactor)
      imgPlaceholder.x, imgPlaceholder.y = placeholder.x, placeholder.y
      groupPlaceholder.imgPlaceholder = imgPlaceholder
    end


    local scaleF = math.min(imageWidth/placeholder.contentWidth, imageHeight/placeholder.contentHeight )
    placeholder:scale(scaleF, scaleF)
    if doNotShowPlaceholder then
      placeholder.alpha = 0
    end

    if showOnlyPlaceholder then
      return groupPlaceholder
    end

    local loading
    if showSpinner then
      if _G.AUX and _G.AUX.showLoadingAnimation then
        loading = _G.AUX.showLoadingAnimation(placeholder.x, placeholder.y, math.min(placeholder.contentWidth, placeholder.contentHeight)*.6)
        groupPlaceholder:insert(loading)
      else
        print("[rb-display.loadImageFromInternet] Warning: No _G.AUX.showLoadingAnimation function available. Not showing spinner")
      end
    end


    local function networkListener( event )

      inDownload[destFilename] = nil

     if ( event.isError ) then
         print ( "Network error - download failed" )
         -- retrying the download
         if hasAlreadyRetried[destFilename] == nil then
             hasAlreadyRetried[destFilename] = true
             timer.performWithDelay( 100, function()
                 display.loadRemoteImage( url, "GET", networkListener, destFilename, imageBaseDir, placeholder.x, placeholder.y )
             end)
         end
     else

         local downloadImage = event.target
         if downloadImage == nil then
          print("image download failed(", url,")")
          return
         end
         display.remove(loading)
         downloadImage.alpha = 0
         if groupPlaceholder == nil or groupPlaceholder.contentWidth == nil or (currentScene ~= composer.getSceneName( "current" ) and currentScene ~= "scene-loading" and composer.getSceneName( "current" ) == "scene-home") then
             -- image should not be in screen anymore
             display.remove(downloadImage)
             return
         end

         --local finalW, finalH = groupPlaceholder.contentWidth, groupPlaceholder.contentHeight
         local finalW, finalH = imageWidth, imageHeight
         local scaleFactorW = finalW / downloadImage.contentWidth
         local scaleFactorH = finalH / downloadImage.contentHeight
         -- local isPlaceholderHorizontal = (groupPlaceholder.contentWidth / groupPlaceholder.contentHeight) > 1
         -- local isImageHorizontal = (downloadImage.contentWidth / downloadImage.contentHeight) > 1
         -- if isPlaceholderHorizontal ~= isImageHorizontal and ignoreSizeCheck ~= true then
         --     --print("ATTENTION: image width/height informed appears to be inverted!")
         --     scaleFactorH = math.min(groupPlaceholder.contentWidth, groupPlaceholder.contentHeight) / math.max(downloadImage.contentWidth, downloadImage.contentHeight)
         --     scaleFactorW = scaleFactorH
         -- end

         if keepAspectRatio then
             local scaleF
             if aspectMode == "fit" then
                scaleF = math.min(scaleFactorW, scaleFactorH)
             else
                scaleF = math.max(scaleFactorW, scaleFactorH)
             end
             downloadImage:scale(scaleF,scaleF)
         else
             downloadImage:scale(scaleFactorW, scaleFactorH)
         end

         downloadImage.anchorX, downloadImage.anchorY = groupPlaceholder.anchorX, groupPlaceholder.anchorY
         downloadImage.x, downloadImage.y = groupPlaceholder.x, groupPlaceholder.y
         --print("group=", group, zIndex)
         group = group or (groupPlaceholder and groupPlaceholder.parent)
         if group then
             group:insert(zIndex or group.numChildren + 1, downloadImage)
         end
         transition.to( groupPlaceholder, { time=900, alpha = 0})
         transition.to( downloadImage, { time=1000, alpha = initialAlpha, onComplete=function()
                 display.remove(groupPlaceholder)
                 --print("removed placeholderrr - url=", url)
                 if onComplete then
                    downloadImage.id = id
                    onComplete({target=downloadImage})
                 end
          end } )

        if disableiCloudSync and imageBaseDir == system.DocumentsDirectory then
          local results, errStr = native.setSync( destFilename, { iCloudBackup = false } )
        end

     end

     --print ( "event.response.fullPath: ", event.response.fullPath )
     --print ( "event.response.filename: ", event.response.filename )
     --print ( "event.response.baseDirectory: ", event.response.baseDirectory )
    end



    if inDownload[destFilename] == nil or allowSimultaneousDownloads then
      inDownload[destFilename] = networkListener
      display.loadRemoteImage( url,
        "GET",
        function(e)
          if allowSimultaneousDownloads then
            networkListener(e)
          else
            inDownload[destFilename](e)
          end

        end,
        destFilename, imageBaseDir, placeholder.x, placeholder.y )
    else
      inDownload[destFilename] = networkListener -- let's update to the latest networklistener
    end

    if group then
      group:insert(zIndex or group.numChildren + 1, groupPlaceholder)
    end



    -- exposing setFillColor under placeholder group so it can work without problem with rb.NewButton when the image was not downloaded
    groupPlaceholder.setFillColor = function()
      return
    end


    return groupPlaceholder
end

return rb