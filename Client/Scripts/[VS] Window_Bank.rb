#==============================================================================
# ** Window_Bank
#------------------------------------------------------------------------------
#  Esta classe lida com a janela do banco.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Bank < Window_ItemSelectable
  
  attr_reader   :tab_page
  
  def initialize
    super(230, 155, 242, 242)
    self.visible = false
    self.closable = true
    self.title = Vocab::Bank
    @tab_page = Tab_Control.new(self, [Vocab::Items, Vocab::Weapons, Vocab::Armors], true) { refresh }
    Icon.new(self, 19, 200, Configs::ADD_GOLD_ICON) { $windows[:amount].show(Enums::Amount::DEPOSIT_GOLD) }
    Icon.new(self, 49, 200, Configs::REMOVE_GOLD_ICON) { $windows[:amount].show(Enums::Amount::WITHDRAW_GOLD) }
    create_gold_bar
  end
  
  def col_max
    7
  end
  
  def gold
    $game_bank.gold
  end
  
  def hide_window
    return unless visible
    $network.send_close_window
  end
  
  def make_item_list
    if @tab_page.index == 0
      @data = $game_bank.items
    elsif @tab_page.index == 1
      @data = $game_bank.weapons
    else
      @data = $game_bank.armors
    end
  end
  
  def draw_item_number(rect, item)
    rect.y += 7
    draw_text(rect, $game_bank.item_number(item), 2)
  end
  
  def refresh
    super
    @tab_page.draw_border
  end
  
  def update
    super
    $windows[:amount].show(Enums::Amount::WITHDRAW_ITEM, item) if Mouse.dbl_clk?(:L) && index >= 0
  end
  
  def update_drag
    return unless Mouse.press?(:L)
    return if $cursor.object
    return if $dragging_window
    return unless index >= 0
    $cursor.change_item(item, Enums::Mouse::BANK)
  end
  
  def update_drop
    return if Mouse.press?(:L)
    return unless $cursor.object
    return unless $cursor.type == Enums::Mouse::ITEM
    return unless in_area?
    $windows[:amount].show(Enums::Amount::DEPOSIT_ITEM, $cursor.object)
  end
  
end
