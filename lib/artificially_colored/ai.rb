class ArtificiallyColored::AI

  def ai_connect
    test = [[44,43,44],[90,83,82],"N","N","N"]
    
    uri = URI.parse("http://colormind.io/api/")
    request = Net::HTTP::Post.new(uri)
    request.body = JSON.dump({ "model" => "default", "input" => test })
    
    req_options = { use_ssl: uri.scheme == "https" }
    
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    
    if response.code == '200'
      puts response.body
    else
      puts 'Unable to connect to API.'
    end
  end

end
