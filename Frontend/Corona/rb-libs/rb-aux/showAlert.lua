local rb = {}

--  v1
-- showAlert("Lorem ipsum?", { {label="Ok", handler=function() end,}, {label="Cancel", handler=function() end} }

rb.new = function(message, buttons)

    if buttons == nil then
        native.showAlert("AlumNET", message , {"Ok"})
    else
        local buttonsLabel = {}
        for i=1, #buttons do
            buttonsLabel[#buttonsLabel+1] = buttons[i].label
        end
        native.showAlert("Phelps", message , buttonsLabel, function(event)
            if ( event.action == "clicked" ) then
                local i = event.index
                if buttons[i].handler then
                    buttons[i].handler()
                end
            end
        end )

    end

end


return rb