local rb = {}

--  v2
-- function: validates a string based on its chars  
-- retuns:  bool, errorCode (int)
--
--   1   text is empty
--   2   text not has minimum size
--   3   text has invalid char
--   4   email is in a invalid format


rb.new = function(text,txtType,minSize, ignoreCharsCheck)
    ----print("running: checkRestrictions for ", text,  " tyoe = ",txtType )
    local charSetList = {
            password = "abcdefghijklmnopqrswtuvxyz0123456789._-@!#$%()*+?",
            username = "abcdefghijklmnopqrswtuvxyz0123456789._-",
            email    = "abcdefghijklmnopqrswtuvxyz0123456789._-@",
            text     = "abcdefghijklmnopqrswtuvxyz 'áéíóúàèìòùãiõñêîôûäëïöü-.",
            firstName     = "abcdefghijklmnopqrswtuvxyz'áéíóúàèìòùãiõñêîôûäëïöüç",
            name     = "abcdefghijklmnopqrswtuvxyz 'áéíóúàèìòùãiõñêîôûäëïöüç-.123456789",
            phone     = "0123456789+ -()",
            date     = "0123456789/",
            currency     = "0123456789.,",
    }

    charSetList.nome = charSetList.firstName
    charSetList.sobrenome = charSetList.name
    charSetList["e-mail"] = charSetList.email
    charSetList.senha = charSetList.password

    if text == nil or text == "" then
        return false, 1
    end

    if minSize then
        if not text or text:len() < minSize then
            return false, 2
        end
    end
    
    if ignoreCharsCheck == true then
        return true
    end
    
    local charset = charSetList[txtType or "username"]
    if charset == nil then
        charset = charSetList["username"]
    end
    
    local lowerText = string.lower(text)
    ----print("testing string ",lowerText)
    for i=1, #lowerText do
        local charNow = lowerText:sub(i,i)
        ----print("lookink for",charNow )
        
        if charset:find(charNow) == nil then
      --      --print("found invalid")
            return false, 3
        end
    end
    
    if txtType == "email" or txtType == "e-mail" then
        local textLen = text:len()
        if not text or textLen < 5 then
            return false, 2
        end

        local position
        position = lowerText:find("@",1)
        if not position then -- no "@" found in the string
            return false, 4
        end
        
        local nextChar = lowerText:sub(position+1, position+1)
        --print("nextChar=", nextChar)
        if nextChar == "." then -- "." right after "@" found
            return false, 4
        end

        position = lowerText:find("@",position+1)
        if position then -- Two "@" found in the string
            return false, 4
        end
                
        position = lowerText:find(".",1, true)
        if not position then -- no "." found in the string
            return false, 4
        end
        
        local firstChar = lowerText:sub(1,1)
        if firstChar == "." or firstChar == "@" then  -- starts with "@" or "." 
            return false, 4
        end
        local lastChar = lowerText:sub(textLen,textLen)
        if lastChar == "." or lastChar == "@" then  -- finishes with "@" or "." 
            return false, 4
        end
    end
    
    return true
end

return rb