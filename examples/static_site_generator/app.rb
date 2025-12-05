class App

  def initialize
    run_app
  end

  def run_app
    site_generator = SiteGenerator.new
    site_generator.build
  end
end
