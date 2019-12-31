class ArtificiallyColored::CLI

  def call
    main_menu
  end
  
  def main_menu
    colors = ['#AE81FF', "#66D9EF", "#A6E22E", "#E6DB74", "#E69F66", "#FD971F", "#F92672"]
    loading_color = Rainbow("▎").color(colors.sample)
    palettes = []
    5.times do
      clear
      puts "LOADING: #{loading_color}"
      6.times { loading_color += Rainbow("▎").color(colors.sample) }
      swatches = []
      ArtificiallyColored::AI.new.ai_connect('D27042').each do |i|
        swatches << "#{Rainbow("▇" * 6).color(i[:hex])}"
      end
      palettes << "#{swatches[0]} #{swatches[1]} #{swatches[2]} #{swatches[3]} #{swatches[4]}"
    end
    clear
    i = 0
    palettes.uniq.each do |palette|
      i += 1
      puts "#{i}: #{palette}\n"
    end
  end

  def clear
    system "clear" or system "cls"
  end

end
