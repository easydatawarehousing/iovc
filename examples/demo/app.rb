# The code will have an entry point class (App) that initializes and runs the application. It will create an array, use a BubbleSort class to sort it, and output the result. The BubbleSort class will contain the algorithm implementation.
# Application entry point
class App

  def initialize
    run_app
  end

  def run_app
    number = [17, 1, 42, 9, -2].freeze
    bubble_sort = BubbleSort.new
    sorted_array = bubble_sort.sort(number)
    puts "Sorted array: #{sorted_array.inspect}"
  end
end
