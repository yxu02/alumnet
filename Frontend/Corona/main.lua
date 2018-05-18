--display.setStatusBar( display.HiddenStatusBar )



display.setDefault( "background", 130/255, 200/255, 182/255)


------------------------------
-- red beach library globals

require("rb-libs")



------------------------------
-- screen globals

_G.CENTER_X = display.contentCenterX
_G.CENTER_Y = display.contentCenterY
_G.SCREEN_W = display.contentWidth
_G.SCREEN_H = display.contentHeight

_G.STATUS_BAR_H = display.topStatusBarContentHeight
_G.TOP_AFTER_STATUS_BAR = _G.STATUS_BAR_H
if _G.RB_DEVICE.isPhoneX then
	_G.TOP_AFTER_STATUS_BAR = _G.TOP_AFTER_STATUS_BAR + display.safeScreenOriginY
end



_G.GROW_WITH_SCREEN_W = (_G.SCREEN_W / 375 )
_G.GROW_WITH_SCREEN_H = (_G.SCREEN_H / 667 )

_G.GROW_WITH_SCREEN = _G.GROW_WITH_SCREEN_W

------------------------------
-- module globals

_G.SERVER = require("module-server")
_G.FONTS  = require("module-fonts")
_G.COLORS = require("module-colors")
_G.TOPBAR = require("module-topBar")
-- _G.STORAGE = require("module-storage")
_G.FRAMES = require("custom-frames")


_G.USER = require "class-user"


------------------------------
-- composer

local composer = require "composer"
--composer.recycleOnSceneChange = true
composer.go = function(sceneName, params)
	composer.gotoScene( sceneName, {effect="slideLeft", time=400, params=params} )
end


composer.gotoScene("scene-init")
-- if _G.USER.token then
--   composer.gotoScene("scene-main")

-- else
--   composer.gotoScene("scene-login")
-- end

--composer.gotoScene("scene-login")
--composer.gotoScene("scene-register")
--composer.gotoScene("scene-main")
--composer.gotoScene("scene-newGroup")
--composer.gotoScene("scene-list")
--composer.gotoScene("scene-search")
--composer.gotoScene("scene-group-inside")
--composer.gotoScene("scene-account")


