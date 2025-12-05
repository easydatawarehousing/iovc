Build a command line application in Ruby that takes a string as an argument (use 'Hello world' as default when no argument is given), then runs and captures the output of 'cowsay'. Next the application should flip the direction the cow is looking in (so reverse the entire cow to make it look to the right) and prints the reversed output. Only reverse the cow not the text!

Note that:
- Cowsay is a command line utility that takes a string as input and outputs: a line of dashes (_), followed by the input string, then another line of dashes (-), the final 5 lines show an ascii art cow looking to the left. So the text has 3 lines, the cow 5 lines
- you can use the 'reverse' method for a string to flip it contents.
- to split a string into separate lines use: `string.split("\n")`. And to join use: `array.join("\n")`
- you need to determine the width of the cow. In Ruby: `longest_line_length = cow_lines.max_by(&:length).length`.
  Then you need to prepend that number of spaces to all lines. In Ruby: `map { |line| "#{' ' * (longest_line_length - line.length)}#{line}" }`
- you need to flip all \ characters in the cow