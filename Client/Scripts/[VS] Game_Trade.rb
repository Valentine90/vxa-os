#==============================================================================
# ** Game_Trade
#------------------------------------------------------------------------------
#  Esta classe lida com a troca.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Game_Trade
  
  attr_reader   :his_gold, :my_gold
  
  def initialize
    @his_items = {}
    @his_weapons = {}
    @his_armors = {}
    @my_items = {}
    @my_weapons = {}
    @my_armors = {}
    @his_gold = 0
    @my_gold = 0
  end
  
  def open
    $windows[:his_trade].show
    $windows[:my_trade].show
    $windows[:trade].show
    $windows[:equip].show
  end
  
  def close
    $windows[:his_trade].hide
    $windows[:my_trade].hide
    $windows[:trade].hide
    $windows[:equip].hide
    $windows[:amount].hide
    @his_items.clear
    @his_weapons.clear
    @his_armors.clear
    @my_items.clear
    @my_weapons.clear
    @my_armors.clear
    @his_gold = 0
    @my_gold = 0
  end
  
  def his_items
    @his_items.keys.sort.collect { |id| $data_items[id] }
  end
  
  def his_weapons
    @his_weapons.keys.sort.collect { |id| $data_weapons[id] }
  end

  def his_armors
    @his_armors.keys.sort.collect { |id| $data_armors[id] }
  end
  
  def my_items
    @my_items.keys.sort.collect { |id| $data_items[id] }
  end

  def my_weapons
    @my_weapons.keys.sort.collect { |id| $data_weapons[id] }
  end

  def my_armors
    @my_armors.keys.sort.collect { |id| $data_armors[id] }
  end
  
  def all_his_items
    his_items + his_weapons + his_armors
  end
  
  def all_my_items
    my_items + my_weapons + my_armors
  end
  
  def his_item_container(item_class)
    return @his_items if item_class == RPG::Item
    return @his_weapons if item_class == RPG::Weapon
    return @his_armors if item_class == RPG::Armor
    return nil
  end
  
  def my_item_container(item_class)
    return @my_items if item_class == RPG::Item
    return @my_weapons if item_class == RPG::Weapon
    return @my_armors if item_class == RPG::Armor
    return nil
  end
  
  def his_item_number(item)
    container = his_item_container(item.class)
    container ? container[item.id] || 0 : 0
  end
  
  def my_item_number(item)
    container = my_item_container(item.class)
    container ? container[item.id] || 0 : 0
  end
  
  def has_my_item?(item)
    my_item_number(item) > 0
  end
  
  def full_items?(item)
    size = @my_items.size + @my_weapons.size + @my_armors.size
    if size == Configs::MAX_TRADE_ITEMS && !has_my_item?(item)
      $error_msg = Vocab::FullTrade
      return true
    end
    return false
  end
  
  def gain_his_item(item, amount)
    container = his_item_container(item.class)
    return unless container
    last_number = his_item_number(item)
    new_number = last_number + amount
    container[item.id] = [[new_number, 0].max, $game_party.max_item_number(item)].min
    container.delete(item.id) if container[item.id] == 0
  end
  
  def gain_my_item(item, amount)
    container = my_item_container(item.class)
    return unless container
    last_number = my_item_number(item)
    new_number = last_number + amount
    container[item.id] = [[new_number, 0].max, $game_party.max_item_number(item)].min
    container.delete(item.id) if container[item.id] == 0
  end
  
  def gain_his_gold(amount)
    @his_gold = [[@his_gold + amount, 0].max, $game_party.max_gold].min
  end
  
  def gain_my_gold(amount)
    @my_gold = [[@my_gold + amount, 0].max, $game_party.max_gold].min
  end
  
end
