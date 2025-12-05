# Produces the final HTML for an article by applying a hard‑coded layout and inserting a navigation menu.
class TemplateRenderer

  def render(article, all_articles)
    # Convert markdown content to HTML
    html_content = Kramdown::Document.new(article.content).to_html

    # Generate navigation menu
    menu_items = all_articles.map do |a|
      current_class = a.filename == article.filename ? 'class="current"' : ''
      "<li><a #{current_class} href="#{a.filename}.html">#{a.title}</a></li>"
    end
    menu_html = "<nav><ul>#{menu_items.join}</ul></nav>"

    # Hardcoded layout template
    layout = <<~HTML
    <!DOCTYPE html>
    <html>
    <head><title>#{article.title}</title></head>
    <body>
    #{menu_html}
    <main>#{html_content}</main>
    </body>
    </html>
    HTML

    layout
  end
end
