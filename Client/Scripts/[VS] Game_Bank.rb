#==============================================================================
# ** Game_Bank
#------------------------------------------------------------------------------
#  Esta classe lida com o banco.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Game_Bank
  
  attr_reader   :gold
  
  def initialize
    @items = {}
    @weapons = {}
    @armors = {}
    @gold = 0
  end
  
  def open
    $windows[:bank].show
    $windows[:equip].show
  end
  
  def close
    $windows[:bank].hide
    $windows[:equip].hide
    $windows[:amount].hide
    @items.clear
    @weapons.clear
    @armors.clear
    @gold = 0
  end
  
  def items
    @items.keys.sort.collect { |id| $data_items[id] }
  end
  
  def weapons
    @weapons.keys.sort.collect { |id| $data_weapons[id] }
  end
  
  def armors
    @armors.keys.sort.collect { |id| $data_armors[id] }
  end
  
  def item_container(item_class)
    return @items if item_class == RPG::Item
    return @weapons if item_class == RPG::Weapon
    return @armors if item_class == RPG::Armor
    return nil
  end
  
  def item_number(item)
    container = item_container(item.class)
    container ? container[item.id] || 0 : 0
  end
  
  def has_item?(item)
    item_number(item) > 0
  end
  
  def full_items?(item)
    if item_container(item.class).size == Configs::MAX_BANK_ITEMS && !has_item?(item)
      $error_msg = Vocab::FullBank
      return true
    end
    return false
  end
  
  def gain_item(item, amount)
    container = item_container(item.class)
    return unless container
    last_number = item_number(item)
    new_number = last_number + amount
    container[item.id] = [[new_number, 0].max, $game_party.max_item_number(item)].min
    container.delete(item.id) if container[item.id] == 0
  end
  
  def gain_gold(amount)
    @gold = [[@gold + amount, 0].max, $game_party.max_gold].min
  end
  
end
