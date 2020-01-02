class ArtificiallyColored::CLI

  def initialize
    @selections = ""
    @user_inputs = []
    @rgb_selections = []
  end

  def call
    main_menu
  end
  
  def main_menu
    ai_menu
  end

  def ai_menu
    i = 0
    4.times do
      clear
      if i == 0
        puts "Enter the first color or enter \"done\" to generate random palettes:"
      else
        puts "Current Selections:"
        puts @selections
        puts
        puts "Enter the next color or enter \"done\" to generate palettes:"
      end
      user_input = gets.strip
      if user_input.downcase == "done"
        user_num = 498.498
        while !(user_num > 0 && user_num <= 10)
          clear
          puts "Invalid selection." if user_num != 498.498
          puts "How many palettes would you like to generate (1-10)?"
          user_num = gets.strip.to_i
        end
        @rgb_selections.map! { |color|color.delete('rgb()').split(',').map(&:to_i) }
        @rgb_selections << "N" while @rgb_selections.length < 5
        ai_get_results(@rgb_selections, user_num)
        break
      else
        color = ArtificiallyColored::Scraper.new(user_input)
        while !color.rgb
          puts "Invalid color, please try again."
          user_input = gets.strip
          color = ArtificiallyColored::Scraper.new(user_input)
        end
        @selections += "#{color_bar(1, color.hex)}  #{user_input} "
        @user_inputs << user_input
        @rgb_selections << color.rgb
        i += 1
      end
    end
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
      gen_colors.each { |i| swatches << color_bar(6, i.hex)}
      palettes << "#{swatches[0]} #{swatches[1]} #{swatches[2]} #{swatches[3]} #{swatches[4]}"
    end
    ai_display_results(palettes, all.uniq)
  end

  def ai_display_results(palettes, all)
    clear
    palettes.uniq.each { |palette| puts "#{palettes.uniq.index(palette) + 1}: #{palette}\n" }
    puts "\e[?25h"
    puts "Select a number for the color codes to that number's palette."
    selection = gets.strip.to_i - 1
    ai_more_info(selection, palettes, all)
  end

  def ai_more_info(selection, palettes, all)
    clear
    info = all[selection]
    info.each do |i|
      bar = color_bar(1, i.hex)
      puts "#{bar}  #{i.hex.ljust(8)} #{bar}  #{i.rgb.ljust(18)} #{bar}  #{i.hsl.ljust(20)} #{bar}  #{i.hsv}"
    end
    puts "Enter \"back\" to go back, \"new\" to start fresh, or \"exit\" to quit."
    gets
    ai_display_results(palettes, all)
  end

  def clear
    system "clear" or system "cls"
  end

  def fake_loader
    Rainbow("▎" * 2).color(['#AE81FF',"#66D9EF","#E69F66","#FD971F","#F92672"].sample) 
  end

  def color_bar(width, color)
    Rainbow("▉" * width).color(color)
  end

end
