#==============================================================================
# ** Window_Teleport
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de teletransporte.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Teleport < Window_Selectable
  
  def initialize
    super(292, 170, 225, 212)
    self.visible = false
    self.closable = true
    self.title = Vocab::Teleport
  end
  
  def show(teleport_id)
    @teleport_id = teleport_id
    super()
  end
  
  def hide_window
    $network.send_close_window
  end
  
  def line_height
    20
  end
  
  def make_list
    @data = Configs::TELEPORTS[@teleport_id]
  end
  
  def teleport_name(index)
    $data_mapinfos[@data[index][:map_id]].name
  end
  
  def draw_item(index)
    n = @data[index][:gold] > $game_party.gold ? 10 : 0
    change_color(text_color(n))
    draw_text(item_rect_for_text(index), teleport_name(index), 1)
  end
  
  def update
    super
    if Mouse.click?(:L) && index >= 0
      $windows[:teleportinfo].show(index, @teleport_id, teleport_name(index))
      Sound.play_ok
    end
  end
  
end

#==============================================================================
# ** Window_TeleportInfo
#==============================================================================
class Window_TeleportInfo < Window_Base
  
  def initialize
    super(532, 170, 215, 212)
    self.visible = false
    self.closable = true
    self.title = Vocab::Information
    Button.new(self, 92, 175, Vocab::Go) { go }
  end
  
  def show(index, teleport_id, map_name)
    @teleport = Configs::TELEPORTS[teleport_id][index]
    @index = index
    @map_name = map_name
    @map_id = @teleport[:map_id]
    @gold = @teleport[:gold]
    super()
  end
  
  def refresh
    draw_map_name
    draw_map
    draw_gold
  end
  
  def draw_map_name
    contents.clear
    change_color(system_color)
    draw_text(0, -2, contents_width, line_height, @map_name, 1)
  end
  
  def draw_map
    return unless FileTest.exist?("Graphics/Minimaps/#{@map_id}.png")
    bitmap = Cache.minimap(@map_id.to_s)
    contents.blt(27, 22, bitmap, bitmap.rect)
  end
  
  def draw_gold
    rect = Rect.new(Configs::GOLD_ICON % 16 * 24, Configs::GOLD_ICON / 16 * 24, 24, 24)
    bitmap = Cache.system('Iconset')
    contents.blt(0, 137, bitmap, rect)
    change_color(normal_color)
    draw_text(30, 141, contents_width, line_height, format_number(@gold))
  end
  
  def go
    if @gold > $game_party.gold
      $error_msg = Vocab::NotEnoughMoney
      Sound.play_buzzer
      return
    end
    $network.send_choice_telepot(@index)
  end
  
end
