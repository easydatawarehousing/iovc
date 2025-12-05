require "open3"

class CowsayRunner

  # Executes the external `cowsay` command with a given message and captures its output.
  def run(message)
    output, stderr, status = Open3.capture3('cowsay', message)
    output
  end
end