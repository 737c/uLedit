Layers = {}

canvas_up = Canvas.new()
canvas_down = Canvas.new()

local objLayers_up = {}
local objLayers_down = {}

loadedImg = {}

Layers.layerUpdate = false

local canvas_orverlay_layers = {}

Layers.system_vKeybord_isloaded = false

Layers.render = function()
    -- overlay draw
    -- if the keybord has been updated
    if vKeybord ~= nil then
        if vKeybord.updateCounter > 0 then
            canvas_orverlay_layers = Layers.clearLayer(canvas_orverlay_layers, 1)
            vKeybord.draw(canvas_orverlay_layers)
            Layers.update(1,canvas_orverlay_layers)
    
            vKeybord.updateCounter = vKeybord.updateCounter -1
        end
    end

    Canvas.draw(SCREEN_UP, canvas_up, -1000, -1000)
    Canvas.draw(SCREEN_DOWN, canvas_down, -1000, -1000)

    render()
end

Layers.update = function(screenId, layers)
    if screenId == 0 then
        canvas = canvas_up
    elseif screenId == 1 then
        canvas = canvas_down
    end

    for i=1, #layers do
        Canvas.add(canvas, layers[i])
    end
end

Layers.clearLayer = function(layers, screenId)
    if type(layers) ~= "table" then
        Debug.print("not table")
        error("not table: ".. type(layers))
        --return "not table"
    end

    if screenId == 0 then
        canvas = canvas_up
    elseif screenId == 1 then
        canvas = canvas_down
    else
        --Debug.print()
        error("not enexpected value: ".. type(screenId))
        return
    end

    for i=1,#layers do
        Canvas.removeObj(canvas, layers[i])
    end
    layers = {}

    return layers
end

Layers.drawBox = function(layers, x, y, sizeX, sizeY, filled, color)

    if type(layers) ~= "table" then
        Debug.print("not table")
        error("not table: " .. type(layers))
    end

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
    
    table.insert(layers, layerObj)
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

Layers.drawPic = function(layers, x, y, imageObj)
    if type(layers) ~= "table" then
        Debug.print("not table")
        --return "not table"
    end
    x = x +1000
    y = y +1000

    local layerObj = Canvas.newImage(x, y, imageObj)
    table.insert(layers, layerObj)
end

Layers.drawTextBox = function(layers, x, y, sizeX, sizeY, string, color)
    x = x +1000
    y = y +1000
    if color == nil then
        color = Color.new(31, 31, 31)
    end

    local layerObj = Canvas.newTextBox(x, y, x+ sizeX, y+ sizeY, string, color)
    table.insert(layers, layerObj)
end

Layers.drawText = function(layers, x, y, string, color)
    if type(layers) ~= "table" then
        Debug.print("not table")
        --return "not table"
    end
    x = x +1000
    y = y +1000
    if color == nil then
        color = Color.new(31, 31, 31)
    end
    local layerObj = Canvas.newText(x, y, string, color)
    table.insert(layers, layerObj)
end