def download_url(url)
  url = URI.escape(url)
  url.gsub!(" ", "%20")
  io = open(url)
  logo_path = url.split("/").last
  if logo_path.length > 50
    logo_path = "preview.#{ logo_path[/(jpg|png)/i, 1] || "jpg" }"
  end
  io.define_singleton_method(:original_filename) do
    logo_path
  end
  io
rescue OpenURI::HTTPError
  $stderr.puts "FEHLER #{url} nicht gefunden"
  return nil
end
