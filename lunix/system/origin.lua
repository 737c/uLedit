-- 実行したLuaがエラーを出力した際、直感的にわかりやすくるために
-- TrueとFalseを反転させるFunc
local function errorHandle(pcallSuccess)
    if pcallSuccess == false then
        return true
	end
    return false
end

-- ユーザースクリプトを実行
local function runLua(luaFile, argTable)
    -- 引数にファイルの指定がnilだった場合エラー出力
    if luaFile == nil then
        Debug.print("fileName is not specified")
        return
    end
    -- 読み込んだファイルを実行
    local func = function (argTable)
        dofile(luaFile)
        -- 自作グラフィックライブラリを追加
        package.path = "lunix/lib/lunix/graph.lua"
        require("graph")
        local returnValue = main(argTable)
        Layers.unloadPic()
        -- 読み込んだグラフィックライブラリを開放
        package.loaded["graph"] = nil
        return returnValue
    end
    local pcallSuccess, returnValue = pcall(func, argTable)
    -- GCを実行
    collectgarbage("collect")
    return pcallSuccess, returnValue
end
-- [ここからメインロジック]
-- エラーメッセージ用変数を初期化
local voyageMessage = ""
local voyageMessageType = ""

while true do
    -- 下のrunLua実行時に、エラーが発生した際のメッセージをファイルマネージャーを起動する際の引数として渡す
    Debug.ON()
    Debug.setColor(Color.new(31,31,31))
    local argTable = {}
    argTable[#argTable+1] = voyageMessageType
    argTable[#argTable+1] = voyageMessage
    -- 自作ファイルマネージャーを起動(/に戻る)
    local pcallSuccess, returnValue = runLua("lunix/system/voyage.lua", argTable)
    -- (ファイルマネージャーorFM上で実行されたユーザーLuaが閉じられたあと)
    -- GCを実行
	collectgarbage("collect")
    -- もし返り値がエラーだった場合
    if errorHandle(pcallSuccess) then
        -- ビルトインライブラリを使ってエラー内容を基本出力
        Debug.print(returnValue)
        -- 出力内容を画面にレンダ
        while true do
            render()
        end
    end
    -- デバッグ出力変数を初期化
    voyageMessage = ""
    voyageMessageType = ""

    while true do
        --もし返り値がテーブル型だった場合
        if type(returnValue) == "table" then
            -- runLua(ユーザーLuaファイルDir, 引数テーブル)を実行
            pcallSuccess, returnValue = runLua(returnValue[1], returnValue[2])
            --ユーザープログラムが終了後エラーが帰ってきたら返り値をエラーとしてキープ
            if errorHandle(pcallSuccess, returnValue) then
                voyageMessageType = "error"
                voyageMessage = returnValue
                break
            end
        end 
        break
    end
      
end


