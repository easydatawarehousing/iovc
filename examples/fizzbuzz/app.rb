# The code will have an App class that orchestrates the application flow. It will iterate through integers 1 to 100 and use a FizzBuzz class to determine the output for each number. The FizzBuzz class encapsulates the business logic for determining the correct output based on divisibility rules.
# Application entry point
class App

  def initialize
    run_app
  end

  def run_app
  (1..100).each do |i|
  fizz_buzz = FizzBuzz.new
  result = fizz_buzz.get_result(i)
  puts result
  end
  end
end
