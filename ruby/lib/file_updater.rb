# frozen_string_literal: true

# Manipulate contents of Ruby files
class FileUpdater

  include Utils

  def initialize(type, target_folder, response, filepath = nil)
    @target_folder = target_folder
    @response = response
    @filepath = check_filepath_inside_target_folder(filepath)

    case type
    when :guidance
      handle_guidance
    when :method_missing
      handle_method_missing
    when :error_message
      handle_error_message
    end

    add_new_gems
  end

  private

  def check_filepath_inside_target_folder(filepath)
    if filepath
      target = @target_folder.realpath.to_s
      raise "Invalid path: '#{filepath}'" if target != filepath.realpath.to_s[0, target.length]
      filepath
    end
  end

  def handle_guidance
    structure = @response.json.key?("structure") ? @response.json["structure"].to_s.strip : nil

    if structure
      IO.write("#{@target_folder}/README.md", structure)
    end

    if (@response.json["classes"] || []).length.positive?
      @response.json["classes"].each do |class_data|
        ruby_file = Pathname.new("#{@target_folder}/#{underscore(class_data["class_name"])}.rb")
        FileUtils.mkdir_p(ruby_file.dirname)

        if !File.exist?(ruby_file)
          puts "Creating file '#{ruby_file.realdirpath}' for class: '#{class_data["class_name"]}'"

          File.open(ruby_file, 'w') do |f|
            f.puts "# #{class_data["class_description"]}"
            f.puts "class #{class_data["class_name"]}"
            f.puts "end\n"
          end
        end
      end
    end
  end

  def handle_method_missing
    # TODO: First check if new code parses okay?
    FileEditor.new(@filepath).add_class_method(response_code)
  end

  def handle_error_message
    File.open(@filepath, 'w') do |f|
      f.write(response_code)
    end
  end

  def response_code
    r = @response.json["code"].gsub('\n', "\n")

    if r.include?("```")
      r.split(/```(?:[ ])?(?:[\n])?(?:ruby)?/)[1].strip
    else
      r
    end
  end

  def add_new_gems
    if (@response.json["gem_names"] || []).length.positive?
      gems_to_add = @response.json["gem_names"].dup

      f = File.open("#{@target_folder}/Gemfile", 'a+')
      f.readlines.each do |l|
        line = l.strip
        next if line.empty?

        gem = line.scan(/\Agem\s*["']{1}([a-zA-Z\-_\d]*)["']{1}[ ,]*.*\z/)&.first&.first
        gems_to_add.delete(gem) if gem
      end

      gems_to_add.each do |gem|
        puts "Add gem: '#{gem}'"
        f.puts "\ngem \"#{gem}\""
      end

      f.close
    end
  end
end
