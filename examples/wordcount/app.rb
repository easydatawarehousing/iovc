# The code will have a single class 'App' that handles command line arguments, file processing, line/word counting, and error handling. The class will use instance methods to separate concerns while keeping the logic contained within a single class as per the simplicity requirement.
class App

  def initialize
    run_app
  end

  def run_app
  file_path = ARGV.first || 'instructions.md'
  
  begin
  File.open(file_path, 'r') do |file|
  line_count = 0
  word_count = 0
  file.each_line do |line|
  line_count += 1
  word_count += line.split.size
  end
  puts "Lines: #{line_count}, Words: #{word_count}"
  end
  rescue Errno::ENOENT
  puts "Error: File not found."
  end
  end
end
