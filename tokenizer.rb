class Tokenizer
  def initialize
    # 入力された.jackファイルを開く
    # .jackファイルから空白、コメントを取り除く
    # トークンを配列に格納する
  end

  def has_more_tokens?
    # トークンの配列にまだトークンが存在するか？
  end

  def advance
    # 入力から次のトークンを取得し、それを現在のトークンとする
    # #has_more_tokens?()がtrueの場合のみ呼び出すことができる
    # 最初は、現トークンは設定されていない
  end

  def token_type
    # 現トークンの種類を返す

    # 戻り値
    # KEYWORD, SYMBOL, IDENTIFIER, INT_CONST, STRING_CONST
  end

  def keyword
    # 現トークンのキーワードを返す
    # #token_type()がKEYWORDの場合のみ呼び出すことができる

    # 戻り値
    # CLASS, METHOD, FUNCTION, CONSTRUCTOR, INT, BOOLEAN, CHAR, VOID, VAR, STATIC, FIELD,
    # LET, DO, IF, ELSE, WHILE, RETURN, TRUE, FALSE, NULL, THIS
  end

  def symbol
    # 現トークンの文字を返す
    # #tokey_type()がSYMBOLの場合のみ呼び出すことができる

    # 戻り値は文字
  end

  def identifier
    # 現トークンの識別子（identifier）を返す
    # #token_type()がIDENTIFIERの場合のみ呼び出すことができる

    # 戻り値は文字列
  end

  def int_val
    # 現トークンの整数の値を返す
    # #token_type()がINT_CONSTの場合のみ呼び出すことができる

    # 戻り値は整数
  end

  def string_val
    # 現トークンの文字列を返す
    # #token_type()がSTRING_CONSTの場合のみ呼び出すことができる

    # 戻り値は文字列
  end
end
