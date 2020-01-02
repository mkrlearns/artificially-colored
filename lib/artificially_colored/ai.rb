class ArtificiallyColored::AI

  def connect(array)
    uri = URI.parse("http://colormind.io/api/")
    request = Net::HTTP::Post.new(uri)
    if array == []
      request.body = JSON.dump({ "model" => "default" })
    else
      request.body = JSON.dump({ "model" => "default", "input" => array })
    end
    req_options = { use_ssl: uri.scheme == "https" }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    if response.code == '200'
      palette = []
      json = JSON.parse(response.body)
      json['result'].each do |color|
        palette << ArtificiallyColored::Scraper.new("rgb(#{color.to_s.delete('[]')})")
      end
      return palette
    else
      return
    end
  end

end
