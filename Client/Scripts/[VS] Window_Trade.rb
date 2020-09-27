#==============================================================================
# ** Window_Trade
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de troca.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_HisTrade < Window_ItemSelectable
  
  def initialize
    super(90, 140, 212, 122)
    self.visible = false
    self.closable = true
    self.title = Vocab::Trade
    create_gold_bar
  end
  
  def gold
    $game_trade.his_gold
  end
  
  def x=(x)
    super
    $windows[:my_trade].x = x
    $windows[:trade].x = x
  end
  
  def y=(y)
    super
    $windows[:my_trade].y = y + height - 1
    $windows[:trade].y = $windows[:my_trade].y + $windows[:my_trade].height - 2
  end
  
  def hide_window
    $network.send_close_window
  end
  
  def make_item_list
    @data = $game_trade.all_his_items
  end
  
  def draw_item_number(rect, item)
    rect.y += 7
    draw_text(rect, $game_trade.his_item_number(item), 2)
  end
  
end

#==============================================================================
# ** Window_MyTrade
#==============================================================================
class Window_MyTrade < Window_ItemSelectable
  
  def initialize
    super(adjust_x, adjust_y, 212, 122)
    self.visible = false
    Icon.new(self, 19, 80, Configs::ADD_GOLD_ICON) { $windows[:amount].show(Enums::Amount::ADD_TRADE_GOLD) }
    Icon.new(self, 49, 80, Configs::REMOVE_GOLD_ICON) { $windows[:amount].show(Enums::Amount::REMOVE_TRADE_GOLD) }
    @dragable = false
    create_gold_bar
  end
  
  def adjust_x
    $windows[:his_trade].x
  end
  
  def adjust_y
    $windows[:his_trade].y + $windows[:his_trade].height - 1
  end
  
  def gold
    $game_trade.my_gold
  end
  
  def make_item_list
    @data = $game_trade.all_my_items
  end
  
  def draw_item_number(rect, item)
    rect.y += 7
    draw_text(rect, $game_trade.my_item_number(item), 2)
  end
  
  def update
    super
    $windows[:amount].show(Enums::Amount::REMOVE_TRADE_ITEM, item) if Mouse.dbl_clk?(:L) && index >= 0
  end
  
  def update_drag
    return unless Mouse.press?(:L)
    return if $cursor.object
    return if $dragging_window
    return unless index >= 0
    $cursor.change_item(item, Enums::Mouse::TRADE)
  end
  
  def update_drop
    return if Mouse.press?(:L)
    return unless $cursor.object
    return unless $cursor.type == Enums::Mouse::ITEM
    return unless in_area?
    $windows[:amount].show(Enums::Amount::ADD_TRADE_ITEM, $cursor.object)
  end
  
end

#==============================================================================
# ** Window_Trade
#==============================================================================
class Window_Trade < Window_Base
  
  def initialize
    super(adjust_x, adjust_y, 212, 44)
    self.visible = false
    self.windowskin = Cache.system('Window3')
    Button.new(self, 74, 11, Vocab::Accept) { $network.send_request(Enums::Request::FINISH_TRADE) }
    @dragable = false
  end
  
  def adjust_x
    $windows[:my_trade].x
  end
  
  def adjust_y
    $windows[:my_trade].y + $windows[:my_trade].height - 2
  end
  
end
