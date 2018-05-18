local classGroup = {}


classGroup.new = function(data)
	local obj = {}
	obj.id = data.id
	obj.name = data.name

	obj.getId = function(self)
		return self.id
	end
	obj.getName = function(self)
		return self.name
	end

	return obj
end



return classGroup
