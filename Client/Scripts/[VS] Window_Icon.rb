#==============================================================================
# ** Window_Icon
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de ícones.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Icon < Window_Base
  
  def initialize
    # Quando a resolução é alterada, a coordenada x é
    #reajustada no adjust_windows_position da Scene_Map
    super(adjust_x, adjust_y, 286, 45)
    self.windowskin = Cache.system('Window3')
    Icon.new(self, 10, 10, Configs::ITEM_ICON, "#{Vocab.item} (#{Configs::ITEM_KEY.to_s.delete('LETTER_')})") { $windows[:equip].trigger }
    Icon.new(self, 50, 10, Configs::SKILL_ICON, "#{Vocab.skill} (#{Configs::SKILL_KEY.to_s.delete('LETTER_')})") { $windows[:skill].trigger }
    Icon.new(self, 90, 10, Configs::STATUS_ICON, "#{Vocab.status} (#{Configs::STATUS_KEY.to_s.delete('LETTER_')})") { $windows[:status].trigger }
    Icon.new(self, 130, 10, Configs::QUEST_ICON, "#{Vocab::Quests} (#{Configs::QUEST_KEY.to_s.delete('LETTER_')})") { $windows[:quest].trigger }
    Icon.new(self, 170, 10, Configs::FRIEND_ICON, "#{Vocab::Friend}s (#{Configs::FRIEND_KEY.to_s.delete('LETTER_')})") { $windows[:friend].trigger }
    Icon.new(self, 210, 10, Configs::GUILD_ICON, "#{Vocab::Guild} (#{Configs::GUILD_KEY.to_s.delete('LETTER_')})") { $windows[:guild].trigger }
    Icon.new(self, 250, 10, Configs::MENU_ICON, "#{Vocab::Menu} (#{Configs::MENU_KEY.to_s.delete('LETTER_')})") { $windows[:menu].trigger }
  end
  
  def adjust_x
    Graphics.width - 299
  end
  
  def adjust_y
    Graphics.height - 51
  end
  
end
