#==============================================================================
# ** Window_Friend
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de amigos.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Friend < Window_Selectable
  
  def initialize
    super(300, 170, 215, 212)
    self.visible = false
    self.closable = true
    self.title = "#{Vocab::Friend}s"
  end
  
  def trigger
    self.visible ? hide : $network.send_open_friend_window
  end
  
  def line_height
    20
  end
  
  def make_list
    @data = $game_actors[1].friends
  end
  
  def draw_item(index)
    rect = item_rect_for_text(index)
    icon_index = index >= $game_actors[1].online_friends_size ? Configs::PLAYER_ON_ICON : Configs::PLAYER_OFF_ICON
    rect2 = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    bitmap = Cache.system('Iconset')
    contents.blt(0, rect.y, bitmap, rect2)
    rect.x += 24
    draw_text(rect, @data[index])
  end
  
  def update
    super
    remove_friend
    private_chat
  end
  
  def remove_friend
    return unless Input.trigger?(:DELETE)
    return unless index >= 0
    $windows[:choice].show(Vocab::Ask, Enums::Choice::REMOVE_FRIEND, index)
  end
  
  def private_chat
    return unless Mouse.dbl_clk?(:L)
    return unless index >= 0
    $windows[:chat].private(@data[index])
  end
  
end
