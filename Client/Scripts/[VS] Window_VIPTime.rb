#==============================================================================
# ** Window_VIPTime
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de tempo VIP.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_VIPTime < Window_Base
  
  def initialize
    # Quando a resolução é alterada, as coordenadas x e y
    #são reajustadas no adjust_windows_position da Scene_Map
    super(adjust_x, adjust_y, 230, 42)
    self.opacity = 0
    # Deixa a janela de tempo VIP embaixo das janelas de
    #seleção e criação de personagem
    self.z = 98
    @buy_button = Button.new(self, 140, 9, Vocab::ShopBuy) { open_url }
    @buy_button.visible = !$network.vip?
    @dragable = false
    refresh
  end
  
  def adjust_x
    Graphics.width / 2 - 115
  end
  
  def adjust_y
    Graphics.height - 32
  end
  
  def refresh
    if $network.vip?
      time_now = Time.new(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0)
      vip_days = (($network.vip_time - time_now) / 86400).to_i
      draw_text(0, 0, contents_width, line_height, sprintf(Vocab::VIP, vip_days), 1)
    else
      draw_text(20, 0, contents_width, line_height, Vocab::NotVIP)
    end
  end
  
  def open_url
    Win32API.new('Shell32.dll', 'ShellExecute', 'pppppi', 'i').call(nil, 'open', Configs::STORE_WEBSITE, nil, nil, 10)
  end
  
end
