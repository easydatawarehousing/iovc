# Made by 'qwen3:14b' with some edits (split, join) and proper indentation by me
#
# Spaces should have also be added to the 'text_lines'.
# And forward slashes should also be reversed.
class CowDirectionReverser

  def reverse(input)
    lines = input.split("\n")
    text_lines = lines[0..2]
    cow_lines = lines[3..-1]

    processed_cow_lines = cow_lines.map do |line|
      reversed_line = line.reverse
      flipped_line = reversed_line.gsub("\\", "/")
      flipped_line
    end

    longest_line_length = processed_cow_lines.max_by(&:length).length

    adjusted_cow_lines = processed_cow_lines.map do |line|
      spaces = ' ' * (longest_line_length - line.length)
      "#{spaces}#{line}"
    end

    result_lines = text_lines + adjusted_cow_lines
    result_lines.join("\n")
  end
end
