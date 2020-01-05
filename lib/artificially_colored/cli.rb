class ArtificiallyColored::CLI

  def initialize
    @palettes = []
    @all_colors = []
    @get_colors = ArtificiallyColored::Scraper
    @cycle_colors = ['#AE81FF',"#66D9EF","#E69F66","#FD971F","#F92672"]
    @selections = ""
    @user_inputs = []
    @rgb_selections = []
  end

  def main_menu
    clear
    intro
    puts clr_str("\nPress \"Enter\" to continue", "#A6E22E")
    gets
    clear
    selection_menu
  end

  def intro
    puts "\e[?25l"
    puts type_on("Welcome to Artificially Colored!\n", "#A6E22E")
    puts "This tool will generates five color palettes aided by deep learning "
    puts "and converts CSS color codes to and from hex, rgb, and hsl.\e[?25h"
  end

  def selection_menu
    puts clr_str("1. ", "#A6E22E") + "Create an AI generated color palette"
    puts clr_str("2. ", "#A6E22E") + "Convert color codes"
    puts clr_str("3. ", "#A6E22E") + "Credits\n\n"
    puts clr_str("Enter a selection between 1 and 3:", "#A6E22E")
    selection = gets.strip
    clear
    ai_menu if selection == "1"
    convert_menu if selection == "2"
    credits if selection == "3"
    clear
    puts clr_str("Invalid selection, please try again.", "#F92672")
    selection_menu
  end

  def credits
    puts "\e[?25l"
    type_on("Artificially Colored was created by Ryan Meek.\nColor conversions " +
      "scraped from https://convertingcolors.com/.\nDeep learning color palettes " +
      "API from http://colormind.io/.\n\n", "#A6E22E")
    puts clr_str("Press \"Enter\" to go back to menu.", "#A6E22E")
    puts "\e[?25h"
    gets
    clear
    selection_menu
  end

  def convert_menu
    puts clr_str("Convert between hex, rgb, or hsl colors.", "#A6E22E")
    puts "Examples of valid colors:"
    puts "#E69F66, rgb(230, 159, 102), hsl(27, 72%, 65%)\n\n"
    puts clr_str("Enter a color code to convert:", "#A6E22E")
    converted = @get_colors.new(gets.strip)
    puts converted
    if !converted.rgb
      clear
      puts clr_str("Invalid color, please try again.", "#F92672")
      convert_menu
    else
      display_converted(converted)
    end
  end

  def display_converted(converted)
    clear
    puts color_bar(18, converted.hex)
    puts converted.hex
    puts converted.rgb
    puts converted.hsl
    puts clr_str("\nPress \"Enter\" to go back to menu or type \"new\" to convert another color.", "#A6E22E")
    selection = gets.strip.downcase
    clear
    convert_menu if selection == "new"
    selection_menu
  end

  def ai_menu
    while @rgb_selections.length < 4 do
      if @rgb_selections.length == 0
        puts clr_str("Provide between 0-4 colors to generate a five color palette.", "#A6E22E")
        puts "Examples of valid colors:"
        puts "#E69F66, rgb(230, 159, 102), hsl(27, 72%, 65%)\n\n"
        puts clr_str("Enter the first color or hit \"Enter\" to generate random palettes:", "#A6E22E")
      else
        puts clr_str("Type \"clear\" to clear all selections.\n", "#A6E22E")
        puts "Current Selections:"
        puts @selections
        puts clr_str("\nAdd the next color or hit \"Enter\" to generate palettes:", "#A6E22E")
      end
      user_input = gets.strip
      if user_input == "clear"
        clear
        self.class.new.ai_menu
      elsif user_input == ""
        break
      else
        color = @get_colors.new(user_input)
        if !color.rgb
          clear
          puts clr_str("Invalid color, please try again.", "#F92672")
          ai_menu
          break
        end
        if user_input.encode('UTF-8').include?("\u{00B0}")
          user_input = user_input.encode('UTF-8').delete!("\u{00B0}").encode('ASCII')
        end
        @selections += "#{color_bar(1, color.hex)}  #{user_input} "
        @user_inputs << user_input
        @rgb_selections << color.rgb
        clear
      end
    end
    clear
    ai_gen_palettes
  end

  def ai_gen_palettes
    puts clr_str("How many palettes would you like to generate (1-10)?", "#A6E22E")
    user_num = gets.strip.to_i
    while !(user_num > 0 && user_num <= 10)
      clear
      puts clr_str("Invalid selection, please try again.", "#F92672")
      ai_gen_palettes
    end
    @rgb_selections.map! { |color|color.delete('rgb()').split(',').map(&:to_i) }
    @rgb_selections << "N" while @rgb_selections.length < 5
    ai_get_results(@rgb_selections, user_num)
  end

  def ai_get_results(user_colors, user_num)
    loading = ""
    user_num.times do
      clear
      swatches = []
      puts Rainbow("Depending on the amount of palettes, " +
        "this may take some time.").color(@cycle_colors.sample)  + "\e[?25l"
      puts loading
      loading += fake_loader
      gen_colors = ArtificiallyColored::AI.new.connect(user_colors)
      if !gen_colors
        puts "Unable to connect to AI API, press \"Enter\" to try again."
        ai_get_results(user_colors, user_num)
      end
      @all_colors << gen_colors
      gen_colors.each { |i| swatches << color_bar(6, i.hex)}
      @palettes << "#{swatches[0]} #{swatches[1]} #{swatches[2]} #{swatches[3]} #{swatches[4]}"
    end
    clear
    ai_display_results
  end

  def ai_display_results
    @palettes.uniq.each { |palette| puts "#{@palettes.uniq.index(palette) + 1}: #{palette}\n" }
    puts "\e[?25h"
    puts clr_str("Select a number for the color codes to that number's palette", "#A6E22E")
    puts clr_str("or type \"new\" to start from color selection.", "#A6E22E")
    selection = gets.strip
    if selection == "new"
      clear
      self.class.new.ai_menu
    elsif is_number?(selection) and selection.to_i < 0 and selection.to_i <= palettes.uniq.length
      selection = selection.to_i - 1
      ai_more_info(selection)
    else
      clear
      puts clr_str("Invalid selection, please try again.", "#F92672")
      ai_display_results
    end
  end

  def ai_more_info(selection)
    clear
    info = @all_colors.uniq[selection]
    info.each do |i|
      bar = color_bar(1, i.hex)
      puts "#{bar}  #{i.hex.ljust(8)} #{bar}  #{i.rgb.ljust(18)} #{bar}  #{i.hsl.ljust(20)}"
    end
    puts clr_str("\nPress \"Enter\" to go back. Type \"new\" to start fresh or \"exit\" to quit.", "#A6E22E")
    selection = gets.downcase.strip
    if selection == "new"
      clear
      self.class.new.selection_menu
    elsif selection == "exit"
      exit
    else
      ai_display_results
    end
  end

  def clear
    system "clear" or system "cls"
  end

  def fake_loader
    Rainbow("▎" * [2,3,4,5].sample).color(@cycle_colors.sample) 
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
    7.times do
      clear
      print Rainbow(string).color(@cycle_colors.sample)
      sleep(0.2)
    end
    clear
    print Rainbow(string).color(color)
  end

  def is_number?(string)
    true if Float(string) rescue false
  end

end
