def download_url(url)
  url = URI::DEFAULT_PARSER.escape(url).gsub(" ", "%20").gsub(" ", "%20")
  io = URI.open(url)
  logo_path = url.split("/").last
  if logo_path.length > 50
    logo_path = "preview.#{logo_path[/(jpg|png)/i, 1] || 'jpg'}"
  end
  io.define_singleton_method(:original_filename) do
    logo_path
  end
  io
rescue OpenURI::HTTPError
  warn "FEHLER #{url} nicht gefunden"
  nil
end
