require 'ripper'

class Tokenizer
  # NOTE: トークナイザーに関して言えば、トークンを5種類のタグのいずれかで囲むだけ、と考えていいと思う
  # 文字の並びをトークンに区切る処理が必要かもしれない

  KEYWORD = %w(class constructor function method field static var int
               char boolean void true false null this let do if else while return)
  SYMBOL  = %w({ } ( ) [ ] . , ; + - * / & | < > = ~)

  def initialize(jack_file)
    # 入力された.jackファイルを開く
    # .jackファイルから空白、コメントを取り除く
    # トークンを配列に格納する
    arr = File.open(jack_file)
    # ファイルを一つの文字列にする
    # @target_lines = trim(arr).join('')
    @target_lines = trim(arr)
    @tokens = divide_into_tokens(@target_lines)

    @current_token = ''
  end

  def has_more_tokens?
    !@tokens.empty?
  end

  def advance
    # 最初は、現トークンは設定されていない
    # has_more_tokens?()がtrueの場合のみ呼び出すことができる
    raise StandardError if @target_lines.empty?

    # 配列の先頭からトークンを取り出す
    @current_token = @tokens.shift
  end

  def token_type
    # 現トークンの種類を返す

    # 戻り値
    # :KEYWORD, :SYMBOL, :IDENTIFIER, :INT_CONST, :STRING_CONST
    case when KEYWORD.include?(@current_token)
      :KEYWORD
    when SYMBOL.include?(@current_token)
      :SYMBOL
    when @current_token.match(/^\d/)
      :INT_CONST
    when @current_token.match(/^st_const/)
      :STRING_CONST
    else
      :IDENTIFIER
    end
  end

  def keyword
    # 現トークンのキーワードを返す
    # #token_type()がKEYWORDの場合のみ呼び出すことができる

    # 戻り値
    # CLASS, METHOD, FUNCTION, CONSTRUCTOR, INT, BOOLEAN, CHAR, VOID, VAR, STATIC, FIELD,
    # LET, DO, IF, ELSE, WHILE, RETURN, TRUE, FALSE, NULL, THIS
    @current_token
  end

  def symbol
    # 現トークンの文字を返す
    # #tokey_type()がSYMBOLの場合のみ呼び出すことができる
    # 戻り値は文字
    case @current_token
    when '<'
      '&lt;'
    when '>'
      '&gt;'
    when '&'
      '&amp;'
    else
      @current_token
    end
  end

  def identifier
    # 現トークンの識別子（identifier）を返す
    # #token_type()がIDENTIFIERの場合のみ呼び出すことができる

    # 戻り値は文字列
    @current_token
  end

  def int_val
    # 現トークンの整数の値を返す
    # #token_type()がINT_CONSTの場合のみ呼び出すことができる

    # 戻り値は整数
    @current_token
  end

  def string_val
    # 現トークンの文字列を返す
    # #token_type()がSTRING_CONSTの場合のみ呼び出すことができる

    # 戻り値は文字列
    @current_token.delete('st_const')
  end

  private

  # コメント、改行、空白を取り除く
  #
  # コメントは
  # // 行の終わりまで
  # /* 結びまで */
  # /** APIドキュメント用のコメント */ の３種類
  def trim(lines)
    lines.map { |e| e.gsub(/\/\/.*/, '') }
         .map { |e| e.gsub(/\/\*.*\*\//, '') }
         .map { |e| e.gsub(/\n/, '') }
         .map { |e| e.gsub(/\r/, '') }
         .map { |e| e.gsub(/\t/, '') }
         .map { |e| e.gsub(/^\s+/, '') }
         .reject(&:empty?)
  end

  def divide_into_tokens(lines)
    # TODO: ここから
    # do Outputなどのruby文法として解釈できない表現はトークナイズできない
    # そのため、ripperを使わずに、トークンに分割するように実装する

    # Ruby標準ライブラリを使ってみた
    # あくまでRubyコードをトークナイズするためのものなので、うまくトークナイズできないコードもありそうだが
    # その場合は柔軟に拡張する
    # tokens =  Ripper.tokenize(lines)
    # tokens.delete(' ')
    lines.map! do |e|
      e.split(/(class|constructor|function|method|field|static|var|int|char|boolean|void|true|false|null|this|let|do|if|else|while|return)/)
    end.flatten!

    lines.reject! { |e| e.match(/^\s$/) }

    lines.map! do |e|
      e.split(/({|}|\(|\)|[|]|\.|,|;|\+|-|\*|\/|&|\||<|>|=|~)/)
    end.flatten!

    lines.reject!(&:empty?)
    lines.reject! { |e| e.match(/^\s$/) }

    binding.irb


    tokens = mark_string_const(tokens)
    tokens
  end

  def mark_string_const(tokens)
    indexes = tokens.map.with_index(0) do |str, i|
      i if str.match(/"/)
    end.reject(&:nil?)

    st_con_indexes = indexes.each_slice(2).map(&:first).map { |i| i + 1 }

    st_con_indexes.each do |i|
      tokens.insert(i, "st_const" + tokens[i])
      tokens.delete_at(i + 1)
    end

    tokens.delete('"')
    tokens
  end
end
