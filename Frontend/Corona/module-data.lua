--[[
    Module responsible for the logic of downloading and keeping data
--]]

-- for now we will be just reading from a sample json data
-- later you will download it from a remote location and check for updates

--local data = _G.RB_S.get("data/sample.json", nil, true)
local data = _G.RB_S.get("data/app_israel.json", nil, true)

table.sort(data.pointsOfInterest, function(a,b)
	return a.pt.title < b.pt.title
end)

return data
