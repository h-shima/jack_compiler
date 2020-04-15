# TODO: 次回やること
# $ruby compilation_engine.rb tests/letStatementT.xmlをエラーを発生させずにパースできるようにする
# 各メソッドごとに同じようなテストをした方がいいかも。

class CompilationEngine
  attr_reader :xml_stream
  # 入力としてXxxT.xmlファイル（JackTokenizerによってトークナイズされたファイル）を受け取り、
  # 構文解析されたXxx.xmlファイルを出力する。

  def initialize(tokenized_file)
    @tokens        = trim(tokenized_file)
    @current_token = ''
    @prev_token    = ''
    @xml_stream    = ''
    # compile_classルーチンを呼ぶ
    # 呼び出されたcompile_classルーチンから実行が返ってきたら（= ファイル内を全て構文解析し終わったら）、
    # Xxx.xmlファイルに構文解析の結果を格納して出力する
  end

  def advance
    @prev_token    = @current_token
    @current_token = @tokens.shift

    true
  end

  def accept(token)
    if @current_token =~ /#{token}/
      advance
    else
      false
    end
  end

  def accept_op(token)
    # opが <> の時、タグがマッチしてしまうのでタグを削除する
    current_token_without_tag = @current_token.gsub(/^\s*<[^>]*>/, '')
    current_token_without_tag = current_token_without_tag.gsub(/<[^<]+>\s*$/, '')

    if current_token_without_tag =~ /#{token}/
      advance
    else
      false
    end
  end

  def expect(token)
    if accept(token)
      true
    else
      raise StandardError.new('expect: unexpected token');
    end
  end

  # 'class' className '{' classVarDec* subroutineDec* '}'
  def compile_class
    expect('class')
    write('<class>')
    write(@prev_token)
    expect('identifier')
    write(@prev_token)
    expect('{')
    write(@prev_token)

    while @current_token =~ /(static|field)/
      compile_class_var_dec
    end # ここまでは正しそう

    while @current_token =~ /(constructor|function|method)/
      compile_subroutine
    end

    expect('}')
    write(@prev_token)
    write('</class>')
  end

  def compile_class_var_dec
    expect('(static|field)')
    write('<classVarDec>')
    write(@prev_token)
    expect('(int|char|boolean|identifier)')
    write(@prev_token)
    expect('identifier')
    write(@prev_token)

    while accept(',')
      write(@prev_token)
      expect('identifier')
      write(@prev_token)
    end

    expect(';')
    write(@prev_token)
    write('</classVarDec>')
  end

  def compile_subroutine
    expect('(constructor|function|method)')
    write('<subroutineDec>')
    write(@prev_token)
    expect('(void|int|char|boolean|identifier)')
    write(@prev_token)
    expect('identifier')
    write(@prev_token)
    expect('\(')
    write(@prev_token)

    compile_parameter_list

    expect('\)')
    write(@prev_token)

    # ここからsubroutineBody
    expect('{')
    write('<subroutineBody>')
    write(@prev_token)

    while @current_token =~ /var/
      compile_var_dec
    end # ここまで正しそう @current_token == ExpressionLessSquare/MainT.xml:61, 描画はMain.xml:98まで終わっている状態

    compile_statements # ここまで正しそう @current_token == MainT.xml:107, 描画Main.xml:200

    expect('}')
    write(@prev_token)
    write('</subroutineBody>')
    # ここまでsubroutineBody

    write('</subroutineDec>')
  end

  def compile_parameter_list
    #　続くif文の条件分岐がfalseであったとしても、<parameterList></parameterList>は必要
    write('<parameterList>')

    if accept('(int|char|boolean|identifier)')
      write(@prev_token)
      expect('identifier')
      write(@prev_token)

      while accept(',')
        write(@prev_token)
        expect('(int|char|boolean|identifier)')
        write(@prev_token)
        expect('identifier')
        write(@prev_token)
      end
    end

    write('</parameterList>')
  end

  def compile_var_dec
    expect('var')
    write('<varDec>')
    write(@prev_token)

    expect('(int|char|boolean|identifier)')
    write(@prev_token)

    expect('identifier')
    write(@prev_token)

    while accept(',')
      write(@prev_token)
      expect('identifier')
      write(@prev_token)
    end

    expect(';')
    write(@prev_token)

    write('</varDec>')
  end

  def compile_statements
    write('<statements>')

    while @current_token =~ /(let|if|while|do|return)/
      case @current_token
      when /let/
        compile_let
      when /if/
        compile_if
      when /while/
        compile_while
      when /do/
        compile_do
      when /return/
        compile_return
      end
    end

    write('</statements>')
  end

  def compile_let
    expect('let')
    write('<letStatement>')
    write(@prev_token)

    expect('identifier')
    write(@prev_token)

    if accept('\[')
      write(@prev_token)
      compile_expression
      expect('\]')
      write(@prev_token)
    end

    expect('=')
    write(@prev_token)

    compile_expression

    expect(';')
    write(@prev_token)

    write('</letStatement>')
  end

  def compile_if
    expect('if')
    write('<ifStatement>')
    write(@prev_token)

    expect('\(')
    write(@prev_token)

    compile_expression

    expect('\)')
    write(@prev_token)

    expect('\{')
    write(@prev_token)

    compile_statements

    expect('\}')
    write(@prev_token)

    if accept('else')
      write(@prev_token)
      expect('\{')
      write(@prev_token)

      compile_statements

      expect('\}')
      write(@prev_token)
    end

    write('</ifStatement>')
  end

  def compile_while
    expect('while')
    write('<whileStatement>')
    write(@prev_token)

    expect('(')
    write(@prev_token)

    compile_expression

    expect(')')
    write(@prev_token)

    expect('{')
    write(@prev_token)

    compile_statements

    expect('}')
    write(@prev_token)

    write('</whileStatement>')
  end

  def compile_do
    expect('do')
    write('<doStatement>')
    write(@prev_token)

    compile_subroutine_call

    expect(';')
    write(@prev_token)

    write('</doStatement>')
  end

  def compile_return
    expect('return')
    write('<returnStatement>')
    write(@prev_token)

    if @current_token =~ /(integerConstant|stringConstant|true|false|null|this|identifier|\(|-|~)/
      compile_expression
    end

    expect(';')
    write(@prev_token)

    write('</returnStatement>')
  end

  def compile_expression
    write('<expression>')

    compile_term

    while accept_op('(\+|\-|\*|\/|&|\||\<|\>|\=)')
      write(@prev_token)

      compile_term
    end

    write('</expression>')
  end

  def compile_term
    if @current_token =~ /(integerConstant|stringConstant|true|false|null|this|identifier|\(|-|~)/
      write('<term>')

      case @current_token
      when /integerConstant/
        expect('integerConstant')
        write(@prev_token)
      when /stringConstant/
        expect('stringConstant')
        write(@prev_token)
      when /keywordConstant/
        expect('keywordConstant')
        write(@prev_token)
      when /\(/
        expect('\(')
        write(@prev_token)

        compile_expression

        expect('\)')
        write(@prev_token)
      when /[-~]/
        expect('(-|~)')
        write(@prev_token)

        compile_term
      when /identifier/
        # 先読みが必要な式たち
        # @tokens.firstは<symbol> ; </symbol>のはず
        case @tokens.first     # @current_tokenの次にくるトークン
        when /\[/ # '[' expression ']'
          expect('identifier')
          write(@prev_token)

          compile_expression

          expect('identifier')
          write(@prev_token)
        when /\(/ # subroutine_call
          compile_subroutine_call
        else # varName単体
          expect('identifier')
          write(@prev_token)
        end
      end

      write('</term>')
    end
  end

  # <subroutineCall> タグはつけない
  def compile_subroutine_call
    expect('identifier')
    write(@prev_token)

    if @current_token.match('\(')
      expect('\(')
      write(@prev_token)

      compile_expression_list

      expect('\)')
      write(@prev_token)
    else
      expect('\.')
      write(@prev_token)

      expect('identifier')
      write(@prev_token)

      expect('\(')
      write(@prev_token)

      compile_expression_list

      expect('\)')
      write(@prev_token)
    end
  end

  def compile_expression_list
    write('<expressionList>')

    if @current_token =~ /(integerConstant|stringConstant|true|false|null|this|identifier|\(|-|~)/
      compile_expression

      while accept(',')
        write(@prev_token)
        compile_expression
      end
    end

    write('</expressionList>')
  end

  private

  def trim(tokenized_file)
    tokens = File.new(tokenized_file).readlines
    tokens.shift
    tokens.pop
    tokens.map { |token| token.gsub!(/\n$/, '') }
  end

  def write(value)
    @xml_stream += <<~"COMPILATION_ENGINE"
    #{value}
    COMPILATION_ENGINE
  end
end

compilation_engine = CompilationEngine.new(ARGV[0])

compilation_engine.advance
compilation_engine.compile_class

File.open("./Test.xml", 'w') do |file|
  file.puts compilation_engine.xml_stream
end


