class ArtificiallyColored::Scraper
  attr_reader :rgb, :hex, :hsl, :hsv
  
  def initialize(user_color)
    color = user_color.dup
    color = color.delete!('()°%').gsub!(',', '_').gsub!(' ', '') if color.include? ','
    
    if color.downcase.include? 'rgb'
      url = color.sub!(/rgb/i, 'rgb-color-')
    elsif color.include? '#'
      url = !color.match(/\A#?(?:[A-F0-9]{3}){1,2}\z/i).nil? && color.sub!('#', 'hex-color-')
    elsif color.downcase.include? 'hsl'
      url = color.sub!(/hsl/i, 'hsl-color-')
    elsif color.downcase.include? 'hsv'
      url = color.sub!(/hsv/i, 'hsv-color-')
    elsif !color.match(/\A[a-zA-Z0-9]*\z/).nil? && (color.length == 6 || color.length == 3)
      url = "hex-color-#{color}"
    else
      return
    end

    begin
      return if !url
      file = open("https://convertingcolors.com/#{url.strip}.html")
      doc = Nokogiri::HTML(file)
      @rgb = "rgb(#{doc.css('#copyRgbtext').text})"
      @hex = "##{doc.css('#copyHextext').text})"
      @hsl = "hsl(#{doc.css('#copyHSLtext').text})"
      @hsv = "hsv(#{doc.css('#copyHSVtext').text})"
    rescue OpenURI::HTTPError => e
      if e.message == '404 Not Found'
        return
      else
        raise e
      end
    end
  end

end
