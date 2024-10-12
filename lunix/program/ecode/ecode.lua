-- 自作仮想キーボードを起動
dofile("lunix/system/vKey.lua")

function main(argTable)
    -- canvas set up
    local debugString = ""
    --#################################################################
    local lines = {}
    local debugString = ""
    -- 起動時読み込みファイルの指定がなかった場合、下のファイルを読み込み
    local fileName = "lunix/home/Documents/text.txt"
    -- nilエラー回避のための分岐
    if argTable ~= nil then
        fileName = argTable[1]
    end
    --ファイル読み込み
    local file = io.open(fileName, "rb")
    -- ファイル読み込みが失敗した場合
    if file == nil then
        --　エラーを画面に出力
        str = "failed to open a file: ".. fileName
        error(str)
    end
    -- 読み込んだデータを行別に配列として格納
    for line in file:lines() do
        ln = #lines + 1
        lines[ln] = line
    end
    file:close()
    -- 行末にある改行文字を配列から削除(最後の文字を除いた文字を再格納している)
    for i=1,#lines-1 do
        lines[i] = string.sub(lines[i], 1,-2)
    end
    -- ファイルがみつからなかった場合、テキストとして"no file found"を表示
    if file == nil then
        lines[#lines+1] = "no file found"
    end


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
    -- 仮想キーボードを有効化
    vKeybord.on()
    -- 画面更新フラグをTrue
    local drawUpdate = true
    -- Startキーを押すとプログラムを終了します。
    while not Keys.held.Start do
        -- 入力されたキーをシステムから取得
        Controls.read()
        -- 仮想キーボードから入力されたキーを取得
        local inputKey, CtrlKey = vKeybord.update()
        -- Xキーが押された際、仮想キーボードのキーセットを切り替え
        if Keys.newPress.X then
            vKeybord.switch()
        end

        -- [テキスト入力]
        --　仮想キーボードでなんらかの入力があった場合
        if inputKey ~= "" then
            insStr = lines[textPointerY + 1]
            -- \b(BackSpace)が入力された場合
            if inputKey == "\b" then
                -- ポインターカーソル(CP)の位置が行はじめ(行の1番左)であった場合
                if 0 == textPointerX then
                    -- 1行目以上の行であった場合
                    if 0 < textPointerY then
                        -- CPのある行とその一つ上の行の文字列を結合し、
                        -- 行を削除した後、
                        -- CP位置を結合した文字列の先頭に来るよう変数を格納する。
                        lnPointerX = #lines[textPointerY]
                        lines[textPointerY] = lines[textPointerY] .. lines[textPointerY + 1]
                        table.remove(lines, textPointerY + 1)

                        textPointerX = lnPointerX
                        textPointerY = textPointerY - 1
                    end
                -- CPの位置が行の1番左ではなかった場合
                else
                    --CPで選択されている文字以外左右を結合、
                    -- CPを一つ左に動かし行を更新する。
                    insStr = insStr:sub(1,textPointerX-1)..insStr:sub(textPointerX+1)
                    textPointerX = textPointerX - 1
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

        -- >>カーソルポインター<<
        -- カーソルポインター右に最大寄れる位置を定義
        local tpMaxLen = #lines[textPointerY + 1]
        -- カーソルポインターの移動ベクター変数を初期化
        local ptMoveX = 0
        local ptMoveY = 0
        -- それぞれ方向キーが入力された際に、
        -- 応じて移動ベクター変数を格納
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

        -- 方向キーがホールドされている場合
        -- - (方向キーホールド時間しきい値は15f(0.5秒)に指定)
        local holdFixTime = 15
        -- 方向キー下が入力されている場合
        if Keys.held.Down then
            if keyHoldCounterY < 0 then
                keyHoldCounterY = 0
            end
            -- キーがホールドされている時間として加算
            keyHoldCounterY = keyHoldCounterY + 1
            -- キーがホールドされている時間がしきい値を上回っている場合、
            -- 移動ベクターを指定方向になるよう格納
            if holdFixTime < keyHoldCounterY then
                ptMoveY = 1
            end
        -- 方向キー上が入力されている場合
        elseif Keys.held.Up then
            if 0 < keyHoldCounterY then
                keyHoldCounterY = 0
            end
            keyHoldCounterY = keyHoldCounterY - 1
            if keyHoldCounterY < (holdFixTime * -1) then
                ptMoveY = -1
            end
        -- 方向キー右が入力されている場合
        elseif Keys.held.Right then
            if keyHoldCounterX < 0 then
                keyHoldCounterX = 0
            end
            keyHoldCounterX = keyHoldCounterX + 1
            if holdFixTime < keyHoldCounterX then
                ptMoveX = 1
            end
        -- 方向キー左が入力されている場合
        elseif Keys.held.Left then
            if 0 < keyHoldCounterX then
                keyHoldCounterX = 0
            end
            keyHoldCounterX = keyHoldCounterX - 1
            if keyHoldCounterX < (holdFixTime*-1) then
                ptMoveX = -1
            end
        else
            -- キーが何も押されていない場合はカウンターを常にリセットする。
            keyHoldCounterX = 0
            keyHoldCounterY = 0
        end

        -- ポインターカーソル(CP)の移動ベクターXに動きがあった場合
        if ptMoveX ~= 0 then
            --　CPの位置+移動方向がテキスト面上内である場合
            if (0 <= (textPointerX + ptMoveX))and((textPointerX + ptMoveX) < tpMaxLen +1) then
                -- CPを移動ベクターを+した位置に変更
                textPointerX = textPointerX + ptMoveX
            --　CPの位置+移動方向がX:-1(左の画面外に行った場合)
            elseif textPointerX + ptMoveX < 0 then
                -- CPのY位置が0行目ではない場合に限り、以下の処理を実行
                if 0 < textPointerY  then
                    --CPのY位置を-1(一つ上の行へ指定)
                    textPointerY = textPointerY -1
                    -- CPのX位置を行の一番最後に持っていく
                    textPointerX = #lines[textPointerY+1]
                end
            --　CPの位置+移動方向が行の右端を超えて移動した場合(右のテキスト面上の外へ行った場合)
            elseif tpMaxLen < textPointerX + ptMoveX then
                -- CPのY位置がEOFを超えていない場合に限り、以下の処理を実行
                if textPointerY+1 < #lines then
                    --CP位置を次の行へもっていき、行の一番左へ来るようにする
                    textPointerY = textPointerY +1
                    textPointerX = 0
                end
            end
        end
        -- ポインターカーソル(CP)の移動ベクターYに動きがあった場合
        if ptMoveY ~= 0 then
            -- CP位置+移動ベクターが0行目、またはEOF行目を超えていない場合
            if (0 <= (textPointerY+ptMoveY))and((textPointerY+ptMoveY) < #lines) then
                -- CP位置をCP位置+移動ベクターに指定
                textPointerY = textPointerY + ptMoveY

                -- CP移動をした際にCP位置が行の文字長を超えていた場合
                tpMaxLen = #lines[textPointerY + 1]
                if tpMaxLen < textPointerX  then
                    -- CPのX位置をを行の最後の位置に指定
                    textPointerX = tpMaxLen
                end
                
            end
        end

        --==================================================================

        -- [画面コントロール] ====================================================
        -- || カーソルポインター、キーボード入力があった場合にポインターが画面に来るように
        -- || テキスト面そのものを動かして制御します。
        -- 
        --もしカーソルポインターに動き、またキーボード入力があった場合
        if (ptMoveY ~= 0) or (ptMoveX ~= 0) or (inputKey ~= "") then
            -- カーソルポインターが下に画面外へ行った場合
            if 192 < ((textPointerY+1)*9)+textDispGapY then
                -- 画面テキスト面をY-方向へ文字の大きさ分スクロールさせる
                textDispGapY = textDispGapY - ((((textPointerY+1)*9)+textDispGapY) - 192)
            -- カーソルポインターが上に画面外へ行った場合
            elseif (textPointerY*9)+textDispGapY < 0 then
                -- 画面テキスト面をY+方向へ文字の大きさ分スクロールさせる
                textDispGapY = textDispGapY + (0-((textPointerY*9)+textDispGapY))
            end
            -- 画面を更新します。
            drawUpdate = true
        end
        -- =====================================================================
        --　もし画面更新フラグが立っていた場合。
        if drawUpdate == true then
            -- レイヤー処理 ============================================
            -- カーソルポインターがある行をハイライトする四角を描画
            Layers.drawBox(1, 0,(textPointerY*9) + textDispGapY,256,9, true, Color.new(7, 7, 7))

            -- 画面左に表示される行数番号を描画
            -- 画面内一番上に来るテキスト行を算出
            --  - テキスト面ギャップ値Yを文字の大きさ(9)で割って描画開始行を出しています。
            drawStartLine = math.floor((textDispGapY*-1)/9)
            -- 1画面、固定で最大23行まで表示されます
            i = drawStartLine
            while i < drawStartLine + 23 do
                -- 行がEOFまで行った場合処理を中断
                if #lines-1 < i then
                    break
                end
                -- 文字幅のpixel数を算出
                tNumWidth = string.len(tostring(math.abs(i))) * 7
                -- 行数番号を右寄りになるよ座標を合わせたうえで描画
                Layers.drawText(1, textLineNumberDivX-tNumWidth,((i*9)+1)+textDispGapY, tostring(math.abs(i)), Color.new(15, 15, 15))

                i = i + 1
            end

            -- テキスト面を描画
            -- 先ほど出した画面内一番上に来るテキスト行番号を再利用
            i = drawStartLine
            while i < drawStartLine + 23 do
                -- EOFで処理中断
                if #lines-1 < i then
                    break
                end
                -- 一行ずつテキストを描画します。
                Layers.drawText(1, textLineNumberDivX,((i*9)+1)+textDispGapY, lines[i+1], Color.new(31, 31, 31))

                i = i + 1
            end

            -- カーソルポインターを描画
            Layers.drawText(1, ((textPointerX*6)-3)+textLineNumberDivX, ((textPointerY*9)+2)+textDispGapY, "|", Color.new(31, 31, 31))

            -- 描画更新フラグをFalseにします。
            drawUpdate = false
        end

        -- レイヤーデータをもとに描画を実行します。
        Layers.render()
    end

    
end