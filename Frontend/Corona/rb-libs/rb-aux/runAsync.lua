local rb = {}

--------------------------------------------------------
-- v3
--
--
-- v3: added onProgress listener
--
--


rb.new = function(listOfFunctionsToRun, onProgress)
    if listOfFunctionsToRun == nil or #listOfFunctionsToRun == 0 then
        error("[rb-aux.runAsync] list of functions passed is empty!")
    end
    local i = 0
    local numOfFunctions = #listOfFunctionsToRun
    local function runNextFunction()
        i=i+1
        if onProgress then
            onProgress(i, numOfFunctions)
        end
        if listOfFunctionsToRun[i] then
            return listOfFunctionsToRun[i](runNextFunction)
        end
    end

    runNextFunction()
end

return rb