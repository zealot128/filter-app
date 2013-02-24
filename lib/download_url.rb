def download_url(url)
  url.gsub!(" ","%20")
  io = open(url)
  logo_path = url.split("/").last
  io.define_singleton_method(:original_filename) do
    logo_path
  end
  io
rescue OpenURI::HTTPError
  $stderr.puts "FEHLER #{url} nicht gefunden"
  return nil
end

