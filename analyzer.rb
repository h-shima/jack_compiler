require_relative 'tokenizer'

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
  tokenized_xml = <<~"TOKENIZER".chomp
  <tokens>\n
  TOKENIZER
  xml_filename = File.basename(ARGV[0]).gsub('.jack', '')

  while tokenizer.has_more_tokens?
    tokenizer.advance
    token_type = tokenizer.token_type

    case token_type
    when :KEYWORD
      tokenized_xml += <<~"TOKENIZER".chomp
      <keyword>#{tokenizer.keyword}</keyword>\n
      TOKENIZER
    when :SYMBOL
      tokenized_xml += <<~"TOKENIZER".chomp
      <symbol>#{tokenizer.symbol}</symbol>\n
      TOKENIZER
    when :IDENTIFIER
      tokenized_xml += <<~"TOKENIZER".chomp
      <identifier>#{tokenizer.identifier}</identifier>\n
      TOKENIZER
    when :INT_CONST
      tokenized_xml += <<~"TOKENIZER".chomp
      <integerConstant>#{tokenizer.int_val}</integerConstant>\n
      TOKENIZER
    when :STRING_CONST
      tokenized_xml += <<~"TOKENIZER".chomp
      <stringConstant>#{tokenizer.string_val}</stringConstant>\n
      TOKENIZER
    end
  end

  # トークンをタグとしたXxxT.xmlファイルを出力する
  # 一旦tokenizerからXxxT.xmlファイルが正しく出力されることを確認する

  tokenized_xml += <<~"TOKENIZER".chomp
  </tokens>
  TOKENIZER

  File.open("./#{xml_filename}T.xml", 'w') do |file|
    file.puts tokenized_xml
  end
end
