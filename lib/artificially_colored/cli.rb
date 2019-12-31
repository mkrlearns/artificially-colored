class ArtificiallyColored::CLI

  def call
    main_menu
  end
  
  def main_menu
    ai_menu
  end

  def ai_menu
    puts "Enter a comma seperated list of 1-4 colors."
    puts "A five color AI generated palette will be returned."
    user_colors = gets
    clear
    puts "How many palettes would you like to generate?"
    puts "The higher the number the longer it will take,"
    puts "with ten being the highest you can return."
    puts "Any duplicates generated will be removed from results."
    user_num = gets.strip.to_i
    user_num = 10 if user_num > 10
    ai_results(user_colors, user_num)
  end

  def ai_results(user_colors, user_num)
    palettes = []
    all = []
    loading = fake_loader
    user_num.times do
      clear
      puts loading + "\e[?25l"
      loading += fake_loader + fake_loader
      swatches = []
      ArtificiallyColored::AI.new.ai_connect(user_colors).each do |i|
        swatches << "#{Rainbow("▇" * 6).color(i[:hex])}"
        all << i
      end
      palettes << "#{swatches[0]} #{swatches[1]} #{swatches[2]} #{swatches[3]} #{swatches[4]}"
    end
    clear
    palettes.uniq.each { |palette| puts "#{palettes.uniq.index(palette) + 1}: #{palette}\n" }
    puts "\e[?25h"
  end

  def clear
    system "clear" or system "cls"
  end

  def fake_loader
    Rainbow("▎" * 2).color(['#AE81FF',"#66D9EF","#E69F66","#FD971F","#F92672"].sample) 
  end

end
