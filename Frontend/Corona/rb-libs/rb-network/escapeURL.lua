local rb = {}

-- v4

--
-- escape URL
--
--


rb.new = function(urlToEscape)
	if urlToEscape == nil or urlToEscape == "" then
		error("[rb-network.escapeURL] invalid url parameter. url = '" .. tostring(urlToEscape) .. "'")
	end
	if string.sub(urlToEscape,1,4) ~= "http" then
		urlToEscape = "http://" .. urlToEscape
	end
    local socketURL = require("socket.url")
    local parsedURL = socketURL.parse(urlToEscape)
    local escapedURL = socketURL.build(parsedURL)

    return escapedURL
end



return rb