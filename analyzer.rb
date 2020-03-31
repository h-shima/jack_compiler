module Analyzer
  # ターミナルからこのクラスを実行することによって、
  # Tokenizer, CompilationEngineを実行する。
  #
  # 1. tokenizerを実行してXxxT.xmlファイルを出力する
  #
  # 2. tokenizerを実行することによって生成されるXxxT.xmlファイルをCompilationEngineに渡して
  #    実行し、Xxx.xmlファイルを出力する
  #
  # 3. Analyerの引数としてディレクトリが渡ってきても対応できるようにする
  #    具体的には、ディレクトリ以下の.jackファイルそれぞれに対応する.xmlファイルを出力できるようにする

  tokenizer = Tokenizer.new(ARGV[0])

  while tokenizer.has_more_tokens?
    token_type    = tokenizer.token_type

    case token_type
    when :KEYWORD

    when :SYMBOL

    when :IDENTIFIER

    when :INT_CONST

    when :STRING_CONST

    end

    tokenizer.advance
  end

  # トークンをタグとしたXxxT.xmlファイルを出力する
  # 一旦tokenizerからXxxT.xmlファイルが正しく出力されることを確認する
end
