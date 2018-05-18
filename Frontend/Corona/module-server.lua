local server = {}

local serverURL = "http://cmpe2-cmpe2-1sp2h8973fsvj-88e42d812a5c4f44.elb.us-west-2.amazonaws.com:8282/rest/"


server._lastRequestFailedDueToNoInternet = false -- internal variable, do not change this


-----------------------------------
-- Dev / Test variables

local SIMULATE_NO_INTERNET = false -- for testing purposes (to test the no-internet alert)
local SIMULATE_TIMEOUT = false -- for testing purposes (to test the timeout alert)

-----------------------------------


local composer = require("composer")

 -- converts a table from to a string format
local function paramToString(paramsTable)
    local str = ""
    local i = 1

    for paramName,paramValue in pairs(paramsTable) do
        --print(paramName .. ": " .. paramValue)
        if i == 1 then
            str = paramName .. "=" .. paramValue
        else
            str = str .. "&" .. paramName .. "=" .. paramValue
        end
        i=i+1
    end

    return str
end



local function hasInternet(onSuccess, onFail)
    print("testing connection")
    --if true then return onFail() end


    --------------------------------------------------
    -- Error Simulation functions

    if SIMULATE_NO_INTERNET then
        onFail({noInternet=true})
        timer.performWithDelay(20000, function()
            SIMULATE_NO_INTERNET = nil
        end)
        return
    end

    if SIMULATE_TIMEOUT then
        onSuccess()
        timer.performWithDelay(20000, function()
            SIMULATE_TIMEOUT = nil
        end)
    end

    -------------------------

    local function testResult( event )
        if ( event.isError ) then
            onFail({noInternet=true})
        else
            onSuccess()
        end
    end


    local params = {}
    params.timeout = 3
    return network.request("https://www.google.com","GET",testResult, params)
end

-- function that gets a JSON from a server
local getJSON
getJSON = function(endpoint, params, onCompleteDownload, method, onProgress, silentRequest )

    local method = method or "GET"

    local url = serverURL .. endpoint
    params = params or {}

    -- common parameters to all requests
    --params["deviceId"] = system.getInfo( "deviceID" ) or "00000"

    local paramsString
    if params then
        if method == "GET" then
            paramsString = paramToString(params)
        else
            paramsString = require("json").encode(params)
        end
    else
        paramsString = ""
    end
    print("paramsString=", paramsString)



    local function showDownloadErroAlert(errorTitle, errorMessage)
        native.setActivityIndicator( false )
         -- Handler that gets notified when the alert closes
        local function onComplete( event )
           if event.action == "clicked" then
                local i = event.index
                if i == 1 then
                    -- Retrying....
                    getJSON(endpoint, params, onCompleteDownload, method, onProgress, silentRequest )
                    return
                elseif i == 2 then
                    -- local composer = require "composer"
                    -- if composer.getSceneName( "current" ) ~= "scene-main" then
                    --     composer.gotoScene( "scene-main", {effect="slideLeft", time=400} )
                    -- end

                    return --native.requestExit()
                end
            end
        end
        if silentRequest ~= true then
            BUTTONS_DISABLED = false
            local alert = native.showAlert( errorTitle, errorMessage , { "Try again", "I will try again later" }, onComplete )
        end
    end

    local function handleNetworkProblem()
        print("on handleNetworkProblem")
        hasInternet(
            function()
                local isOverlayAlreadyOnScreen = composer.getSceneName("overlay") == "scene-overlay-noInternet"
                if isOverlayAlreadyOnScreen then
                    composer.hideOverlay()
                end
                showDownloadErroAlert( "Oopps", "Something went wrong trying to communicate with the server.")
            end,
            function()
                server._lastRequestFailedDueToNoInternet = true
                --showDownloadErroAlert( "No Internet connection", "Please make sure that you are connected to internet.")

                local isOverlayAlreadyOnScreen = composer.getSceneName("overlay") == "scene-overlay-noInternet"
                if not isOverlayAlreadyOnScreen then
                    composer.showOverlay( "scene-overlay-noInternet")
                end
                timer.performWithDelay(3000, function() -- trying again automatically in 3 seconds
                    getJSON(endpoint, params, onCompleteDownload, method, onProgress, silentRequest )
                end)
            end
            )
    end

    local function networkListener( event )
        --print( "on networkListener - ", event.isError, event.status, event.phase,event.response )
        local result, data, errorMessage = false, nil, nil
        --print("_G.SIMULATE_NO_INTERNET=", _G.SIMULATE_NO_INTERNET)
         if SIMULATE_NO_INTERNET or SIMULATE_TIMEOUT then
            event.isError = true
            event.status = -1
         end
        if ( event.isError  or (event.phase == "ended" and event.status ~= 200)) then
            print( "Network error! - ", event.isError, event.status) --, event.phase,event.response )

            errorMessage = "Something went wrong trying to communicate with the server."

            return handleNetworkProblem()
        end


        if server._lastRequestFailedDueToNoInternet then
            local isOverlayAlreadyOnScreen = composer.getSceneName("overlay") == "scene-overlay-noInternet"
            if isOverlayAlreadyOnScreen then
                composer.hideOverlay()
            end
        end


        if ( event.phase == "began" ) then
            if ( event.bytesEstimated <= 0 ) then
                print( "Download starting, size unknown" )
            else
                print( "Download starting, estimated size: " .. event.bytesEstimated )
            end

        elseif ( event.phase == "progress" ) then
            if ( event.bytesEstimated <= 0 ) then
                print( "Download progress: " .. event.bytesTransferred )
            else
                print( "Download progress: " .. event.bytesTransferred .. " of estimated: " .. event.bytesEstimated )
            end
            if onProgress then
                local percentComplete = nil
                if event.bytesTransferred and event.bytesEstimated and event.bytesEstimated > 0 then
                    percentComplete = event.bytesTransferred / event.bytesEstimated
                end
                onProgress(percentComplete)
            end

        elseif ( event.phase == "ended" ) then

            print("Network ok. Now let's decode the JSON")
            local response = event.response  --:gsub("&#8211;", "-")  -- manually replacing a HTML code for its chair
            print("response=", response)
            local data = require("json").decode(response)


            if data == nil or type(data) ~= "table" then
                print("Data is not a valid JSON")

                -- Handler that gets notified when the alert closes
                -- local function onComplete( event )
                --    if event.action == "clicked" then
                --         local i = event.index
                --         if i == 1 then
                --             -- Retrying....
                --             getJSON(endpoint, params, onCompleteDownload)
                --             return
                --         elseif i == 2 then

                --             return --native.requestExit()
                --         end
                --     end
                -- end
                -- if silentRequest ~= true then
                --     BUTTONS_DISABLED = false
                --     local alert = native.showAlert( "Oopps", "Something went wrong trying to communicate with the server." , { "Try again", "I will try again later" }, onComplete )
                -- end
                showDownloadErroAlert()
                return

            end


            if data["errorCode"] == 2 then
                -- request not authorized
                print("request not authorized")

                return
            end
            --print("data.success=", data.success)
            --print("data.success=", data[1].success)
            --print("result=", result)
            onCompleteDownload(data, event)
        end

    end


    local headers = {}
    local params = {}

    if method == "POST" or method == "DELETE" then
        headers["Content-Type"] = "text/plain"
        params.body = paramsString
    else
        headers["Content-Type"] = "text/plain"
        url = url .. "?" .. paramsString
    end


    params.headers = headers
    params.timeout = 30
    if onProgress then
        params.progress = "upload"
    end

    print("url=", url)
    print("params=", require("json").encode(params))
    network.request( url, method, networkListener, params)


end








--------------------------------------------
---- Public Functions


---- GROUP FUNCTIONS

server.createGroup = function(groupName, groupDescription, onSuccess, onFail)
    print("on server.createGroup")

    local params = {}
    params["name"] = groupName
    params["sid"] = _G.USER.getSchoolId()


    getJSON("create?type=group",
            params,
            function(data)
                local success = data.errorCode == nil
                --print("sucess=", success)
                if success then
                    if onSuccess then
                        onSuccess(data)
                    end
                else
                    if onFail then
                        onFail(data.errorMsg, data.errorCode)
                    end
                end

            end,
            "POST",  -- method
            nil,     -- onProgress
            false)    -- silentRequest

end


server.joinGroup = function(groupId, onSuccess, onFail)
    print("on server.createGroup")

    local params = {}
    params["admin"] = true
    params["gid"] = groupId
    params["uid"] = _G.USER.id


    getJSON("update?type=userGroup",
            params,
            function(data)
                local success = data.errorCode == nil
                --print("sucess=", success)
                if success then
                    if onSuccess then
                        onSuccess()
                    end
                else
                    if onFail then
                        onFail(data.errorMsg, data.errorCode)
                    end
                end

            end,
            "POST",  -- method
            nil,     -- onProgress
            false)    -- silentRequest

end

server.leaveGroup = function(groupId, onSuccess, onFail)
    print("on server.createGroup")

    local params = {}
    params["admin"] = true
    params["gid"] = groupId
    params["uid"] = _G.USER.id


    getJSON("del?type=userGroup",
            params,
            function(data)
                local success = data.errorCode == nil
                --print("sucess=", success)
                if success then
                    if onSuccess then
                        onSuccess(data)
                    end
                else
                    if onFail then
                        onFail(data.errorMsg, data.errorCode)
                    end
                end

            end,
            "DELETE",  -- method
            nil,     -- onProgress
            false)    -- silentRequest

end


server.getGroupMembers = function(groupId, onSuccess, onFail)

    local params = {}
    params["type"] = "group"
    params["id"] = groupId

    getJSON("item",
            params,
            function(data)
                local success = data.errorCode == nil
                --print("sucess=", success)
                if success then
                    if onSuccess then
                        onSuccess(data)
                    end
                else
                    if onFail then
                        onFail(data.errorMsg, data.errorCode)
                    end
                end

            end,
            "GET",  -- method
            nil,     -- onProgress
            false)    -- silentRequest

end

server.getPostsFromGroup = function(groupId, onSuccess, onFail)

    local params = {}
    params["type"] = "post"
    params["gid"] = groupId

    getJSON("list",
            params,
            function(data)
                local success = data.errorCode == nil
                --print("sucess=", success)
                if success then
                    if onSuccess then
                        onSuccess(data)
                    end
                else
                    if onFail then
                        onFail(data.errorMsg, data.errorCode)
                    end
                end

            end,
            "GET",  -- method
            nil,     -- onProgress
            false)    -- silentRequest

end




server.search = function(searchType, txt, onSuccess, onFail)

    local params = {}
    -- params["xxx"] = xxxx
    -- params["xxx"] = xxxx

    -- timer.performWithDelay(1000, function()
    --     local data = {}
    --     data[#data+1] = {id=1, name="SJSU"}
    --     data[#data+1] = {id=1, name="Caltech"}
    --     data[#data+1] = {id=1, name="MIT"}
    --     data[#data+1] = {id=1, name="Stanford"}
    --     onSuccess(data)
    -- end)
    -- if true then return end
    params["type"] = searchType or "user"  -- "user" or "group"
    if txt ~= "" then
        params["keyword"] = txt
    end
    params["sid"] = _G.USER.getSchoolId()


    getJSON("list",
            params,
            function(data)
                local success = data.errorCode == nil
                --print("sucess=", success)

                if success then
                    if onSuccess then
                        onSuccess(data)
                    end
                else
                    if onFail then
                        onFail(data.errorMsg, data.errorCode)
                    end
                end

            end,
            "GET",  -- method
            nil,     -- onProgress
            false)    -- silentRequest

end


server.getMyClasses = function(onSuccess, onFail)

    local params = {}
    -- params["xxx"] = xxxx
    -- params["xxx"] = xxxx

    timer.performWithDelay(1000, function()
        local classGroup = require("class-group")
        local data = {}
        data[#data+1] = classGroup.new({id=1, name="SJSU"})
        data[#data+1] = classGroup.new({id=1, name="Caltech"})
        data[#data+1] = classGroup.new({id=1, name="MIT"})
        data[#data+1] = classGroup.new({id=1, name="Stanford"})
        onSuccess(data)
    end)
    if true then return end




    getJSON("item?type=user&amp;id=2354",
            params,
            function(data)
                local success = data.errorCode == nil
                --print("sucess=", success)

                if success then
                    if onSuccess then
                        onSuccess()
                    end
                else
                    if onFail then
                        onFail(data.errorMsg, data.errorCode)
                    end
                end

            end,
            "GET",  -- method
            nil,     -- onProgress
            false)    -- silentRequest

end



server.login = function(email, onSuccess, onFail)

    local params = {}
    params["mail"] = email .. "@email.com"
    params["externalid"] = email


    getJSON("exlogin",
            params,
            function(data)
                local success = data.errorCode == nil
                --print("sucess=", success)
                if success then
                    if onSuccess then
                        onSuccess(data)
                    end
                else
                    if onFail then
                        onFail(data.errorMsg, data.errorCode)
                    end
                end

            end,
            "POST",  -- method
            nil,     -- onProgress
            false)    -- silentRequest

end





server.getMyClassesAndGroups = function(onSuccess, onFail)

    local params = {}
    params["type"] = "user"
    params["id"] = _G.USER.id

    getJSON("item",
            params,
            function(data)
                local success = data.errorCode == nil
                --print("sucess=", success)
                if success then
                    local classes = data.userSchools
                    local groups = data.userGroups
                    _G.USER.saveClasses(classes)
                    _G.USER.saveGroups(groups)
                    if onSuccess then
                        onSuccess()
                    end
                else
                    if onFail then
                        onFail(data.errorMsg, data.errorCode)
                    end
                end

            end,
            "GET",  -- method
            nil,     -- onProgress
            false)    -- silentRequest

end


server.newPost = function(groupId, title, txt, onSuccess, onFail)

    local params = {}

    params["gid"] = groupId
    params["title"] = title
    params["msg"] = txt
    params["uid"] = _G.USER.id


    getJSON("create?type=post",
            params,
            function(data)
                local success = data.errorCode == nil
                --print("sucess=", success)

                if success then
                    if onSuccess then
                        onSuccess(data)
                    end
                else
                    if onFail then
                        onFail(data.errorMsg, data.errorCode)
                    end
                end

            end,
            "POST",  -- method
            nil,     -- onProgress
            false)    -- silentRequest

end


server.uploadPhoto = function(filename, onSuccess, onFail)

    local s3 = require("plugin.s3-lite")

    local myS3 = s3:new({
      key = "AKIAIW2ZKHZN5ZDUPRAA",
      secret = "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",
      region = s3.US_WEST_1
    })


    local function onPutObject( evt )
      if evt.error then
        print(evt.error, evt.message, evt.status)
        onFail()
      else
        if evt.progress then
          print(evt.progress)
        else
          print("object upload complete")
          onSuccess()
        end
      end
    end

    s3:putObject(
      system.TemporaryDirectory,
      filename,
      "alumnet-images",
      filename,
      onPutObject
    )



end


return server