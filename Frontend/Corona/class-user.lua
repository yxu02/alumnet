local user = {}

local keychain = require("plugin.keychain")

user.id = keychain.get("id")
user.email = keychain.get("email")
user.name = keychain.get("name")
user.token = keychain.get("token")



user.isLoggedIn = function()
	return (user.id ~= nil or user.token ~= nil)
end


user.new = function(id, username, name, email)
	user.id = id
	user.email = email
	user.name = name
	user.token = username
	keychain.set("id", id)
	keychain.set("email", email)
	keychain.set("name", name)
	keychain.set("token", token)

end


user.logout = function()
	print("user.email=", user.email)
	local pluginCognito = require "plugin-cognito"
    pluginCognito.logout(user.email)

    user.id = nil
	user.name = nil
	user.email = nil
	user.token = nil

	keychain.set("id", nil)
	keychain.set("email", nil)
	keychain.set("name", nil)
	keychain.set("token", nil)


	require("composer").gotoScene("scene-login", { effect="slideRight", time=400})
end

user.getPhotoUrl = function(self)
	--return "https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg"
	return "https://s3-us-west-1.amazonaws.com/alumnet-images/" .. self:getPhotoFilename()
end

user.getPhotoFilename = function(self)
	return tostring(self.id) .. ".jpg"
end

user.saveClasses = function(data)
	user.classes = data
end

user.saveGroups = function(data)
	user.groups = data
end

user.getSchoolId = function()
	return 2369
end

user.amIMemberOfGroup = function(groupId)
	if user.groups then
		for _, v in ipairs(user.groups) do
			if (v.id and v.id == groupId) or (v.group and v.group.id and v.group.id == groupId) then
				return true
			end
		end
	end
	return false
end


return user