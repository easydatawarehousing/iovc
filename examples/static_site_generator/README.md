The application is organized into several small, focused classes that each own a single responsibility. The flow is:

1. **App** – The entry point that creates a `SiteGenerator` instance and triggers the build.
2. **SiteGenerator** – Orchestrates the whole process: scans the `articles` folder, parses each file, renders the article, builds the navigation menu, and writes the output to `dist`.
3. **Article** – Represents a single markdown article. It holds the parsed front‑matter metadata and the raw markdown content.
4. **TemplateRenderer** – Encapsulates the hard‑coded HTML layout and menu. It receives an `Article` and the list of all articles to produce the final HTML string.

Each class uses only the Ruby standard library except for two small gems that handle front‑matter parsing and markdown conversion.

The directory layout is:
```
project_root/
├─ app.rb          # contains the App class
├─ site_generator.rb
├─ article.rb
├─ template_renderer.rb
├─ articles/      # markdown files with front‑matter
└─ dist/          # generated html files
```

All output files are written into `dist/` preserving the article name (e.g., `home.html`). The `home` article is treated specially as the site’s root page.