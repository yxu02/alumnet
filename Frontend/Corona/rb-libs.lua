
local function requireRBLib(libName)
	return require("rb-libs.rb-" .. libName)
end

_G.BACK 	 = requireRBLib("back" )
_G.RB_D 	 = requireRBLib("display")
_G.RB_W 	 = requireRBLib("widget")
_G.RB_DEVICE = requireRBLib("device")
_G.RB_S 	 = requireRBLib("storage")
_G.RB_N 	 = requireRBLib("network")
_G.RB_A 	 = requireRBLib("aux")

requireRBLib("table")
