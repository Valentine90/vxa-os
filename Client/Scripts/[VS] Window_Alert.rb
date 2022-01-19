#==============================================================================
# ** Window_Alert
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de alerta.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Alert < Window_Base
  
  def initialize
    # Quando a resolução é alterada, a coordenada x é
    #reajustada no adjust_windows_position da Scene_Map
    super(adjust_x, 270, 290, 90)
    self.visible = false
    self.z = 106
    self.title = Vocab::Alert
    Button.new(self, 129, 59, Vocab::Ok) { hide }
  end
  
  def adjust_x
    Graphics.width / 2 - 145
  end
  
  def show(text)
    contents.clear
    word_wrap(text).each.with_index do |text, i|
      draw_text(0, line_height * i, contents_width, line_height, text, 1)
    end
    super()
  end
  
end

#==============================================================================
# ** Window_Password
#==============================================================================
class Window_Password < Window_Base
  
  def initialize
    super(adjust_x, 253, 235, 168)
    self.visible = false
    self.closable = true
    self.z = 103
    self.title = Vocab::Alert
    @delete_button = Button.new(self, 89, 136, Vocab::Delete) { delete }
    @pass_box = Text_Box.new(self, 47, 110, 140, Configs::MAX_CHARACTERS, true) { enable_delete_button }
    draw_contents
  end
  
  def adjust_x
    Graphics.width / 2 - 117
  end
  
  def show(actor_id)
    super()
    @actor_id = actor_id
    @pass_box.clear
    @pass_box.active = true
    @delete_button.enable = false
  end
  
  def draw_contents
    word_wrap(Vocab::EnterPass).each_with_index do |text, i|
      draw_text(0, line_height * i, contents_width, line_height, text, 1)
    end
  end
  
  def delete
    return unless @delete_button.enable
    $network.send_remove_actor(@actor_id, @pass_box.text)
    hide
  end
  
  def enable_delete_button
    @delete_button.enable = (@pass_box.text.strip.size >= Configs::MIN_CHARACTERS)
  end
  
end
