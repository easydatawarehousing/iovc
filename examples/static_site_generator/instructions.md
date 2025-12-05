Build a Static Site Generator, a command line application in Ruby that converts a collection of articles into a cohesive website.
Articles are located in subfolder 'articles' and are in markdown format, with frontmatter. The article named "home" will serve as the site home page.

The tool must:
1. Parse every Markdown file in the `articles` subfolder, extracting the front‑matter metadata (title, date, tags)
2. Render each article into an HTML page, applying a consistent layout template. Hardcode the html for the layout
3. Build a navigation menu that lists all articles and highlights the current page. Hardcode the html for the menu
4. Output to a ready‑to‑deploy directory `dist` containing the generated HTML files. For now ignore CSS and assets

# Sample article content

```
---
title: "My First Post"
date: "2024-10-01"
tags: [static-site, generator]
---
# Heading

Markdown content...
```

You can use gem "front_matter_parser". Use it like this to get both frontmatter as a Hash and the article content as a String:

```
parsed = FrontMatterParser::Parser.parse_file("article.md")
parsed.front_matter #=> {"title" => "My First Post", "date" => "2024-10-01", "tags" => ["static-site", "generator"]}
parsed.content #=> "Markdown content..."
```

You can use gem "kramdown" to convert markdown to html like this:

```
html = Kramdown::Document.new(text).to_html
```