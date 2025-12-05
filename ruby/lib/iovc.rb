# frozen_string_literal: true

require 'zeitwerk'

Zeitwerk::Loader.new.then do |loader|
  loader.tag = File.basename __FILE__, '.rb'
  loader.push_dir __dir__
  loader.setup
end

require "fileutils"
require "pathname"
require "session"
require "json"

class Iovc

  include Utils

  # Names of files in lib/templates
  PROMPT_NAMES = %i[system guidance method_missing error_message syntax_error].freeze

  # Treat missing methods for these classes as errors
  REROUTE_TO_FIX_ERROR_CLASSES = %w[String Integer Hash Array Time NilClass TrueClass FalseClass].freeze

  # Stop after this number of errors occurred. Set to a higher value for more complicated tasks
  MAX_ERROR_COUNT = 2

  def self.start(argv)
    @instance ||= self.new(argv)
  end

  def initialize(argv)
    if argv.length == 1
      @target_folder = Pathname.new(argv.first)

      if @target_folder.directory?
        if File.exist?("#{@target_folder}/instructions.md")
          start_development
          return
        else
          puts "File '#{@target_folder}/instructions.md' not found"
        end
      else
        puts "Target folder '#{@target_folder}' not found"
      end
    else
      puts "Please specify a target folder, for example: 'bin/iovc ../examples/demo'"
    end

    exit 1
  end

  private

  def start_development
    prepare_app
    prepare_prompts
    ask_for_guidance if new_application?

    @error_count = 0
    @finished = false
    while !@finished && @error_count < MAX_ERROR_COUNT do
      run_app
    end
  end

  def new_application?
    !File.exist?("#{@target_folder}/README.md")
  end

  def prepare_app
    puts "Prepare app '#{@target_folder}'"

    # Copy templates if not present
    Dir.children("#{__dir__}/templates").each do |filename|
      next if filename[-3..-1] != ".tt"

      source_filename = "#{__dir__}/templates/#{filename}"
      target_filename = "#{@target_folder}/#{filename.split("/").last[0..-4]}"

      if !File.exist?(target_filename)
        puts "Copying template: '#{filename}'"
        FileUtils.copy(source_filename, target_filename)
      end
    end
  end

  def prepare_prompts
    @instructions = IO.read("#{@target_folder}/instructions.md")

    @prompts = PROMPT_NAMES.to_h do |name|
      [
        name,
        IO.read("#{__dir__}/prompts/#{name}.md")
      ]
    end

    @llm = Llm.new
  end

  def ask_for_guidance
    puts "Asking LLM for guidance on application structure"

    user_prompt = @prompts[:guidance]
      .dup
      .sub("${instructions}", @instructions)
      .sub("${code}", IO.read("#{@target_folder}/app.rb"))

    response = @llm.ask(:guide, system_prompt, user_prompt)

    if response.json.is_a?(Hash) && response.json.key?("structure") && response.json.key?("classes")
      FileUpdater.new(:guidance, @target_folder, response)
    else
      puts "No json found!"
      p response
      @error_count += 1
    end
  end

  def system_prompt = @prompts[:system]

  def run_app
    puts "Running app"
    response = iteration

    if response.is_a?(Hash)
      case response["error"].to_sym
      when :method_missing
        ask_for_more_code(response)
      when :exception
        ask_for_fix_error(response)
      when :syntax_error
        ask_for_fix_syntax(response)
      end
    else
      puts response
      @finished = true
    end
  end

  def ask_for_more_code(response)
    filepath    = Pathname("#{@target_folder}/#{underscore(response["class"])}.rb")
    called_from = response["caller"].first.split(":").last[3..]

    if !File.exist?(filepath)
      if REROUTE_TO_FIX_ERROR_CLASSES.include?(response["class"])
        ask_for_fix_error({
          "error"   => "No method",
          "message" => "#{response["class"]} #{response["method"]} #{response["caller"].first.split(":").last}",
          "caller"  => response["caller"]
        })
        return
      end

      if response["class"] == "Class"
        puts "Tried to use a class method!"
        @error_count += 1
        return
      end

      puts "No target file found to add method to!"
      p response
      @error_count += 1
      return
    end

    arguments = if !response["args"].empty?
      "\n- The function is called with these arguments: #{response["args"].map { |a| "#{a["value"]} (#{a["class"]})" }.join(', ')}."
    end || ""

    user_prompt = @prompts[:method_missing]
      .dup
      .sub("${instructions}", @instructions)
      .sub("${readme}", File.exist?("#{@target_folder}/README.md") ? IO.read("#{@target_folder}/README.md") : "")
      .sub("${code}", IO.read(filepath))
      .sub("${arguments}", arguments)
      .gsub("${method_missing}", response["method"])

    puts "Asking LLM code for method: '#{response["class"]}.#{response["method"]}' called from: #{called_from}"
    response = @llm.ask(:code, system_prompt, user_prompt)

    if response.json.is_a?(Hash) && response.json.key?("code")
      FileUpdater.new(:method_missing, @target_folder, response, filepath)
    else
      puts "No code found!"
      p response
      @error_count += 1
    end
  end

  def ask_for_fix_error(response)
    filepath = Pathname(response["caller"].first.split(":").first)

    if !File.exist?(filepath)
      puts "No target file found to fix error in!"
      p response
      @error_count += 1
      return
    end

    user_prompt = @prompts[:error_message]
      .dup
      .sub("${instructions}", @instructions)
      .sub("${code}", IO.read(filepath))
      .sub("${error_message}", "#{response["error"]}: #{response["message"]}")

    puts "Asking LLM to fix code for error: '#{response["message"]}'"
    response = @llm.ask(:code, system_prompt, user_prompt)

    if response.json.is_a?(Hash) && response.json.key?("code")
      FileUpdater.new(:error_message, @target_folder, response, filepath)
    else
      puts "No code found!"
      p response
      @error_count += 1
    end
  end

  def ask_for_fix_syntax(response)
    filepath = Pathname(response["message"].split(":").first)

    if !File.exist?(filepath)
      puts "No target file found to fix syntax error in!"
      p response
      @error_count += 1
      return
    end

    user_prompt = @prompts[:syntax_error]
      .dup
      .sub("${instructions}", @instructions)
      .sub("${code}", IO.read(filepath))
      .sub("${error_message}", response["message"].split("\n")[1..].join("\n"))

    puts "Asking LLM to fix syntax error"
    response = @llm.ask(:code, system_prompt, user_prompt)

    if response.json.is_a?(Hash) && response.json.key?("code")
      FileUpdater.new(:error_message, @target_folder, response, filepath)
    else
      puts "No code found!"
      p response
      @error_count += 1
    end
  end

  def iteration
    bash_execute(test_script, /YAML|RubyGems/)
  ensure
    @bash.close! if @bash
    @bash = nil
  end

  def test_script
    [
      "cd #{@target_folder.realpath} > /dev/null;",
      "bundle install > /dev/null;",
      "ruby main.rb",
    ].join("\n")
  end

  def bash_execute(commands, ignore_errors = nil)
    @bash ||= Session::Bash::Login.new

    response = nil
    @bash.execute(commands) do |out, err|
      if out
        log(:app_run, "", out)

        if out[0] == "{"
          response = JSON.parse(out)
        else
          puts out
        end
      end

      if err && (!ignore_errors || err !~ ignore_errors)
        puts "Errors: #{err}"
        puts "\nCommand(s):\n#{commands}"
        exit 2
      end
    end

    response
  end
end
