local function getFileExt(filename)
    local str = ""
    local isFileExt = 0
    for st in filename:gmatch("[^.]+") do
        isFileExt = isFileExt + 1
        str = st
    end
    --local ext = ""
    if isFileExt > 1 then
        return str
    end
    return ""
end

local function getUpDirectry(directry)
    local str = st
    local i = 0
    for st in directry:gmatch("[^//]+") do
        str = st
        i = i+1
    end
    if 0 < i then
        return directry:sub(1,(string.len(str)*-1)-2)
    end
    return directry
end

local forcusId = 0

local focus = {}
focus.Folders = 0
focus.Submenu = 1
focus.errorMessage = 2
focus.renameBox = 3

local function runFile(fileNamePath)
    --local fullPath = CURRENT_DIR .. fileName
    local ext = getFileExt(fileNamePath)
    --Debug.print("hello: "..ext)

    if ext == "lua" then
        return {fileNamePath}
    elseif ext == "llk" then
        --Debug.print("hello: "..tostring(fileNamePath))
        local iniTable = INI.load(fileNamePath)
        --Debug.print("linkpath: "..tostring(iniTable["data"]["path"]))
        if iniTable["data"]["path"] == nil then
            Debug.print("the INI is nil!!")
        end
        local fullFilePath = iniTable["data"]["path"]
        return runFile(fullFilePath)
    else
        return {fileNamePath}
    end
    
end

local lcMenu_state = -1
local lcMenu_targetItemId = -1
local lcMenu_pointPos = 0
local lcMenuBoxX = 0
local lcMenuBoxY = 0
local lcMenuBox_sizeX = 0
local lcMenuBox_sizeY = 0
local lcMenu_Items = {}

local textBox = {}
textBox.actuve = false
textBox.text = ""
textBox.targetFileName = ""
textBox.textPointer = 0

local function openSubMenu(subMenuBoxX, subMenuBoxY, fileFullPath, isDir)
    if isDir == nil then
        isDir = false
    end
    lcMenu_Items = {}
    forcusId = focus.Submenu

    lcMenuBoxX = subMenuBoxX
    lcMenuBoxY = subMenuBoxY
    lcMenuBox_sizeX = 0
    lcMenuBox_sizeY = 0
    lcMenu_Items = {}
    -- get what type of file
    local ext = getFileExt(fileFullPath)
    if isDir == false then
        if ext == "lua" then
            table.insert(lcMenu_Items, {"Open", "run"} )
        else
            table.insert(lcMenu_Items, {"Open", "run"})
        end
        table.insert(lcMenu_Items, {"Edit", "edit"})
    else
        --
    end
    table.insert(lcMenu_Items, {"X Cut", "cut"})
    table.insert(lcMenu_Items, {"X Copy", "copy"})
    table.insert(lcMenu_Items, {"Delete X", "delete"})
    table.insert(lcMenu_Items, {"Rename", "rename"})
    table.insert(lcMenu_Items, {"New folder", "newDir"})
    table.insert(lcMenu_Items, {"New file", "newFile"})
    table.insert(lcMenu_Items, {"X Properties", "property"})
    

    -- decide the menu box width and height
    for i=1,#lcMenu_Items do
        local strPixcelSizeX = (string.len(lcMenu_Items[i][1])-1)*7
        if lcMenuBox_sizeX < strPixcelSizeX then
            lcMenuBox_sizeX = strPixcelSizeX
        end
    end
    lcMenuBox_sizeY = #lcMenu_Items * 9
    
    lcMenu_pointPos = 0

    lcMenu_state = 2
end

local function getSubMenuSelected(subMenuPointPos)
    return lcMenu_Items[subMenuPointPos][2] -- sCommand
end

local function dirRefresh()
    dirListTable = System.listDirectory(CURRENT_DIR)
end

local function doSubMenuCommand(sCommand, fileName)
    local excuteContent = ""
    local isExcuteMode = false
    if sCommand == "run" then
        excuteContent = runFile(CURRENT_DIR .. fileName)
        isExcuteMode = true
    elseif sCommand == "edit" then
        excuteContent = {"lunix/program/ecode/ecode.lua", {CURRENT_DIR .. fileName}}
        isExcuteMode = true
    elseif sCommand == "runPick" then
        --newDir
    elseif sCommand == "newDir" then
        System.makeDirectory(CURRENT_DIR .. "NewFolder")
        dirRefresh()
    elseif sCommand == "newFile" then
        local file = io.open(CURRENT_DIR .. "NewFile", "w")
        file:write("")
        file:close()
        dirRefresh()
    elseif sCommand == "delete" then
        --[[
        --local dirList = System.listDirectory(CURRENT_DIR .. fileName)
        --local dirCount = 0
        --for i=1, #dirList do
            --if (dirList[i]["name"] == ".") or (dirList[i]["name"] == "..") then
                -- body
            --else
                --dirCount = dirCount + 1
            --end
            
        end
        if 0 < dirCount then
            -- body
        end
        ]]--
        System.remove(CURRENT_DIR .. fileName)
        dirRefresh()
    elseif sCommand == "rename" then
        dofile("lunix/system/vKey.lua")
        vKeybord.on()
        textBox.text = fileName
        textBox.targetFileName = CURRENT_DIR .. fileName
        forcusId = focus.renameBox
        textBox.actuve = true
        drawUpdate_bottom = true
    end
    --local dirFileName 
    return isExcuteMode, excuteContent
end

local function closeSubMenu(subMenuBoxX, subMenuBoxY, fileFullPath)
    lcMenu_state = -1
    forcusId = focus.Folders
end




CURRENT_DIR = "lunix/home/desktop/"
dirListTable = System.listDirectory(CURRENT_DIR)

--CURRENT_DIR = ULUA_DIR --.. "libs/"
function main(argTable)
    local fileNameList = ""
    local curserPoint = 0

    --local layers = {}
    --local layers_bottom = {}

    --fileNameList = lsArray()
    
    local bsStr = ""
    local drawUpdate = true
    local drawUpdate_bottom = true
    local drawUpdate_bottom_timer = 0

    local pointerUpdate = 0

    
    -- 0 = fileViewer
    -- 1 = lsMenu
    -- 2 = errormessage


    -- load back dround
    local bgImg =  Layers.loadPic("/lunix/system/bg2.gif", RAM)
    local iconImg_file = Layers.loadPic("/lunix/system/voyage/icon_file.png", RAM)
    local iconImg_folder = Layers.loadPic("/lunix/system/voyage/icon_folder.png", RAM)
    local iconImg_luaFile = Layers.loadPic("/lunix/system/voyage/icon_luaFile.png", RAM)

    while true do
        Controls.read()

        if Keys.newPress.A then
            if forcusId == focus.Folders then
                bsStr = dirListTable[curserPoint+1]["name"]
                --bsStr = CURRENT_DIR .. dirListTable[curserPoint+1]["name"]
                if (bsStr == "..")  then
                    curserPoint = 0
                    CURRENT_DIR = getUpDirectry(CURRENT_DIR)
                    dirListTable = System.listDirectory(CURRENT_DIR)
                else
                    if dirListTable[curserPoint+1]["isDir"] == false then
                        return runFile(CURRENT_DIR .. bsStr)
                    else
                        curserPoint = 0
                        CURRENT_DIR = CURRENT_DIR .. bsStr .. "/"
                        dirListTable = System.listDirectory(CURRENT_DIR)
                    end
                end
            elseif forcusId == focus.Submenu then
                local sCommand = getSubMenuSelected(lcMenu_pointPos +1)
                local isExcute, exContent = doSubMenuCommand(sCommand, dirListTable[curserPoint+1]["name"])
                if isExcute == true then
                    return exContent
                end
                closeSubMenu()
            elseif forcusId == focus.errorMessage then
                argTable[1] = ""
                forcusId = 0
                drawUpdate = true
            end

            drawUpdate = true
        end

        if Keys.newPress.B then
            if forcusId == 0 then
                curserPoint = 0
                CURRENT_DIR = getUpDirectry(CURRENT_DIR)
                dirListTable = System.listDirectory(CURRENT_DIR)
            elseif forcusId == 1 then
                lcMenu_state = -1
                forcusId = 0
            elseif forcusId == 2 then
                argTable[1] = ""
                forcusId = 0
            end
            drawUpdate = true
        end

        if Keys.newPress.Y then
            if forcusId == focus.Folders then
                local fileName = dirListTable[curserPoint+1]["name"]
                local subMenuBoxX = (7 + string.len(fileName)*6) / 2
                local subMenuBoxY = 10 + ((curserPoint*9)+1) + 4
                openSubMenu(subMenuBoxX, subMenuBoxY, CURRENT_DIR .. dirListTable[curserPoint+1]["name"], dirListTable[curserPoint+1]["isDir"])

                forcusId = focus.Submenu
            elseif forcusId == focus.Submenu then
                closeSubMenu()
            end
            drawUpdate = true
        end

        if Keys.newPress.Down then
            pointerUpdate = 1
        elseif Keys.newPress.Up then
            pointerUpdate = -1
        end

        if pointerUpdate ~= 0 then
            if forcusId == 0 then
                local updatedPointPos = curserPoint + pointerUpdate
                if (0 <= updatedPointPos) and (updatedPointPos < #dirListTable) then
                    curserPoint = updatedPointPos
                end
            elseif forcusId == 1 then
                local updatedPointPos = lcMenu_pointPos + pointerUpdate
                if (0 <= updatedPointPos) and (updatedPointPos < #lcMenu_Items) then
                    lcMenu_pointPos = updatedPointPos
                end
            end
            
            pointerUpdate = 0
            drawUpdate = true
        end

        if 30 <= drawUpdate_bottom_timer then
            drawUpdate_bottom = true
            drawUpdate_bottom_timer = 0
        else
            drawUpdate_bottom_timer = drawUpdate_bottom_timer + 1
        end

        if textBox.actuve == true then
            local inputKey, CtrlKey = vKeybord.update()
            if inputKey ~= "" then
                if inputKey == "\b" then
                    if 0 < textBox.textPointer then
                        textBox.text = textBox.text:sub(1,textBox.textPointer-1)..textBox.text:sub(textBox.textPointer+1)
                        textBox.textPointer = textBox.textPointer - 1
                    end
                elseif inputKey == "\r" then
                    System.rename(textBox.targetFileName, CURRENT_DIR .. textBox.text)
                    vKeybord.off()
                    --vKeybord = nil
                    dirRefresh()
                    textBox.actuve = false
                    drawUpdate = true
                    forcusId = focus.Folders
                elseif inputKey == "\t" then
                else
                    textBox.text = textBox.text:sub(1,textBox.textPointer)..inputKey..textBox.text:sub(textBox.textPointer+1)
                    textBox.textPointer = textBox.textPointer + 1
                end
                drawUpdate_bottom = true
            end
            if Keys.newPress.Right then
                if textBox.textPointer < #textBox.text then
                    textBox.textPointer = textBox.textPointer+1
                end
            elseif Keys.newPress.Left then
                if 0 < textBox.textPointer then
                    textBox.textPointer = textBox.textPointer-1
                end
            end
        end
        
        if drawUpdate == true then
        --if true then
            Layers.drawPic(1 ,0, 0 ,bgImg)
            Layers.drawBox(1, 0, 0, 256, 9, false, Color.new(31,31,31))
            Layers.drawText(1, 2, 0, CURRENT_DIR, Color.new(31, 31, 31))

            local dirListAxisX = 0
            local dirListAxisY = 10
            i = 0
            while i < #dirListTable  do
                local dirFileName = dirListTable[i+1]["name"]

                -- extract ext info
                local ext = getFileExt(dirFileName)
                -- end of extraction
                --Debug.print("hello: ".. tostring(ext))
                if dirListTable[i+1]["isDir"] == true then
                    Layers.drawPic(1 ,0, dirListAxisY + ((i*9)+1)+0 ,iconImg_folder)
                elseif ext == "lua" then
                    Layers.drawPic(1, 0, dirListAxisY + ((i*9)+1)+0 ,iconImg_luaFile)
                else
                    Layers.drawPic(1 ,0, dirListAxisY + ((i*9)+1)+0 ,iconImg_file)
                end
                
                if i == curserPoint then
                    Layers.drawBox(1, 7, dirListAxisY + ((i*9)+1), string.len(dirFileName)*6, 9, true, Color.new(31,31,31))
                    Layers.drawText(1, 7,dirListAxisY + ((i*9)+1), dirFileName, Color.new(0, 0, 0))
                else
                    Layers.drawText(1, 7,dirListAxisY + ((i*9)+1), dirFileName, Color.new(31, 31, 31))
                end

                

                i = i + 1
                drawUpdate = false
            end
            fileCount = i

            -- leftClickMenu draw
            if lcMenu_state == 2 then
                Layers.drawBox(1, lcMenuBoxX, lcMenuBoxY, lcMenuBox_sizeX, lcMenuBox_sizeY, true, Color.new(30,30,30))
                -- point box
                Layers.drawBox(1, lcMenuBoxX, lcMenuBoxY+(lcMenu_pointPos*9), lcMenuBox_sizeX, 9, true, Color.new(23, 23, 23))

                for i=1,#lcMenu_Items do
                    Layers.drawText(1, lcMenuBoxX, lcMenuBoxY + ((i-1)*9), lcMenu_Items[i][1], Color.new(5, 5, 5))
                end
            end

            drawUpdate = false
        end

        if drawUpdate_bottom == true then
            
            Layers.drawBox(2, 0, 0, 256, 10, false, Color.new(31,31,31))
            local dateTimeStr = os.date("%H"..":".."%M")
            --local clockStr = tostring(dateTimeData.hour) .. ":" .. tostring(dateTimeData.minute)
            --clockStr = tostring(dateTimeData)
            Layers.drawText(2, 256 - (string.len(dateTimeStr)*7), 1, dateTimeStr, Color.new(31, 31, 31))

            if argTable[1] == "error" then
                Layers.drawBox(2, 32, 12, 192, 168, true, Color.new(31,31,31))

                Layers.drawText(2, 32, 12, "Error:", Color.new(5, 5, 5))
                Layers.drawTextBox(2, 32, 21, 192, 168, argTable[2], Color.new(5, 5, 5))
                forcusId = 2
            end

            if textBox.actuve == true then
                Layers.drawBox(2, 0, 10, (string.len(textBox.text)+1)*6, 9, true, Color.new(31,31,31))
                Layers.drawText(2, 0, 10, textBox.text, Color.new(0, 0, 0))
            end

            drawUpdate_bottom = false
        end
        

        
        --screen.print(SCREEN_DOWN,0,0,bsStr ,Color.new(31, 31, 31))

        Layers.render()
    end
    
end

--return main()
--helloman()