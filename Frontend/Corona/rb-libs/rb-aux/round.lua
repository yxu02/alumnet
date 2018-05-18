local rb = {}

---------------------------------------------------------------
-- Rounds a number with the decimal points specified
--
-- v1
--
------

rb.new = function( val, decimal )

  local exp = decimal and 10^decimal or 1
  return math.ceil(val * exp - 0.5) / exp

end

return rb