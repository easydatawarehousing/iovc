# Represents a single markdown article, storing its front‑matter metadata and raw markdown content.
class Article

  def front_matter=(front_matter)
    @title = front_matter[:title]
    @date = front_matter[:date]
    @tags = front_matter[:tags]
  end

  def content=(content)
    @content = content
  end

  def filename=(filename)
    @filename = filename
  end

  def filename
    @filename
  end

  def content
    @content
  end

  def title
    @title
  end
end
