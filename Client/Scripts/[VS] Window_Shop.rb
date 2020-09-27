#==============================================================================
# ** Window_Shop
#------------------------------------------------------------------------------
#  Esta classe lida com a janela da loja.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Shop < Window_ItemSelectable
  
  def initialize
    super(280, 165, 212, 212)
    self.visible = false
    self.closable = true
    self.title = Vocab::Shop
  end
  
  def show(shop_goods, purchase_only)
    @shop_goods = shop_goods
    @purchase_only = purchase_only
    super()
  end
  
  def hide_window
    $network.send_close_window
  end
  
  def enable?(item)
    item && @price[item] <= $game_party.gold && !$game_party.item_max?(item)
  end
  
  def make_item_list
    @data = []
    @price = {}
    @shop_goods.each do |goods|
      item = $game_party.item_object(goods[0] + 1, goods[1])
      if item
        @data << item
        @price[item] = goods[2] == 0 ? item.price : goods[3]
      end
    end
  end
  
  def update
    super
    $windows[:amount].show(Enums::Amount::BUY_ITEM, item, index) if Mouse.dbl_clk?(:L) && index >= 0
  end
  
  def update_drag
    return unless Mouse.press?(:L)
    return if $cursor.object
    return if $dragging_window
    return unless index >= 0
    $cursor.change_item(item, Enums::Mouse::SHOP)
  end
  
  def update_drop
    return if Mouse.press?(:L)
    return unless $cursor.object
    return unless $cursor.type == Enums::Mouse::ITEM
    return unless in_area?
    sell_item
  end
  
  def sell_item
    if @purchase_only
      $error_msg = Vocab::NotSellItem
      Sound.play_buzzer
      return
    end
    $windows[:amount].show(Enums::Amount::SELL_ITEM, $windows[:item].item)
  end
  
end
