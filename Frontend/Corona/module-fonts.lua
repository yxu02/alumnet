local fonts = {
	latoBold = "fonts/Lato-Bold",
	nunitoRegular = "fonts/Nunito-Regular",
	nunitoBold = "fonts/Nunito-Bold",
	montserratExtraBold = "fonts/Montserrat-ExtraBold",
	-- avenirHeavy = "fonts/Avenir-Heavy"
}



fonts.btStart = fonts.latoBold
fonts.btListenAudio = fonts.nunitoRegular


fonts.playerAudioTitle = fonts.nunitoBold
fonts.playerAudioNarrator  = fonts.nunitoRegular

fonts.topBarTitle = fonts.latoBold
fonts.regular = fonts.latoBold


-- local searchString = "Avenir"
-- local systemFonts = native.getFontNames()
-- print("")
-- print( "- - - FONTS - - -")
-- for i, fontName in ipairs( systemFonts ) do
--    local j, k = string.find( string.lower(fontName), string.lower(searchString) )
--    if ( j ~= nil ) then
--        print( "Font Name = " .. tostring( fontName ) )
--    end
-- end
-- print( "- - - - - - - - -")
-- print("")


return fonts