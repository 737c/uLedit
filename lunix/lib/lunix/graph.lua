Layers = {}

canvas_up = Canvas.new()
canvas_down = Canvas.new()

local objLayers = {}
objLayers[1] = {}
objLayers[2] = {}
objLayers[3] = {}
objLayers[4] = {}

local objLayers_state = {}
objLayers_state[1] = 0
objLayers_state[2] = 0

loadedImg = {}

Layers.layerUpdate = false

Layers.system_vKeybord_isloaded = false

Layers.render = function()
    -- overlay draw
    -- if the keybord has been updated
    if vKeybord ~= nil then
        if (vKeybord.updateCounter > 0) or (objLayers_state[2] == 1) then
            vKeybord.draw(2)
            vKeybord.updateCounter = vKeybord.updateCounter -1
        end
    end

    if objLayers_state[1] == 1 then
        Layers.update(1, 1)
        objLayers_state[1] = 0
    end
    if objLayers_state[2] == 1 then
        Layers.update(2, 2)
        objLayers_state[2] = 0
    end
    if objLayers_state[3] == 1 then
        Layers.update(1,3)
        objLayers_state[3] = 0
    end
    if objLayers_state[4] == 1 then
        Layers.update(2,4)
        objLayers_state[4] = 0
    end

    Canvas.draw(SCREEN_UP, canvas_up, -1000, -1000)
    Canvas.draw(SCREEN_DOWN, canvas_down, -1000, -1000)

    objLayers_state[1] = 0
    objLayers_state[2] = 0
    objLayers_state[3] = 0
    objLayers_state[4] = 0

    render()
end

Layers.update = function(screenId, objLayerId)--, sLayer)
    if screenId == 1 then
        canvas = canvas_up
    elseif screenId == 2 then
        canvas = canvas_down
    elseif screenId == 3 then
        canvas = canvas_up
    elseif screenId == 4 then
        canvas = canvas_down
    end

    for i=1, #objLayers[objLayerId] do
        Canvas.add(canvas, objLayers[objLayerId][i])
    end
end

Layers.clearLayer = function(screenId)

    if screenId == 1 then
        canvas = canvas_up
    elseif screenId == 2 then
        canvas = canvas_down
    elseif screenId == 3 then
        canvas = canvas_up
    elseif screenId == 4 then
        canvas = canvas_down
    else
        --Debug.print()
        error("not enexpected value: ".. type(screenId))
        return
    end

    for i=1,#objLayers[screenId] do
        Canvas.removeObj(canvas,  objLayers[screenId][i])
    end


    objLayers[screenId] = {}

end

local function layerStateChange(screenId)
    -- 0 = nochange/ fetched
    -- 1 = modifying

    if objLayers_state[screenId] == 0 then
        Layers.clearLayer(screenId)
        objLayers_state[screenId] = 1
    end
    
end

Layers.drawNothing = function(objLyaersId)
    layerStateChange(objLyaersId)
end

Layers.drawBox = function(screenId, x, y, sizeX, sizeY, filled, color)
    layerStateChange(screenId)

    x = x +1000
    y = y +1000
    if color == nil then
        color = Color.new(31, 31, 31)
    end
    if filled == nil then
        filled = false
    end

    if filled == true then
        layerObj = Canvas.newFillRect(x, y, x+sizeX, y+sizeY, color)
    elseif filled == false then
        layerObj = Canvas.newRect(x, y, x+sizeX, y+sizeY, color)
    end
    
    table.insert(objLayers[screenId], layerObj)
end

Layers.loadPic = function(path, where)
    local imgData = Image.load(path, RAM)
    table.insert(loadedImg, imgData)
    return imgData
end

Layers.unloadPic = function()
    for i=1,#loadedImg do
        Image.destroy(loadedImg[i])
    end
    Canvas.destroy(canvas_up)
    Canvas.destroy(canvas_down)
end

Layers.drawPic = function(screenId, x, y, imageObj)
    layerStateChange(screenId)

    x = x +1000
    y = y +1000

    local layerObj = Canvas.newImage(x, y, imageObj)
    table.insert( objLayers[screenId], layerObj)
end

Layers.drawTextBox = function(screenId, x, y, sizeX, sizeY, string, color)
    layerStateChange(screenId)

    x = x +1000
    y = y +1000
    if color == nil then
        color = Color.new(31, 31, 31)
    end

    local layerObj = Canvas.newTextBox(x, y, x+ sizeX, y+ sizeY, string, color)
    table.insert( objLayers[screenId], layerObj)
end

Layers.drawText = function(screenId, x, y, string, color)
    layerStateChange(screenId)

    x = x +1000
    y = y +1000
    if color == nil then
        color = Color.new(31, 31, 31)
    end
    local layerObj = Canvas.newText(x, y, string, color)
    table.insert( objLayers[screenId], layerObj)
end