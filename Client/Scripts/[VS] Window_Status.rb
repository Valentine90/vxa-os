#==============================================================================
# ** Window_Status
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de informações do
# jogador, como parâmetros, classe e pontos.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Status < Window_Base
  
  def initialize
    super(20, 160, 202, 235)
    self.visible = false
    self.closable = true
    self.title = Vocab.status
    @param_buttons = []
    8.times do |param_id|
      @param_buttons << Image_Button.new(self, 162, 22 * param_id + 33, 'Plus') {$network.send_add_param(param_id) }
    end
  end
  
  def refresh
    contents.clear
    change_color(system_color)
    draw_text(0, 0, 60, line_height, Vocab::Class)
    draw_text(0, 22, 30, line_height, "#{Vocab::hp_a}:")
    draw_text(0, 43, 30, line_height, "#{Vocab::mp_a}:")
    (2...8).each do |param_id|
      # Largura suficiente para os termos não abreviados
      draw_text(0, 22 * param_id + 20, 100, line_height, "#{Vocab::param(param_id)}:")
    end
    draw_text(0, 196, 60, line_height, Vocab::Points)
    change_color(normal_color)
    draw_text(75, 0, 150, line_height, $game_actors[1].class.name)
    draw_text(75, 22, 70, line_height, "#{$game_actors[1].hp}/#{$game_actors[1].mhp}")
    draw_text(75, 43, 70, line_height, "#{$game_actors[1].mp}/#{$game_actors[1].mmp}")
    (2...8).each do |param_id|
      draw_text(75, 22 * param_id + 20, 40, line_height, $game_actors[1].param(param_id))
    end
    draw_text(75, 196, 40, line_height, $game_actors[1].points > 0 ? $game_actors[1].points : 0)
    @param_buttons.each { |button| button.enable = $game_actors[1].points > 0 }
  end
  
end
