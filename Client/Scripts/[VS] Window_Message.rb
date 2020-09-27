#==============================================================================
# ** Window_Message
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de mensagens.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Message < Window_Base
  
  def initialize
    # Quando a resolução é alterada, a coordenada x é
    #reajustada no adjust_windows_position da Scene_Map
    super(adjust_x, 0, 640, window_height)
    self.z = 200
    self.openness = 0
    create_all_windows
    create_back_bitmap
    create_back_sprite
    clear_instance_variables
    @ok_button = Button.new(self, 595, window_height - 35, Vocab::Ok) { $game_message.visible = false }
    @ok_button.visible = false
  end
  
  def adjust_x
    Graphics.width / 2 - 320
  end
  
  def window_height
    120
  end
  
  def create_back_sprite
    @back_sprite = Sprite.new
    @back_sprite.bitmap = @back_bitmap
    @back_sprite.visible = false
    @back_sprite.x = adjust_x
    @back_sprite.z = z - 1
  end
  
  def fiber_main
    $game_message.visible = true
    update_background
    update_placement
    loop do
      process_all_text if $game_message.has_text?
      @ok_button.visible = (!$game_message.choice? && !$game_message.item_choice?)
      process_input
      # Se clicou em Ok ou pressinou Esc
      unless $game_message.choice? || $game_message.item_choice?
        @ok_button.visible = false
        $network.send_next_event_command
      end
      $game_message.clear
      @gold_window.close
      # Se morreu com a janela de escolhas aberta
      @choice_window.close
      @item_window.close
      Fiber.yield
      break unless text_continue?
    end
    close_and_wait
    # Se pressionou Esc
    $game_message.visible = false
    @fiber = nil
  end
  
  def reset_font_settings
    change_color(normal_color)
    contents.font.size = 17
    contents.font.bold = false
    contents.font.italic = false
  end
  
  def update_show_fast
    @show_fast = true if Input.trigger?(Configs::ATTACK_KEY)
  end
  
  def input_pause
    self.pause = true
    wait(10)
    Fiber.yield until Input.trigger?(:B) || !$game_message.visible
    Input.update
    self.pause = false
  end
  
  def input_choice
    @choice_window.start
    Fiber.yield while @choice_window.active && $game_message.visible
  end
  
  def input_item
    @item_window.start
    Fiber.yield while @item_window.active && $game_message.visible
  end
  
end
