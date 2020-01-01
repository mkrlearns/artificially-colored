class ArtificiallyColored::CLI

  def call
    main_menu
  end
  
  def main_menu
    ai_menu
  end

  def ai_menu
    puts "Enter a comma seperated list of 1-4 colors."
    puts "You may use any valid hex, rgb, hsl, or hsv color code."
    puts "Example: #AE81FF,#66D9EF,#E69F66,"
    puts "A five color AI generated palette will be returned."
    user_colors = gets
    clear
    puts "The higher the number of palettes the longer it will take."
    puts "Ten is the highest number of palettes you may return."
    puts "Any duplicates generated will be removed from results."
    puts
    puts "How many palettes would you like to generate?"
    user_num = gets.strip.to_i
    user_num = 10 if user_num > 10
    ai_get_results(user_colors, user_num)
  end

  def ai_get_results(user_colors, user_num)
    palettes = []
    all = []
    loading = fake_loader
    user_num.times do
      clear
      puts loading + "\e[?25l"
      loading += fake_loader + fake_loader
      swatches = []
      gen_colors = ArtificiallyColored::AI.new.ai_connect(user_colors)
      all << gen_colors
      gen_colors.each { |i| swatches << color_bar(6, i[:hex])}
      palettes << "#{swatches[0]} #{swatches[1]} #{swatches[2]} #{swatches[3]} #{swatches[4]}"
    end
    ai_display_results(palettes, all.uniq)
  end

  def ai_display_results(palettes, all)
    clear
    palettes.uniq.each { |palette| puts "#{palettes.uniq.index(palette) + 1}: #{palette}\n" }
    puts "\e[?25h"
    puts "Select a number for color codes to that palette."
    selection = gets.strip.to_i - 1
    ai_more_info(selection, all)
  end

  def ai_more_info(selection, all)
    clear
    info = all[selection]
    info.each do |i|
      bar = color_bar(1, i[:hex])
      puts "#{bar}  #{i[:hex].ljust(8)} #{bar}  #{i[:rgb].ljust(18)} #{bar}  #{i[:hsl].ljust(20)} #{bar}  #{i[:hsv]}"
    end
  end

  def clear
    system "clear" or system "cls"
  end

  def fake_loader
    Rainbow("▎" * 2).color(['#AE81FF',"#66D9EF","#E69F66","#FD971F","#F92672"].sample) 
  end

  def color_bar(width, color)
    Rainbow("▇" * width).color(color)
  end
end
