#==============================================================================
# ** Window_Icon
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de ícones.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Icon < Window_Base2
  
  def initialize
    # Quando a resolução é alterada, a coordenada x é
    #reajustada no adjust_windows_position da Scene_Map
    super(adjust_x, adjust_y, 284, 45)
    # O sub, em vez de delete, evita que os caracteres
    #L, E, T e R sejam removidos do restante do texto
    Icon.new(self, 10, 10, Configs::ITEM_ICON, "#{Vocab.item} (#{Configs::ITEM_KEY.to_s.sub('LETTER_', '')})") { $windows[:equip].trigger }
    Icon.new(self, 50, 10, Configs::SKILL_ICON, "#{Vocab.skill} (#{Configs::SKILL_KEY.to_s.sub('LETTER_', '')})") { $windows[:skill].trigger }
    Icon.new(self, 90, 10, Configs::STATUS_ICON, "#{Vocab.status} (#{Configs::STATUS_KEY.to_s.sub('LETTER_', '')})") { $windows[:status].trigger }
    Icon.new(self, 130, 10, Configs::QUEST_ICON, "#{Vocab::Quests} (#{Configs::QUEST_KEY.to_s.sub('LETTER_', '')})") { $windows[:quest].trigger }
    Icon.new(self, 170, 10, Configs::FRIEND_ICON, "#{Vocab::Friend}s (#{Configs::FRIEND_KEY.to_s.sub('LETTER_', '')})") { $windows[:friend].trigger }
    Icon.new(self, 210, 10, Configs::GUILD_ICON, "#{Vocab::Guild} (#{Configs::GUILD_KEY.to_s.sub('LETTER_', '')})") { $windows[:guild].trigger }
    Icon.new(self, 250, 10, Configs::MENU_ICON, "#{Vocab::Menu} (#{Configs::MENU_KEY.to_s.sub('LETTER_', '')})") { $windows[:menu].trigger }
    @dragable = false
    change_opacity
  end
  
  def adjust_x
    Graphics.width - 297
  end
  
  def adjust_y
    Graphics.height - 40
  end
  
  def in_player_area?
    x = self.x / 32 + $game_map.display_x
    y = self.y / 32 + $game_map.display_y
    $game_player.x >= x && $game_player.x <= x + width / 32 && $game_player.y >= y && $game_player.y <= y + height / 32
  end
  
  def change_opacity
    self.opacity = in_player_area? ? 50 : 255
  end
  
  def update
    super
    change_opacity
  end
  
end
