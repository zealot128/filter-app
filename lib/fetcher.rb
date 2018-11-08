require "httparty"
module Fetcher
  module_function

  class FetcherResponse < Struct.new(:code, :body, :content_type, :location)
  end

  HTTP_OPTIONS = {
    headers: {
      "User-Agent" => "User-Agent"=>"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:64.0) Gecko/20100101 Firefox/64.0",
      "Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      "Accept-Language" => "de-de,de,en-us,en",
      # "Accept" => "text/html,application/xhtml+xml,application/xml"
    },
    timeout: 8,
    format: :text
  }.freeze
  # Ruft eine URL auf, probiert es mehrmals
  # liefert eine Struktur FetcherResponse zurueck
  #
  # Wir probieren 4x mit groesser werdenden Abstand
  #
  def fetch_url(url, check_link = false, retries = [0, 5])
    options = HTTP_OPTIONS.merge(base_uri: URI.parse(url).base_url)
    response = nil
    retries.each do |seconds|
      response = HTTParty.get url, options
      if response.code != 200
        puts "Error with #{url}"
        puts response.code
      end
      break if response.code < 400 or response.code == 404
      break if check_link
      Kernel.sleep seconds
    end
    location = if response.request and (redirected = response.request.path) and redirected.to_s != url
                 redirected.to_s
               end
    FetcherResponse.new response.code, response.body, response.content_type, location
  rescue Errno::ETIMEDOUT, Timeout::Error => e
    return FetcherResponse.new 408, e.to_s, "", ""
  rescue SocketError => e
    if e.to_s["getaddrinfo"]
      "Die Webadresse konnte nicht gefunden werden (DNS-Problem)"
    else
      e.to_s
    end
  end

  def real_url(url)
    response = Fetcher.fetch_url(url)
    url = response.location || url
    url.gsub(/\?utm_source.*/, "")
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
