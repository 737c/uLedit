vKeybord ={}

vKeybord.keybordMode = 0
vKeybord.keyMode0 = "1234567890\t@-^\\;:[]\bqwertyuiopasdfghjkl\rzxcvbnm,. \3\a   \a\3/\\\f"
vKeybord.keyMode1 = "!\"#$%&\'() \t`=~|+*{}\bQWERTYUIOPASDFGHJKL\rZXCVBNM<> \3\a   \a\3?_\f"
--vKeybord.keySet = ""

vKeybord.active = false

vKeybord.updateCounter = 0
local hitKeyId = -1

Layers.system_vKeybord_isloaded = true

--local buttonX = 0
-- buttonY = 0
local pressedKey = ""
local CtrlKey = ""

vKeybord.switch = function()
    if vKeybord.active == true then
        vKeybord.off()
    elseif vKeybord.active == false then
        vKeybord.on()
    end
    --Debug.print("hello: " .. tostring(vKeybord.active))
end

vKeybord.on = function()
    vKeybord.active = true
    vKeybord.updateCounter = 1
end

vKeybord.off = function()
    vKeybord.active = false
    vKeybord.updateCounter = 1
    Layers.drawNothing()
end

vKeybord.update = function()
    if vKeybord.active == false then
        return "", ""
    end
    

    pressedKey =""

    if vKeybord.keybordMode == 0 then
        keybordStr = vKeybord.keyMode0
    elseif vKeybord.keybordMode == 1 then
        keybordStr = vKeybord.keyMode1
    end

    -- draw and detect vKeybord
    i = 0
    while i < 60 do
        local buttonX = (i%10) * 25
        local buttonY = ((math.floor(i/10))*25)+36

        -- if the button is pressed
        keyLetter = string.sub(keybordStr, i+1,i+1)

        if ((Stylus.held)or(Stylus.newPress))and(buttonX+1 < Stylus.X)and(Stylus.X < buttonX+25)and(buttonY+1 < Stylus.Y)and(Stylus.Y < buttonY+25) then
            if Stylus.newPress then
                if keyLetter == "\f" then
                    if vKeybord.keybordMode == 0 then
                        vKeybord.keybordMode = 1
                    elseif vKeybord.keybordMode == 1 then
                        vKeybord.keybordMode = 0
                    end
                elseif keyLetter == "\3" then
                    if vKeybord.keybordMode == 0 then
                        vKeybord.keybordMode = 2
                    elseif vKeybord.keybordMode == 2 then
                        vKeybord.keybordMode = 0
                    end
                else
                    if vKeybord.keybordMode == 2 then
                        CtrlKey = keyLetter
                    else
                        pressedKey = keyLetter
                    end
                end
                vKeybord.updateCounter = 2
                hitKeyId = i
                break
            end
        end        

        i = i + 1
    end

    
    return pressedKey, CtrlKey
end

vKeybord.draw = function(screenId)
    screenId = 4
    if vKeybord.active == false then
        return
    end

    if vKeybord.keybordMode == 0 then
        keybordStr = vKeybord.keyMode0
    elseif vKeybord.keybordMode == 1 then
        keybordStr = vKeybord.keyMode1
    end

    --Controls.read()
    

    -- draw and detect vKeybord
    local i = 0
    while i < 60 do
        local buttonX = (i%10) * 25
        local buttonY = ((math.floor(i/10))*25)+36

        -- if the button is pressed
        local keyLetter = string.sub(keybordStr, i+1,i+1)
        
        --if keyInput == keyLetter then
        if hitKeyId == i then
            Layers.drawBox(screenId, buttonX+1, buttonY+1, 24, 24, true, Color.new(31, 23, 23))
            Layers.drawText(screenId, buttonX+5, buttonY+5, string.sub(keybordStr, i+1,i+1), Color.new(0, 0, 0))
        else
            Layers.drawBox(screenId, buttonX+1, buttonY+1, 24, 24, true, Color.new(31, 31, 31))
            Layers.drawText(screenId, buttonX+5, buttonY+5, keyLetter ,Color.new(0, 0, 0))
        end
        if vKeybord.keybordMode == 2 then
            if keyLetter == "\3" then
                Layers.drawBox(screenId, buttonX+1, buttonY+1, 24, 24, true, Color.new(31, 23, 23))
                Layers.drawText(screenId, buttonX+5, buttonY+5, string.sub(keybordStr, i+1,i+1), Color.new(0, 0, 0))
            end
        end
        

        i = i + 1
    end

    hitKeyId = -1
end
