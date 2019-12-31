class ArtificiallyColored::CLI

  def call
    main_menu
  end
  
  def main_menu
    ArtificiallyColored::AI.new.ai_connect
  end

end
