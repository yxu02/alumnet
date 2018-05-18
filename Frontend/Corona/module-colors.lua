local colors = {
	green =  {131/255, 201/255, 183/255},
	brown =  {100/255, 55/255, 	52/255 },
	yellow = {246/255, 213/255, 150/255},
	gray =   {217/255, 215/255, 210/255},
	white =  {1,1,1},
	transparent = {1,1,1,0}
}


colors.btBackground = colors.yellow
colors.btLabel = colors.brown
colors.navBarLabel = colors.white --colors.brown

-- colors.background = colors.lightBrown
-- colors.topBar = colors.darkGreen
-- colors.placeholder = colors.gray



colors.overlay = function(colorName, alpha)
	alpha = alpha or 0.7
	local color = colors[colorName]
	return {color[1], color[2], color[3], alpha}
end


return colors