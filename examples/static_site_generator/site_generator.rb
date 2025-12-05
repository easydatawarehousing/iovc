# Handles scanning the articles directory, parsing files, rendering pages, building navigation, and writing output to the dist folder.
class SiteGenerator

  def build
    articles = []
    home_article = nil

    # Scan articles directory
    Dir.glob('articles/*.md').each do |file|
      # Parse front matter and content
      parsed = FrontMatterParser::Parser.parse_file(file)
      front_matter = parsed.front_matter
      content = parsed.content

      # Create Article instance
      article = Article.new
      article.front_matter = front_matter
      article.content = content
      article.filename = File.basename(file, '.md')

      # Identify home article
      if article.filename == 'home'
        home_article = article
      end

      articles << article
    end

    # Create output directory if needed
    output_dir = 'dist'
    Dir.mkdir(output_dir) unless Dir.exist?(output_dir)

    # Generate HTML for each article
    articles.each do |article|
      renderer = TemplateRenderer.new
      html = renderer.render(article, articles)

      # Write to output directory
      output_file = File.join(output_dir, "#{article.filename}.html")
      File.open(output_file, 'w') do |f|
        f.write(html)
      end
    end
  end
end
