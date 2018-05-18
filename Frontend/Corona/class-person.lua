local classUser = {}


classUser.new = function(data)
	local obj = {}
	obj.id = data.id
	obj.name = data.name
	obj.photoUrl = data.photoUrl

	obj.getId = function(self)
		return self.id
	end
	obj.getName = function(self)
		return self.name or '[private]'
	end

	obj.getPhotoUrl = function(self)
		--return "https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg"
		return "https://s3-us-west-1.amazonaws.com/alumnet-images/" .. self:getPhotoFilename()
	end

	obj.getPhotoFilename = function(self)
		return tostring(self.id) .. ".jpg"
	end


	obj.getProfileGroup = function(self)
		local group = display.newGroup()
		local size = 80
		local background = display.newRect(group, size*.5, size*.5,size,size)
		background.fill = _G.COLORS.gray

		local imageH = size - 20
		local photo = _G.RB_D.loadImageFromInternet{
	        parent = group,
	        imageURL = self:getPhotoUrl(),
	        imageWidth = imageH,
	        imageHeight = imageH,
	        --placeholderImageFilename  -- with path
	        placeholderBackgroundColor = {.2,.2,.2, 1},
	        keepAspectRatio = true,
	        aspectMode = "fit",
	        initialAlpha = 0,
	        allowSimultaneousDownloads = true,
	        onComplete = function(e)
	            if not e.wasCached then
	                transition.to(e.target,{alpha = 1, time=400})
	            else
	                e.target.alpha = 1
	            end
	        end
	    }
	    photo.x = background.x
	    photo.y = imageH*.5

	    local lbName = display.newText{parent=group, text=self:getName(), x=size*.5, y=size - 4, font=_G.FONTS.regular, fontSize=10, width=size, align="center" }
	    lbName.anchorY = 1
	    lbName:setTextColor(unpack(_G.COLORS.brown))

	    return group
	end

	return obj
end



return classUser
