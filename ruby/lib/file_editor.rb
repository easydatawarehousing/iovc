# frozen_string_literal: true

require 'prism'

# Insert a method at the end of a class definition
class FileEditor

  def initialize(filepath)
    @filepath = filepath
    @source   = IO.read(@filepath)
    @prism    = Prism.parse(@source)
  end

  def add_class_method(method_source)
    if (end_node = find_end_of_class)
      add_method(end_node, method_source)
      return true
    end

    false
  end

  private

  # Use Prism to find class definition in source
  class SelectFirstClassVisitor < Prism::Visitor

    attr_reader :nodes

    def initialize(nodes)
      @nodes = nodes
    end

    def visit_class_node(node)
      @nodes << node
      super
    end
  end

  def find_end_of_class
    nodes = []
    @prism.value.accept(SelectFirstClassVisitor.new(nodes))
    nodes.length.positive? ? nodes.first : nil
  end

  def add_method(end_node, method_source)
    puts "Add a method to '#{@filepath}'"
    f = File.open(@filepath, "w")
    f.write @source[0, end_node.end_keyword_loc.start_character_offset]
    f.write "\n#{indent_lines(method_source)}\n"
    f.write @source[end_node.end_keyword_loc.start_character_offset..]
    f.close
  end

  def indent_lines(lines, level = 1)
    lines.split("\n").map { |l| "#{'  ' * level}#{l.strip}" }.join("\n")
  end
end
