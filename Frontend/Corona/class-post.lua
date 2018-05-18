local classPost = {}


classPost.new = function(data)
	local obj = {}
	obj.id = data.id
	obj.title = data.title
	obj.message = data.message

	obj.getId = function(self)
		return self.id
	end
	obj.getTitle = function(self)
		return self.title
	end
	obj.getMessage = function(self)
		return self.message
	end

	return obj
end



return classPost
