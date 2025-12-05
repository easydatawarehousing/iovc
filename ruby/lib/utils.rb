# frozen_string_literal: true

module Utils
  # From ActiveSupport::Inflector
  def underscore(camel_cased_word)
    return camel_cased_word.to_s.dup unless /[A-Z-]|::/.match?(camel_cased_word)

    word = camel_cased_word.to_s.gsub("::", "/")
    word.gsub!(/(?<=[A-Z])(?=[A-Z][a-z])|(?<=[a-z\d])(?=[A-Z])/, "_")
    word.tr!("-", "_")
    word.downcase!
    word
  end

  def log(type, model, message)
    return if message.to_s.strip.empty?

    File.open("llm_calls.log", "a+") do |f|
      f.puts "═ #{Time.now.localtime.strftime("%Y-%m-%d %H:%M:%S")} - #{type} - #{model} #{'═' * 140}"[0, 150]
      f.puts message
    end
  end
end
