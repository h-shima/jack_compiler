class Tokenizer
  # NOTE: トークナイザーに関して言えば、トークンを5種類のタグのいずれかで囲むだけ、と考えていいと思う
  # 文字の並びをトークンに区切る処理が必要かもしれない

  KEYWORD = %w(class constructor function method field static var int
               char boolean void true false null this let do if else while return)
  SYMBOL  = %w({ } ( ) [ ] . , ; + - * / & | < > = ~)

  def initialize(jack_file)
    # jackファイルを開く
    file    = File.new(jack_file)
    # 1つの文字列ストリームに変換する
    stream  = convert_to_stream(file)
    # トークンの配列に分割する
    @tokens = divide_into_tokens(stream)
    @current_token = ''
  end

  def has_more_tokens?
    !@tokens.empty?
  end

  def advance
    @current_token = @tokens.shift
  end

  def token_type
    case @current_token[0]
    when /\d/
      :INT_CONST
    when /({|}|\(|\)|\[|\]|\.|,|;|\+|-|\*|\/|&|\||<|>|=|~)/
      :SYMBOL
    when /"/
      :STRING_CONST
    else
      case @current_token
      when /^(class|constructor|function|method|field|static|var|int|char|boolean|void|true|false|null|this|let|do|if|else|while|return)$/
        :KEYWORD
      else
        :IDENTIFIER
      end
    end
  end

  def keyword
    @current_token
  end

  def symbol
    if @current_token == '<'
      '&lt;'
    elsif @current_token == '>'
      '&gt;'
    elsif @current_token == '&'
      '&amp;'
    else
      @current_token
    end
  end

  def identifier
    @current_token
  end

  def int_val
    @current_token
  end

  def string_val
    @current_token.delete('"')
  end

  private

  # ファイルを1つの文字列ストリームに変換する
  # TODO: ここから、Square/SquareGame.jackがうまくトークナイズできておらず（他はすべてok）、原因は /** */型のコメントを取り除けていないから
  # コメントをストリームから取り除く作業から再開する
  def convert_to_stream(file)
    text = file.map { |e| e.gsub(/\/\/.*/, '') }
        .map { |e| e.gsub(/\/\*.*\*\//, '') }
        .map { |e| e.gsub(/\n/, '') }
        .map { |e| e.gsub(/\r/, '') }
        .map { |e| e.gsub(/\t/, '') }
        .map { |e| e.gsub(/^\s+/, '') }
        .reject(&:empty?)
        .join(' ')

    text.slice!(/\/\*\*(.|\s)*?\*\//)
    text
  end

  # 文字列ストリームを先頭から読んでいき、トークンに分割する
  def divide_into_tokens(stream)
    token_arr = []

    while !stream.empty?
      case stream[0]
      # 先頭の文字が空白ならば削除する
      when /\s/
        stream.slice!(0)
      # 先頭の文字が数字であるならば、INT_CONSTトークン確定。次に文字列ストリームに数字以外が出てくる(空白も含む)までをINT_CONSTトークンとして取り出す
      when /\d/
        token_arr << stream.slice!(/^\d+/)
      # 先頭の文字がシンボル（.や{など）であれば、SYMBOLトークン決定。その１文字だけを取り出す
      when /({|}|\(|\)|\[|\]|\.|,|;|\+|-|\*|\/|&|\||<|>|=|~)/
        token_arr << stream.slice!(/^./)
      # elsif 先頭の文字がダブルクォートであれば、StringConstantトークン決定。次にダブルクォートが出てくるまでを取り出す。ダブルクォートはあとで削除するためここではつけたまま。
      when /"/
        string_with_quote = stream.slice!(/^".*?"/)
        token_arr << string_with_quote
      else
        # 先頭の文字から空白までの間に、シンボルもしくはダブルクォートが含まれていれば
        if stream.slice(/^.+?\s/).slice(/({|}|\(|\)|\[|\]|\.|,|;|\+|-|\*|\/|&|\||<|>|=|~|")/)
          # 含まれていたシンボルもしくはダブルクォート
          symbol = stream.slice(/^.+?\s/).slice(/({|}|\(|\)|\[|\]|\.|,|;|\+|-|\*|\/|&|\||<|>|=|~|")/)

          # 含まれていたシンボルもしくはダブルクォートの直前までをtoken_arrに入れる
          rp = Regexp.escape("#{symbol}")
          token_with_symbol = stream.slice!(/^.*?#{rp}/)

          token_with_symbol.slice!(-1)
          token = token_with_symbol
          token_arr << token

          # 上記でシンボルもしくはダブルクォートをストリームから消してしまうので元に戻す
          stream.insert(0, "#{symbol}")

        # 先頭の文字から空白までの間に、シンボルもしくはダブルクォートが含まれていなければ、先頭の文字から空白までを全て取り出す（ただし空白は削除する）
        else
          token_with_blank = stream.slice!(/^.+?\s/)
          token_with_blank.slice!(-1)
          token = token_with_blank
          token_arr << token
        end
      end
    end

    token_arr
  end
end
