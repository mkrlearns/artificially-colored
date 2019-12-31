class ArtificiallyColored::AI

  attr_accessor :ai_connect
  
  def ai_connect(array)
    if array.include?(',') then array = array.split(',')
    else array = [array.strip] end
    
    array.map! do |color|
      ArtificiallyColored::Scraper.new.convert_color(color)[:rgb].delete('rgb()').split(',').map(&:to_i)
    end
    array << "N" while array.length < 5

    uri = URI.parse("http://colormind.io/api/")
    request = Net::HTTP::Post.new(uri)
    request.body = JSON.dump({ "model" => "default", "input" => array })
    req_options = { use_ssl: uri.scheme == "https" }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    
    if response.code == '200'
      palette = []
      json = JSON.parse(response.body)
      json['result'].each do |color|
        palette << ArtificiallyColored::Scraper.new.convert_color("rgb(#{color.to_s.delete('[]')})")
      end
      puts palette
    else
      puts 'Unable to connect to API.'
    end
  end

end
