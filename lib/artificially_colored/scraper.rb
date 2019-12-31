class ArtificiallyColored::Scraper

  attr_accessor :hex, :rgb, :hsl, :hsv
  
  def initialize(hex=nil, rgb=nil, hsl=nil, hsv=nil)
    
  end

  def convert_color(color)
    color = color.delete!('()°%').gsub!(',', '_').gsub!(' ', '')
    
    if color.downcase.include? 'rgb'
      url = color.sub!(/rgb/i, 'rgb-color')
    elsif color.include? '#'
      url = color.sub!('#', 'hex-color-')
    elsif color.downcase.include? 'hsl'
      url = color.sub!(/hsl/i, 'hsl-color')
    elsif color.downcase.include? 'hsv'
      url = color.sub!(/hsv/i, 'hsv-color')
    elsif color.length == 3 && !color.match(/\A[a-zA-Z0-9]*\z/).nil?
      url = "hex-color-#{color}#{color}"
    elsif color.length == 6 && !color.match(/\A[a-zA-Z0-9]*\z/).nil?
      url = "hex-color-#{color}"
    else
      puts "Invalid color code, try again."
  
  doc = Nokogiri::HTML(open("https://convertingcolors.com/#{url.strip}.html"))
  
  rgb = doc.css('#copyRgbtext').text
  hex = doc.css('#copyHextext').text
  hsl = doc.css('#copyHsltext').text
  hsv = doc.css('#copyHsvtext').text
  
  return { rgb: "rgb(#{rgb})", hex: "##{hex}", hsl: "hsl(#{hsl})", hsv: "rgb(#{hsv})"}
  
  end

end
