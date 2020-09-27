#==============================================================================
# ** Window_Menu
#------------------------------------------------------------------------------
#  Esta classe lida com a janela do menu.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Menu < Window_Base
  
  def initialize
    # Quando a resolução é alterada, a coordenada x é
    #reajustada no adjust_windows_position da Scene_Map
    super(adjust_x, 232, 183, 125)
    self.visible = false
    self.closable = true
    self.title = Vocab::Menu
    Button.new(self, 17, 16, Vocab::Configs, 148) { configs }
    Button.new(self, 17, 40, Vocab::BackSelection, 148) { $network.send_logout }
    Button.new(self, 17, 64, Vocab::BackLogin, 148) { DataManager.back_login }
    # Fecha imediatamente em vez de chamar o exit e/ou
    #fadeout_all da SceneManager, que possibilitaria
    #a execução da SceneManager no Handle_Data, mesmo
    #sem nenhuma cena
    Button.new(self, 17, 88, Vocab::Quit, 148) { exit }
  end
  
  def adjust_x
    Graphics.width / 2 - 91
  end
  
  def configs
    $windows[:config].show
    hide
  end
  
end
