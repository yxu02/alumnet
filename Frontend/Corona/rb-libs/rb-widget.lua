local cw = {}


-- protected 'require' function so we don't throw error when file does not exist
function pRequire( filename )

    local success, result = pcall( function(filename)
                                        return require(filename)
                                    end,
                                    filename)
    --print("success=", success, result)
    if success then
        return result
    end
    error( "RB Library '".. filename .. "' not found. Please make sure the file exist or download it.")
    return nil
end


    -- making the mapView properties accessable directly thru the map object
    local mt = {
        -- __newindex = function(...)
        --     local args={...}
        --     local key = args[2]

        --     if propertiesToExport[key] then
        --         local value = args[3]
        --         mapView[key] = value
        --         return
        --     end
        --     return omt.__newindex(...)
        -- end,
        __index = function(...)
            local args={...}
            local key = args[2]
            return pRequire("rb-libs.rb-widget."..key).new
        end,
    }
    setmetatable( cw, mt )

return cw


