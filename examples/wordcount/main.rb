# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

Zeitwerk::Loader.new.then do |loader|
  loader.tag = File.basename __FILE__, '.rb'
  loader.push_dir __dir__
  loader.setup
end

require "json"

# Override 'method_missing' at the lowest possible level
class BasicObject

  private

  def method_missing(symbol, *args)
    return if self.to_s == "RubyVM::InstructionSequence" || %i[to_io to_int to_ary to_hash].include?(symbol)

    puts({
      error:  "method_missing",
      class:  self.class,
      method: symbol,
      args:   args.map { |a| { class: a.class, value: a.to_s } },
      caller: caller
    }.to_json)

    exit
  end
end

# Application entry point and error trapping
begin
  App.new
rescue SyntaxError => e
  puts({
    error:  "syntax_error",
    message: e.message
  }.to_json)
rescue => e
  puts({
    error:  "exception",
    message: e.message,
    caller:  e.backtrace
  }.to_json)
end
