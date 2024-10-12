-- 自作バーチャルキーボードを起動
dofile("lunix/system/vKey.lua")

function main(argTable)
    local debugString = ""

    --#################################################################
    local lines = {}
    local debugString = ""
    
    local fileName = "lunix/home/Documents/text.txt"

    if argTable ~= nil then
        fileName = argTable[1]
    end

    local file = io.open(fileName, "rb")
    if file == nil then
        str = "failed to open a file: ".. fileName
        error(str)
    end
    for line in file:lines() do
        ln = #lines + 1

        lines[ln] = line
    end
    file:close()

    for i=1,#lines-1 do
        lines[i] = string.sub(lines[i], 1,-2)
    end

    if file == nil then
        lines[#lines+1] = "nofile found"
    end

    -- VirtualKeybord setup
    --vkOn = true
    --vkInt = 0;
    local vkPressedKey = ""


    local bbItem_hold = 0
    local bbItem_expand = false

    local textLineNumberDivX = 21
    local keyHoldCounterX = 0
    local keyHoldCounterY = 0
    local textDispGapY = 0
    local textPointerX = 0
    local textPointerY = 0
    --###############################################################
    
    local canvObj_debugStr = Canvas.newText(0,0,debugString,Color.new(31, 31, 31))
    
    --Canvas.add(canvas_up, canvObj_debugStr)

    --vKeybord.hitConter = 1

    vKeybord.on()
    local drawUpdate = true
    while not Keys.held.Start do
        Controls.read()

        local inputKey, CtrlKey = vKeybord.update()

        if Keys.newPress.X then
            vKeybord.switch()
        end

        -- input text =======================================
        if inputKey ~= "" then
            insStr = lines[textPointerY + 1]

            if inputKey == "\b" then
                if 0 == textPointerX then
                    if 0 < textPointerY then
                        lnPointerX = #lines[textPointerY]
                        lines[textPointerY] = lines[textPointerY] .. lines[textPointerY + 1]
                        table.remove(lines, textPointerY + 1)

                        textPointerX = lnPointerX
                        textPointerY = textPointerY - 1
                    end
                else
                    if 4 < textPointerX then
                        --if insStr:sub(textPointerX-3,textPointerX) == "    " then
                            --insStr = insStr:sub(1,textPointerX-4) .. insStr:sub(textPointerX+1)
                            --textPointerX = textPointerX - 4
                        --end

                        insStr = insStr:sub(1,textPointerX-1)..insStr:sub(textPointerX+1)
                        textPointerX = textPointerX - 1
                    else
                        insStr = insStr:sub(1,textPointerX-1)..insStr:sub(textPointerX+1)
                        textPointerX = textPointerX - 1
                    end
                    lines[textPointerY + 1] = insStr
                end

            elseif inputKey == "\r" then
                infrontSpace = ""
                for i=1,#insStr do
                    if insStr:sub(i,i) ~= " " then
                        break
                    end

                    infrontSpace = infrontSpace .. " "
                end
                
                table.insert(lines, textPointerY + 2, infrontSpace .. insStr:sub(textPointerX+1,#insStr))               
                insStr = insStr:sub(1,textPointerX)
                lines[textPointerY + 1] = insStr

                textPointerX = #infrontSpace
                textPointerY = textPointerY + 1
            elseif inputKey == "\t" then
                itrptStr = "  "
                insStr = insStr:sub(1,textPointerX)..itrptStr..insStr:sub(textPointerX+1)
                lines[textPointerY + 1] = insStr
                textPointerX = textPointerX + #itrptStr
            else
                insStr = insStr:sub(1,textPointerX)..inputKey..insStr:sub(textPointerX+1)
                textPointerX = textPointerX + 1

                lines[textPointerY + 1] = insStr
            end
        end

        -- messing with text poniter =======================================
        -- decide max tXPointer
        local tpMaxLen = #lines[textPointerY + 1]
        local ptMoveX = 0
        local ptMoveY = 0
        if Keys.newPress.Right then
            ptMoveX = 1
        end
        if Keys.newPress.Left then
            ptMoveX = -1
        end
        if Keys.newPress.Up then
            ptMoveY = -1
        end
        if Keys.newPress.Down then
            ptMoveY = 1
        end

        -- Hold related control
        local holdFixTime = 15
        if Keys.held.Down then
            if keyHoldCounterY < 0 then
                keyHoldCounterY = 0
            end
            keyHoldCounterY = keyHoldCounterY + 1
            if holdFixTime < keyHoldCounterY then
                ptMoveY = 1
            end
        elseif Keys.held.Up then
            if 0 < keyHoldCounterY then
                keyHoldCounterY = 0
            end
            keyHoldCounterY = keyHoldCounterY - 1
            if keyHoldCounterY < (holdFixTime * -1) then
                ptMoveY = -1
            end
        elseif Keys.held.Right then
            if keyHoldCounterX < 0 then
                keyHoldCounterX = 0
            end
            keyHoldCounterX = keyHoldCounterX + 1
            if holdFixTime < keyHoldCounterX then
                ptMoveX = 1
            end
        elseif Keys.held.Left then
            if 0 < keyHoldCounterX then
                keyHoldCounterX = 0
            end
            keyHoldCounterX = keyHoldCounterX - 1
            if keyHoldCounterX < (holdFixTime*-1) then
                ptMoveX = -1
            end
        else
            keyHoldCounterX = 0
            keyHoldCounterY = 0
        end

        -- when pointer has been up dated
        if ptMoveX ~= 0 then
            if (0 <= (textPointerX + ptMoveX))and((textPointerX + ptMoveX) < tpMaxLen +1) then
                textPointerX = textPointerX + ptMoveX
            elseif textPointerX + ptMoveX < 0 then
                if 0 < textPointerY  then
                    textPointerY = textPointerY -1
                    textPointerX = #lines[textPointerY+1]
                end
            elseif tpMaxLen < textPointerX + ptMoveX then
                if textPointerY+1 < #lines then
                    textPointerY = textPointerY +1
                    textPointerX = 0
                end
            end
        end
        if ptMoveY ~= 0 then
            if (0 <= (textPointerY+ptMoveY))and((textPointerY+ptMoveY) < #lines) then
                textPointerY = textPointerY + ptMoveY

                tpMaxLen = #lines[textPointerY + 1]
                if tpMaxLen < textPointerX  then
                    textPointerX = tpMaxLen
                end
                
            end
        end

        --==================================================================

        -- display control ====================================================
        if (ptMoveY ~= 0) or (ptMoveX ~= 0) or (inputKey ~= "") then
            if 192 < ((textPointerY+1)*9)+textDispGapY then
                textDispGapY = textDispGapY - ((((textPointerY+1)*9)+textDispGapY) - 192)
            elseif (textPointerY*9)+textDispGapY < 0 then
                textDispGapY = textDispGapY + (0-((textPointerY*9)+textDispGapY))
            end
            drawUpdate = true
        end
        -- =====================================================================

        if drawUpdate == true then

            -- Setting up the layers ============================================
            -- textLineBox
            Layers.drawBox(1, 0,(textPointerY*9) + textDispGapY,256,9, true, Color.new(7, 7, 7))


            --text content
            --decide start line ///////////////////////////////////////////////////
            drawStartLine = math.floor((textDispGapY*-1)/9)
            i = drawStartLine
            -- drawr text line numbers ////////////////////////////////////////////
            while i < drawStartLine + 23 do
                if #lines-1 < i then
                    break
                end
                tNumWidth = string.len(tostring(math.abs(i))) * 7

                Layers.drawText(1, textLineNumberDivX-tNumWidth,((i*9)+1)+textDispGapY, tostring(math.abs(i)), Color.new(15, 15, 15))

                i = i + 1
            end

            --decide start line ///////////////////////////////////////////////////
            i = drawStartLine
            while i < drawStartLine + 23 do
                if #lines-1 < i then
                    break
                end

                Layers.drawText(1, textLineNumberDivX,((i*9)+1)+textDispGapY, lines[i+1], Color.new(31, 31, 31))

                i = i + 1
            end

            Layers.drawText(1, ((textPointerX*6)-3)+textLineNumberDivX, ((textPointerY*9)+2)+textDispGapY, "|", Color.new(31, 31, 31))

            --vKeybord.draw(canvas_down_layers, inputKey)

            -- register All the layers ============================================

            --Debug.print("hello: "..#canvas_down_layers)
            drawUpdate = false
        end

        Layers.render()
    end

    
end

--Debug.ON()
--Debug.setColor(Color.new(31,31,31))

--bEdit()
--main()