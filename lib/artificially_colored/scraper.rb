class ArtificiallyColored::Scraper

  def convert_color(color)
    color = color.delete!('()°%').gsub!(',', '_').gsub!(' ', '') if color.include? ','
    
    if color.downcase.include? 'rgb'
      url = color.sub!(/rgb/i, 'rgb-color-')
    elsif color.include? '#'
      url = color.sub!('#', 'hex-color-')
    elsif color.downcase.include? 'hsl'
      url = color.sub!(/hsl/i, 'hsl-color-')
    elsif color.downcase.include? 'hsv'
      url = color.sub!(/hsv/i, 'hsv-color-')
    elsif !color.match(/\A[a-zA-Z0-9]*\z/).nil? && (color.length == 6 || color.length == 3)
      url = "hex-color-#{color}"
    else
      puts "Invalid color code, try again."
    end
    
    doc = Nokogiri::HTML(open("https://convertingcolors.com/#{url.strip}.html"))
    
    rgb = doc.css('#copyRgbtext').text
    hex = doc.css('#copyHextext').text
    hsl = doc.css('#copyHSLtext').text
    hsv = doc.css('#copyHSVtext').text
    
    return { rgb: "rgb(#{rgb})", hex: "##{hex}", hsl: "hsl(#{hsl})", hsv: "hsv(#{hsv})"}
  
  end

end
