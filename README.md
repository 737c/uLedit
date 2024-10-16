<img src="https://raw.githubusercontent.com/737c/uLedit/refs/heads/main/ergegrth.png" width="50%" height="50%">  

# uLedit  

現在編集中です。  
これはNDS/DSiで使える、テキストエディターアプリになります。  
NDSにこのアプリを導入するとNDS上でファイルを選択して、タッチスクリーンを使ってテキストを編集できます。  

### 導入方法
さらに細かな実際の導入方法については更新ができ次第、記述予定です。  
MicroLua DSが導入されているDSiのSDカード内rootにuLeditプロジェクトを上書きコピー。  
MicroLuaを起動するとファイル選択画面に遷移し、ファイル上でYボタン->"Edit"を選択すると編集画面へ遷移します。  

### コードについて
![/lunix/program/ecode/ecode.lua](https://github.com/737c/uLedit/blob/main/lunix/program/ecode/ecode.lua) がテキストエディターのコアスクリプトとなっていて、  
コメントを随所に記述しています。  
参考にしていただけるとありがたいです。  

このほかにも仮想キーボード、ファイル選択画面など実装しています。  
メインロジック: ![lunix/system/origin.lua](https://github.com/737c/uLedit/blob/main/lunix/system/origin.lua)  
仮想キーボード: ![lunix/system/vKey.lua](https://github.com/737c/uLedit/blob/main/lunix/system/vKey.lua)  
ファイル選択画面: ![lunix/system/voyage.lua](https://github.com/737c/uLedit/blob/main/lunix/system/voyage.lua)  

![NDS テキスト編集画面](https://raw.githubusercontent.com/737c/uLedit/refs/heads/main/DSC_1687-3e.jpg)  

