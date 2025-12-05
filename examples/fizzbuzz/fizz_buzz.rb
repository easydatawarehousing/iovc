# Encapsulates the logic to determine the FizzBuzz output for a given integer based on divisibility rules.
class FizzBuzz

  def get_result(i)
  if i % 15 == 0
  'FizzBuzz'
  elsif i % 3 == 0
  'Fizz'
  elsif i % 5 == 0
  'Buzz'
  else
  i.to_s
  end
  end
end
