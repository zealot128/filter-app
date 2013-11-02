require "httparty"
module Fetcher
  module_function
  class FetcherResponse < Struct.new(:code, :body, :content_type, :location)
  end

  HTTP_OPTIONS = {
    headers: {
      "User-Agent" => "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:22.0) Gecko/20100101 Firefox/22.0",
      "Accept-Language" => "de-de,de,en-us,en",
      "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
      #"Accept" => "text/html,application/xhtml+xml,application/xml"
    },
    format: :text
  }
  # Ruft eine URL auf, probiert es mehrmals
  # liefert eine Struktur FetcherResponse zurueck
  #
  # Wir probieren 4x mit groesser werdenden Abstand
  #
  def fetch_url(url, check_link=false)
    options = HTTP_OPTIONS.merge( :base_uri => URI.parse(url).base_url)
    response = nil
    [0,5,20,60].each do |seconds|
      response = HTTParty.get url, options
      puts response.code
      break if response.code < 400 or response.code == 404
      break if check_link
      Kernel.sleep seconds
    end
    if response.request and redirected = response.request.path and redirected.to_s != url
      location = redirected.to_s
    else
      location = nil
    end
    FetcherResponse.new response.code, response.body, response.content_type, location
  rescue Errno::ETIMEDOUT, Timeout::Error => e
    return FetcherResponse.new 408, e.to_s, "", ""
  rescue SocketError => e
    if e.to_s["getaddrinfo"]
      message = "Die Webadresse konnte nicht gefunden werden (DNS-Problem)"
    else
      message = e.to_s
    end
  end

  def real_url(url)
    response = Fetcher.fetch_url(url)
    url = response.location || url
    url.gsub(/\?utm_source.*/,"")
  end

  class URI::HTTP
    def base_url
      bla = self
      bla.path = "/"
      bla.query = nil
      bla.fragment = nil
      bla.to_s
    end
  end

end
