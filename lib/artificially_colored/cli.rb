class ArtificiallyColored::CLI

  def initialize
    @palettes = []
    @all_colors = []
    @get_colors = ArtificiallyColored::Scraper
    @cycle_colors = ['#AE81FF',"#66D9EF","#E69F66","#FD971F","#F92672"]
  end

  def call
    main_menu
  end
  
  def main_menu
    clear
    intro
    puts
    puts clr_str("Press \"Enter\" to continue", "#A6E22E")
    gets
    clear
    selection_menu
    ai_menu
  end

  def intro
    puts type_on("Welcome to Artificially Colored!", "#A6E22E")
    clear
    puts clr_str("Welcome to Artificially Colored!", "#A6E22E")
    puts
    puts "This tool will generate color palettes aided by AI "
    puts "and convert CSS color codes to and from hex, rgb, hsl, and hsv."
  end

  def selection_menu
    puts clr_str("1. ", "#A6E22E") + "Create an AI generated color palette."
    puts clr_str("2. ", "#A6E22E") + "Convert CSS color codes."
    puts
    puts clr_str("Enter selection 1 or 2", "#A6E22E")
    selection = gets.strip
    if selection == "1"
      clear
      ai_menu
    elsif selection == "2"
      clear
      convert_menu
    else
      clear
      puts "Invalid selection, please try again."
      selection_menu
    end
  end

  def convert_menu
    puts "This tool will convert a hex, rgb, hsl, or hsv CSS color to "
    puts "all of the previously mentioned codes."
    puts "Examples of valid colors: #E69F66, rgb(230, 159, 102), hsl(27°, 72%, 65%), hsv(27°, 56%, 90%)"
    puts "Enter a color code to convert:"
    converted = @get_colors.new(gets.strip)
    display_converted(converted)
  end

  def display_converted(converted)
    clear
    puts color_bar(18, converted.hex)
    puts converted.hex
    puts converted.rgb
    puts converted.hsl
    puts converted.hsv
    puts
    puts "Press \"Enter\" to go back to menu."
    gets
    clear
    selection_menu
  end

  def ai_menu
    i = 0
    selections = ""
    user_inputs = []
    rgb_selections = []
    4.times do
      clear
      if i == 0
        puts "Examples of valid colors: #E69F66, rgb(230, 159, 102), hsl(27°, 72%, 65%), hsv(27°, 56%, 90%)"
        puts
        puts "Enter the first color or enter \"done\" to generate random palettes:"
      else
        puts "Current Selections:"
        puts selections
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
        rgb_selections.map! { |color|color.delete('rgb()').split(',').map(&:to_i) }
        rgb_selections << "N" while rgb_selections.length < 5
        ai_get_results(rgb_selections, user_num)
        break
      else
        color = @get_colors.new(user_input)
        while !color.rgb
          puts "Invalid color, please try again."
          user_input = gets.strip
          color = @get_colors.new(user_input)
        end
        selections += "#{color_bar(1, color.hex)}  #{user_input} "
        user_inputs << user_input
        rgb_selections << color.rgb
        i += 1
      end
    end
  end

  def ai_get_results(user_colors, user_num)
    loading = ""
    user_num.times do
      clear
      swatches = []
      puts Rainbow("Depending on the amount of palettes, this may take some time.").color(@cycle_colors.sample) 
      puts loading + "\e[?25l"
      loading += fake_loader + fake_loader
      gen_colors = ArtificiallyColored::AI.new.connect(user_colors)
      if !gen_colors
        puts "Unable to connect to AI API, press \"Enter\" to try again."
        ai_get_results(user_colors, user_num)
      end
      @all_colors << gen_colors
      gen_colors.each { |i| swatches << color_bar(6, i.hex)}
      @palettes << "#{swatches[0]} #{swatches[1]} #{swatches[2]} #{swatches[3]} #{swatches[4]}"
    end
    ai_display_results
  end

  def ai_display_results
    clear
    @palettes.uniq.each { |palette| puts "#{@palettes.uniq.index(palette) + 1}: #{palette}\n" }
    puts "\e[?25h"
    puts "Select a number for the color codes to that number's palette."
    selection = gets.strip.to_i - 1
    ai_more_info(selection)
  end

  def ai_more_info(selection)
    clear
    info = @all_colors.uniq[selection]
    info.each do |i|
      bar = color_bar(1, i.hex)
      puts "#{bar}  #{i.hex.ljust(8)} #{bar}  #{i.rgb.ljust(18)} #{bar}  #{i.hsl.ljust(20)} #{bar}  #{i.hsv}"
    end
    puts "Enter \"back\" to go back, \"new\" to start fresh, or \"exit\" to quit."
    gets
    ai_display_results
  end

  def clear
    system "clear" or system "cls"
  end

  def fake_loader
    Rainbow("▎" * 2).color(@cycle_colors.sample) 
  end

  def color_bar(width, color)
    Rainbow("▉" * width).color(color)
  end

  def clr_str(string, color)
    Rainbow(string).color(color)
  end

  def type_on(string, color)
    i = string.length
    while i > 0 do
      clear
      print Rainbow(string[0...-i]).color(color) + "\e"
      i -= 1
      sleep(0.04)
    end
    puts "\e[?25l"
    15.times do
      clear
      print Rainbow(string).color(@cycle_colors.sample)
      sleep(0.1)
    end
    puts "\e[?25h"
  end

end
