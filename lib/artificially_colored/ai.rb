class ArtificiallyColored::AI

  def ai_connect(array)

    if array.include(',') then array = array.split(',')
    else array = [array.strip] end
    
    # array.map! { |color| convert_color...
    
    
    uri = URI.parse("http://colormind.io/api/")
    request = Net::HTTP::Post.new(uri)
    request.body = JSON.dump({ "model" => "default", "input" => array })
    
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

#test = [[44,43,44],[90,83,82],"N","N","N"]