class ArtificiallyColored::Scraper
  attr_reader :rgb, :hex, :hsl
  
  def initialize(user_color)
    color = user_color.dup
    color = color.strip.delete!('()%').gsub!(',', '_').gsub!(' ', '') if color.include? ','
    
    if color.downcase.include? 'rgb'
      url = color.sub!(/rgb/i, 'rgb-color-')
    elsif !color.match(/\A[a-zA-Z0-9]*\z/).nil? and (color.length == 6 or color.length == 3)
      url = "hex-color-#{color}"
    elsif !color.match(/\A#?(?:[A-F0-9]{3}){1,2}\z/i).nil? #color.include? '#' && 
      url = color.sub!('#', 'hex-color-')
    elsif color.downcase.include? 'hsl'
      url = color.encode('UTF-8').delete!("\u{00B0}").sub!(/hsl/i, 'hsl-color-')
    else
      return
    end

    begin
      return if !url
      file = open("https://convertingcolors.com/#{url.strip}.html")
      doc = Nokogiri::HTML(file)
      @rgb = "rgb(#{doc.css('#copyRgbtext').text})"
      @hex = "##{doc.css('#copyHextext').text}"
      @hsl = "hsl(#{doc.css('#copyHSLtext').text})"
    rescue OpenURI::HTTPError => e
      if e.message == '404 Not Found'
        return
      else
        puts "There was an issue connecting to the required site."
        puts "Press \"Enter\" to try again."
        gets
        return
      end
    end
  end

end
