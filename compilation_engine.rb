# TODO: クラス宣言とクラス変数宣言だけのXxxT.xmlファイルは正常にパースできる状態
# TODO: 次回はcompile_subroutine_decルーチンの実装から
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
    end

    while @current_token =~ /(constructor|function|method)/
      compile_subroutine_dec
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

  def compile_subroutine_dec
    expect('(constructor|function|method)')
    expect('(void|int|char|boolean|identifier)')
    expect('identifier')
    expect('(')
    # compile_parameter_list
    expect(')')
    # compile_subroutine_body
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


