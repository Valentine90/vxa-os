#==============================================================================
# ** Window_Item
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de itens.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Item < Window_ItemSelectable#2
  
  def initialize
    # Quando a resolução é alterada, a coordenada x é
    #reajustada no adjust_windows_position da Scene_Map
    super(adjust_x, adjust_y, 212, 212)#'ItemWindow')
    self.visible = false
    self.windowskin = Cache.system('Window3')
    @dragable = false
    create_gold_bar
  end
  
  def adjust_x
    $windows[:equip].x
  end
  
  def adjust_y
    $windows[:equip].y + $windows[:equip].height - 1
  end
  
  def gold
    $game_party.gold - $game_trade.my_gold
  end
  
  def enable?(item)
    $game_actors[1].usable?(item) || $game_actors[1].equippable?(item)
  end
  
  def usable?
    item.is_a?(RPG::Item) && $game_player.usable?(item)
  end
  
  def make_item_list
    @data = $game_party.all_items
  end
  
  def draw_item_number(rect, item)
    rect.y += 7
    draw_text(rect, $game_party.item_number(item) - $game_trade.my_item_number(item), 2)
  end
  
  def update
    super
    double_click
    drop_item
  end
  
  def double_click
    return unless Mouse.dbl_clk?(:L)
    return unless index >= 0
    if $windows[:shop].visible
      $windows[:shop].sell_item
    elsif $windows[:my_trade].visible
      $windows[:amount].show(Enums::Amount::ADD_TRADE_ITEM, item)
    elsif $windows[:bank].visible
      $windows[:amount].show(Enums::Amount::DEPOSIT_ITEM, item)
    elsif item.is_a?(RPG::EquipItem) && $windows[:equip].sufficient_level? && !$windows[:equip].equip_vip? && !$windows[:equip].different_sex?
      $network.send_player_equip(item.id, item.etype_id)
    elsif item.is_a?(RPG::Item)
      use_item
    end
  end
  
  def use_item
    return if $game_player.item_attack_time > Time.now
    $game_player.item_attack_time = Time.now + Configs::COOLDOWN_SKILL_TIME
    $network.send_use_item(item.id) if usable?
  end
  
  def drop_item
    return unless Mouse.click?(:R)
    return unless index >= 0
    return if $windows[:my_trade].visible
    $windows[:amount].show(Enums::Amount::DROP_ITEM, item)
  end
  
  def update_drag
    return unless Mouse.press?(:L)
    return if $cursor.object
    return if $dragging_window
    return unless index >= 0
    $cursor.change_item(item, Enums::Mouse::ITEM)
  end
  
  def update_drop
    return if Mouse.press?(:L)
    return unless $cursor.object
    return unless in_area?
    case $cursor.type
    when Enums::Mouse::EQUIP
      $network.send_player_equip(0, $cursor.object.etype_id) unless $game_party.full_items?($cursor.object)
    when Enums::Mouse::SHOP
      $windows[:amount].show(Enums::Amount::BUY_ITEM, $cursor.object, $windows[:shop].index)
    when Enums::Mouse::TRADE
      $windows[:amount].show(Enums::Amount::REMOVE_TRADE_ITEM, $cursor.object)
    when Enums::Mouse::BANK
      $windows[:amount].show(Enums::Amount::WITHDRAW_ITEM, $cursor.object)
    end
  end
  
end
