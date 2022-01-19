#==============================================================================
# ** Window_Amount
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de quantidade.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Amount < Window_Base
  
  def initialize
    super(400, 230, 150, 80)
    self.visible = false
    self.closable = true
    self.title = Vocab::Amount
    @amount_box = Number_Box.new(self, 10, 20, 130, 5) { enable_ok_button }
    @ok_button = Button.new(self, 60, 50, Vocab::Ok) { ok }
  end
  
  def show(type, item = nil, index = 0)
    @type = type
    @item = item
    if index == 0 && item_number_one?
      @amount_box.value = 1
      ok
      return
    end
    super()
    @index = index
    @amount_box.clear
    @amount_box.active = true
    @ok_button.enable = false
  end
  
  def item_number_one?
    return ($game_trade.my_item_number(@item) == 1) if @type == Enums::Amount::REMOVE_TRADE_ITEM
    return ($game_bank.item_number(@item) == 1) if @type == Enums::Amount::WITHDRAW_ITEM
    return ($game_party.item_number(@item) == 1)
  end
  
  def ok
    case @type
    when Enums::Amount::BUY_ITEM
      buy_item
    when Enums::Amount::SELL_ITEM
      sell_item
    when Enums::Amount::DROP_ITEM
      drop_item
    when Enums::Amount::ADD_TRADE_ITEM
      add_trade_item
    when Enums::Amount::ADD_TRADE_GOLD
      add_trade_gold
    when Enums::Amount::REMOVE_TRADE_ITEM
      remove_trade_item
    when Enums::Amount::REMOVE_TRADE_GOLD
      remove_trade_gold
    when Enums::Amount::DEPOSIT_ITEM
      deposit_item
    when Enums::Amount::DEPOSIT_GOLD
      deposit_gold
    when Enums::Amount::WITHDRAW_ITEM
      withdraw_item
    when Enums::Amount::WITHDRAW_GOLD
      withdraw_gold
    end
    hide
  end
  
  def buy_item
    amount = [@amount_box.value, Configs::MAX_ITEMS - $game_party.item_number(@item)].min
    return if $game_party.full_items?(@item)
    if $game_party.gold < @item.price * amount
      $error_msg = Vocab::NotEnoughMoney
      return
    end
    $network.send_buy_item(@index, amount)
  end
  
  def sell_item
    amount = @amount_box.value
    return if $game_party.item_number(@item) < amount
    $network.send_sell_item(@item.id, $game_party.kind_item(@item), amount)
  end
  
  def drop_item
    amount = @amount_box.value
    return if $game_party.item_number(@item) < amount
    if $game_map.drops.size >= Configs::MAX_MAP_DROPS
      $error_msg = Vocab::FullDrops
      return
    elsif @item.soulbound?
      $error_msg = Vocab::SoulboundItem
      return
    end
    $network.send_add_drop(@item.id, $game_party.kind_item(@item), amount)
  end
  
  def add_trade_item
    amount = @amount_box.value
    return if $game_party.item_number(@item) < $game_trade.my_item_number(@item) + amount
    return if $game_trade.full_items?(@item)
    if @item.soulbound?
      $error_msg = Vocab::SoulboundItem
      return
    end
    $network.send_trade_item(@item.id, $game_party.kind_item(@item), amount)
  end
  
  def add_trade_gold
    amount = @amount_box.value
    return if $game_party.gold < $game_trade.my_gold + amount
    $network.send_trade_gold(amount)
  end
  
  def remove_trade_item
    amount = @amount_box.value
    return if $game_trade.my_item_number(@item) < amount
    return if $game_party.full_items?(@item)
    $network.send_trade_item(@item.id, $game_party.kind_item(@item), -amount)
  end
  
  def remove_trade_gold
    amount = @amount_box.value
    return if $game_trade.my_gold < amount
    $network.send_trade_gold(-amount)
  end
  
  def deposit_item
    amount = [@amount_box.value, Configs::MAX_ITEMS - $game_bank.item_number(@item)].min
    return if $game_party.item_number(@item) < amount
    return if $game_bank.full_items?(@item)
    if @item.soulbound?
      $error_msg = Vocab::SoulboundItem
      return
    end
    $network.send_bank_item(@item.id, $game_party.kind_item(@item), amount)
  end
  
  def deposit_gold
    amount = @amount_box.value
    return if $game_party.gold < amount
    $network.send_bank_gold(amount)
  end
  
  def withdraw_item
    amount = [@amount_box.value, Configs::MAX_ITEMS - $game_party.item_number(@item)].min
    return if $game_bank.item_number(@item) < amount
    return if $game_party.full_items?(@item)
    $network.send_bank_item(@item.id, $game_party.kind_item(@item), -amount)
  end
  
  def withdraw_gold
    amount = @amount_box.value
    return if $game_bank.gold < amount
    $network.send_bank_gold(-amount)
  end
  
  def enable_ok_button
    @ok_button.enable = (@amount_box.value != 0)
  end
  
  def update
    super
    ok if Input.trigger?(:C) && @amount_box.value != 0
  end
  
end
