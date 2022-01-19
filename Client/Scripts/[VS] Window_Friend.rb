#==============================================================================
# ** Window_Friend
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de amigos.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Friend < Window_Selectable2
  
  def initialize
    super(300, 170, 'FriendWindow', 'WindowCursor1')
    self.visible = false
    self.closable = true
    @scroll_bar = Scroll_Bar.new(self, Configs::MAX_FRIENDS, line_height)#, false)
    @name_box = Text_Box.new(self, 36, 22, 100, Configs::MAX_CHARACTERS) { find_friend }
    create_contents2(0, 0, contents_width, 20)
  end
  
  def trigger
    self.visible ? hide : $network.send_open_friend_window
  end
  
  def line_height
    20
  end
  
  def contents_y
    Configs::TITLE_BAR_HEIGHT + 24
  end
  
  def contents_height
    @data.size * line_height
  end
  
  def refresh
    make_list
    create_contents
    draw_all_items
    @scroll_bar.refresh
    contents2.clear
    contents2.draw_text(0, 0, contents_width, 18, "#{$game_actors[1].friends.size}/#{Configs::MAX_FRIENDS}", 2)
  end
  
  def make_list
    @data = @name_box.text.empty? ? $game_actors[1].friends : list_friends_found
  end
  
  def list_friends_found
    $game_actors[1].friends.select { |name| name =~ /#{@name_box.text}/i }
  end
  
  def find_friend
    refresh
    self.oy = 0
  end
  
  def draw_item(index)
    rect = item_rect_for_text(index)
    icon_index = $game_actors[1].friends[0, $game_actors[1].online_friends_size].include?(@data[index]) ? Configs::PLAYER_ON_ICON : Configs::PLAYER_OFF_ICON
    rect2 = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    bitmap = Cache.system('Iconset')
    contents.blt(0, rect.y - 2, bitmap, rect2)
    rect.x += 26
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
