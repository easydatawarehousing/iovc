# Contains the bubble sort algorithm implementation. Provides a method to sort an array.
class BubbleSort

  def sort(array)
    arr = array.dup
    n = arr.length
    loop do
      swapped = false
      (n - 1).times do |i|
        if arr[i] > arr[i + 1]
          arr[i], arr[i + 1] = arr[i + 1], arr[i]
          swapped = true
        end
      end
      break unless swapped
    end
    arr
  end
end
