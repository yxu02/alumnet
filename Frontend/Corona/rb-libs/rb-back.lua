------------------------------------------
-- Red Beach Library
-- Library: BackLib
-- v 0.5   ()
--
--
-- Dependencies:
--  . rb-queue
--  . rb-table
------------------------------------------
--
--    How to use:
--
--    1) Require the rb-back in the main file (e.g _G.BACK = require "rb-back"). All scenes will be automatically added to the queue
--    2) Optional: If you want to not have a scene accessible from the Back flow, just call .ignoreScene() on the show-will of that scene
--
--
--
-- v0.5: restructure the library to automatically add all scenes to the Queue (no need to call addPreviousScene anymore); created function ignoreScene();
-- v0.46: added externalBackFunction return options
--
--



-------------------------------------------------------
-- back key handling functionality
-------------------------------------------------------

local rb = {}


local queue = require "rb-libs.rb-queue"    -- creates a LIFO queue to store the scenes and it params
rb.lastGoToSceneArgs = {}                   -- will temporarily store the last scenes params used
rb.lastSceneThatAddBackWasCalled = nil      -- will temporarily store the last scene when addBack was called
rb.lastGoToSceneIsBack = nil                -- flag that indicates if the goToScene is a back movement or not
rb.externalBackFuction = nil                -- external function defined by the user to serve as the "normal" back behavior. It should return true (to make the the normal back function also runs). It can return a 2nd response to indicate that the it should NOT pop the queue.


rb._lastSceneShowEffect = nil

-- list of opposite effect to be used when going to back scene

local oppositeEffects = {}

oppositeEffects.zoomOutIn = "zoomInOut"
oppositeEffects.zoomInOut = "zoomOutIn"
oppositeEffects.zoomOutInFade = "zoomInOutFade"
oppositeEffects.zoomInOutFade = "zoomOutInFade"
oppositeEffects.zoomOutInRotate = "zoomInOutRotate"
oppositeEffects.zoomInOutRotate = "zoomOutInRotate"
oppositeEffects.zoomOutInFadeRotate = "zoomInOutFadeRotate"
oppositeEffects.zoomInOutFadeRotate = "zoomOutInFadeRotate"
oppositeEffects.fromRight = "slideRight"
oppositeEffects.fromLeft = "slideLeft"
oppositeEffects.fromTop = "slideUp"
oppositeEffects.fromBottom = "slideDown"
oppositeEffects.slideLeft = "slideRight"
oppositeEffects.slideRight = "slideLeft"
oppositeEffects.slideUp = "slideDown"
oppositeEffects.slideDown = "slideUp"


local function getOppositeEffect(effect)
    print("on getOppositeEffect - ", effect)
    if effect == nil then
        return nil
    end

    local oppositeEffect = oppositeEffects[effect]
    print("oppositeEffect=", oppositeEffect)
    return oppositeEffect or effect
end


local function getLastOppositeEffect()
    return getOppositeEffect(rb._lastSceneShowEffect)
end

local composer = require("composer")





local goToBackScene = function(extraParams)

    native.setKeyboardFocus( nil ) -- hiding keyboard

    -- if the user defined a external function to server as back, call it. This will not impact the queue scenes
    if rb.externalBackFuction then
        print("[rb-back] lets call user custom back function")
        local shouldContinueRunning, shouldNotPopQueue = rb.externalBackFuction()
        if not shouldContinueRunning then
            if not shouldNotPopQueue then
                queue.pop()
            end
            return true
        end
        --print('BACK, CONTINUING NORMAL BACK FUCNTION -', shouldContinueRunning, shouldNotPopQueue)
    end



    local lastVisitedScene = queue.pop() -- gets the last scene visited (that had the addPreviousScene function called)
    --print("[rb-back] lastVisitedScene=", require("json").encode(lastVisitedScene))
    if lastVisitedScene == nil then print("[rb-back] no previous scene was added - please double check flow"); return end

    while lastVisitedScene == nil or lastVisitedScene.name == composer.getSceneName( "current" ) do
        if lastVisitedScene == nil then print("[rb-back] no previous scene was added - please double check flow"); return end
        if lastVisitedScene.name == composer.getSceneName( "current" ) then print("[rb-back] previous scene is the same current scene. Let's get the previous of that"); end
        lastVisitedScene = queue.pop() -- gets the last scene visited (that had the addPreviousScene function called)
    end

    if table.clone == nil then
        error("[rb-back] this library requires rb-table as dependecy")
    end

    local lastVisitedSceneOriginalData = table.clone(lastVisitedScene)

    if lastVisitedScene.options == nil then
        lastVisitedScene.options = {}
    end
    lastVisitedScene.options.isBack = true
    lastVisitedScene.options.effect = getLastOppositeEffect()
    if extraParams then
        lastVisitedScene.options.params = lastVisitedScene.options.params or {}
        for k,v in pairs(extraParams) do
            lastVisitedScene.options.params[k] = v
        end
    end

    rb._lastGoToSceneData = lastVisitedSceneOriginalData

    rb.externalBackFuction = nil

    -- bypassing the normal composer.gotoScene (which would trigger our gotoScene trap)
    rb.gotoScene(lastVisitedScene.sceneName, lastVisitedScene.options)

    return true

end




-----
-- onKeyEvent: handles the hardware button on android devices
-- @param event
-- @return

local onKeyEvent = function( event )
    --print("running: aux, onKeyEvent - keyName:", event.keyName, " - keyPhase: ", event.phase)

    if event.keyName == "back" then --or ("b" == event.keyName and system.getInfo("environment") == "simulator") then
        local returnValue = false       -- use default key operation

        local currentSceneName = composer.getSceneName( "current" ) -- or composer.getSceneName( "overlay" )

        -- if rb.lastSceneThatAddBackWasCalled ~= currentSceneName then
        --     return returnValue

        -- end

        if event.phase == "up" then
            returnValue = goToBackScene()
        end
        --print("returnValue=", returnValue)
        return returnValue
    end
end


-- Intercepts the gotoScene so it can store what kind of transition effect is being used
rb.gotoScene = composer.gotoScene
composer.gotoScene = function(sceneName, options)
    print("entrou na gotoScene custom - ",sceneName, options)

    if rb._lastGoToSceneData then
        --table.dump(rb._lastGoToSceneData)
        queue.push(rb._lastGoToSceneData)
    end
    rb._lastGoToSceneData = {}
    rb._lastGoToSceneData.sceneName = sceneName
    rb._lastGoToSceneData.options = options

    rb._lastSceneShowEffect = options and options.effect

    -- continue going to next scene
    rb.gotoScene(sceneName, options)
end


---------------------------------
-- PUBLIC FUNCTIONS
---------------------------------


-- makes the goToBackScene function public if the user wants to call it (e.g, uses as a buttonHandler)
rb.goToBackScene = goToBackScene
rb.goBack = goToBackScene





-- prevents the current scene from being added to the Queue. Call this function on the show-will of the scene that you don't want to be acessible via the BACK flow
rb.ignoreScene = function()
    local currentSceneName =  composer.getSceneName( "current" )

    if rb._lastGoToSceneData and rb._lastGoToSceneData.sceneName == currentSceneName then
        rb._lastGoToSceneData = nil
    end
end




--------------------
-- setBackFunction: overrides the back function of this lib. This should be used to hide a group pop or something like that. If you just want to link your backButton to this lib, do NOT use this function. Use instead the function rb.goToBackScene as your buttonHanlder
-- @param externalBackFunction: external function defined by the user to serve as the "normal" back behavior
-- @return
rb.setBackFunction = function(externalBackFunction)
    rb.externalBackFuction = externalBackFunction
end

------------------
-- cancelBackFunction: cancel the override back function to this lib
rb.cancelBackFunction = function()
    rb.externalBackFuction = nil
end



rb.clearData = function()
    queue.clear()
end



Runtime:addEventListener( "key", onKeyEvent )

return rb


