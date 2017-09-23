# curses-twitter
an twitter client run on terminal, made in Ruby, use curses library

## 動作確認環境（20170923時点）
+ Xubuntu 16.04 64bit
+ Ruby (2.3.1)
+ Gems
    + curses (1.2.4)
    + twitter (6.1.0)


## 起動方法
1. configの変更
    + `config/config/rb`の内容を変更します。  
https://dev.twitter.com/ に登録して「Create New App」した後以下の4つを発行してください。
        + Consumer Key
        + Consumer Secret
        + Access Token
        + Access Token Secret
    + 詳しくはGoogle先生に聞いてください。

2. ターミナルから起動  
    $ cd path/to/curses-twitter
    $ ruby curses-twitter.rb

## 操作方法
+ 画面上でキーを押下することで操作します。  
以下に一覧を記載します。（vimのキーバインドを参考にしています。）
    + 通常モード
        + アプリケーション起動時はこのモードです。各キーを押下することで、アクションが発生します。  
|キー|アクション|
|:---|:---|
|a, i|ツイート入力モードに移行|
|j, ↓|1つ古いツイートを表示|
|k, ↑|1つ新しいツイートを表示|
|G|最も新しいツイートを表示|
|u|新着ツイートをサーバから取得|
|数字キー|コマンドモード１に移行|
|:|コマンドモード２に移行|
    + ツイート入力モード
        + ツイート内容を編集するモードです。編集後はEsc→「:w」とタイプすることでツイートがサーバに送信されます。
        + （ *TODO* ）文字キー押下時のカーソル位置は移動できません。  
|キー|アクション|
|:---|:---|
|Esc|通常モードに移行|
|BackSpace|ツイート内容の末尾1文字を削除|
|文字キー|ツイート内容を変更|
    + コマンドモード１
        + 数値に続いて以下のキーを入力することで、アクションが発生します。  
アクション発生後は、一部を除き自動的に通常モードに移行します。  
|キー|アクション|
|:---|:---|
|Esc|入力された内容を破棄し、通常モードに移行|
|数字キー|数値を変更|
|BackSpace|数値の末尾1文字を削除|
|f|数値に対応する番号が振られたツイートを「いいね」|
|F|数値に対応する番号が振られたツイートの「いいね」を解除|
|G|数値に対応する番号が振られたツイートを画面に表示
|r|数値に対応する番号が振られたツイートに対する返信として、ツイート入力モードに移行|
|R|数値に対応する番号が振られたツイートをリツイート|
    + コマンドモード２
        + 「:」に続いて以下の文字列を入力し、Enterを押下することで、アクションが発生します。  
アクション発生後は、一部を除き自動的に通常モードに移行します。  
|文字列（キー）|アクション|
|:---|:---|
|（Esc）|入力された内容を破棄し、通常モードに移行|
|tl, timeline|通常タイムラインを画面に表示|
|reply, mention|自分宛てのメンション付きツイートを画面に表示|
|user [screen_name]|ユーザ[screen_name]のホームタイムラインを表示（@の付与は任意）|
|w|ツイート入力モードで編集したツイート内容をサーバに送信|
|q|アプリケーションを終了し、シェルに戻る|

