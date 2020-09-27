#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  Apesar de ser nomeada como Game_Party, esta classe não
# lida com o grupo, sendo responsável apenas por alguns
# dados do jogador, como dinheiro e itens.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Game_Party < Game_Unit
  
  def items
    @items.keys.sort.collect { |id| $data_items[id] if item_number($data_items[id]) - $game_trade.my_item_number($data_items[id]) > 0 }.compact
  end
  
  def weapons
    @weapons.keys.sort.collect { |id| $data_weapons[id] if item_number($data_weapons[id]) - $game_trade.my_item_number($data_weapons[id]) > 0 }.compact
  end
  
  def armors
    @armors.keys.sort.collect { |id| $data_armors[id] if item_number($data_armors[id]) - $game_trade.my_item_number($data_armors[id]) > 0 }.compact
  end
  
  def item_object(kind, data_id)
    return $data_items[data_id] if kind == 1
    return $data_weapons[data_id] if kind == 2
    return $data_armors[data_id] if kind == 3
    return nil
  end
  
  def kind_item(item)
    return 1 if item.class == RPG::Item
    return 2 if item.class == RPG::Weapon
    return 3 if item.class == RPG::Armor
  end
  
  def full_items?(item)
    size = @items.size + @weapons.size + @armors.size
    if size == Configs::MAX_PLAYER_ITEMS && !has_item?(item)
      $error_msg = Vocab::FullInventory
      return true
    end
    return false
  end
  
  def max_gold
    Configs::MAX_GOLD
  end
  
  def max_item_number(item)
    Configs::MAX_ITEMS
  end
  
end
