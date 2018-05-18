-- v5
-- creates a RB-Table which is basically a lua table with extra handy functions
--
-- How to use:  Instead of creating a table as using {}, just use T{}
--
-- Inpired by @Michal Kottman answer to Stackover flow question avaiable at: https://stackoverflow.com/questions/12670985/luahow-to-create-a-custom-method-on-all-tables
--
--
-- v5: improved table.clone to avoid circle references
-- v4: added table.clone; table.dump
---

---------------------
-- new functions

-- retuns if the table is empty. Works for both associative (dic) and non-associative (list) arrays
function table.isEmpty(tabl)
    local isEmpty = (next(tabl) == nil)
    return isEmpty
end

function table.isNotEmpty(tabl)
    return (not table.isEmpty(tabl))
end

function table.size(tabl)
	if tabl == nil then
		error("Trying to get size of nil table. Make sure to call size using myDic:size() instead of myDic.size()")
	end
	local c = 0
	for _,_ in pairs(tabl) do
		c=c+1
	end
    return (c)
end
table.count = table.size

function table.getFirstKeyValue(tabl)
	for k,v in pairs(tabl) do
		return k,v
	end
end
function table.getFirstKey(tabl)
	local k, v = table.getFirstKeyValue(tabl)
	return k
end
function table.getFirstValue(tabl)
	local k, v = table.getFirstKeyValue(tabl)
	return v
end


function table.toList(tabl)
	local l = {}
	for _,v in pairs(table) do
		l[#l+1] = v
	end
	return l
end

-- creates a new cloned table from an existing one
table.clone = function(tabl, level)
	--print("table.clone - ", tabl, level)
	local t = {}
	if level == nil then -- we are at the top level (not in a recursive loop)
		level = 0
		table._cloneNewTableRef = {}
	end
	table._cloneNewTableRef[tabl] = t -- hold references to new cloned table so we avoid any circle references.
	for k, v in pairs(tabl) do
		if type(v) == "table" then
			if table._cloneNewTableRef[v] then
				t[k] = table._cloneNewTableRef[v]
			else
				--print("k,v=", k,v)
				t[k] = table.clone(v,level + 1)
			end
		else
			t[k] = v
		end
	end
	if level == 0 then
		table._cloneNewTableRef = nil
	end
	return t
end


function table.dump(tabl, label)
	print()
	print("- - - table dump " .. (label and ("- " .. label .. " - ") or "" )..  "[" .. tostring(tabl) .. "]  (begin) - - - ")
	print(require("json").prettify( tabl or {} ))
	print("- - - table dump (end) - - - ")
	print()
end



---------------------
-- constructor

local table_meta = { __index = table }
function T(t)
    -- returns the table passed as parameter or a new table
    -- with custom metatable already set to resolve methods in `table`
    return setmetatable(t or {}, table_meta)
end