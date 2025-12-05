class App

  def initialize
    run_app
  end

  def run_app
    # Parse command line argument or use default
    message = ARGV.first || 'Hello world'

    # Execute cowsay command
    cowsay_output = CowsayRunner.new.run(message)

    # Reverse cow direction
    reversed_output = CowDirectionReverser.new.reverse(cowsay_output)

    # Print final output
    puts reversed_output
  end
end
