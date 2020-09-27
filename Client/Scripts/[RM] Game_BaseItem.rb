#==============================================================================
# ** Game_BaseItem
#------------------------------------------------------------------------------
#  Esta classe gerencia habilidades, itens, armas e armadura de uma maneira
# unificada. Como pode ser incluído no armazenamento de dados, não mantém uma 
# referência ao objeto no banco de dados.
#==============================================================================

class Game_BaseItem
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #--------------------------------------------------------------------------
  def initialize
    @class = nil
    @item_id = 0
  end
  #--------------------------------------------------------------------------
  # * Definir classe
  #--------------------------------------------------------------------------
  def is_skill?;   @class == RPG::Skill;   end
  def is_item?;    @class == RPG::Item;    end
  def is_weapon?;  @class == RPG::Weapon;  end
  def is_armor?;   @class == RPG::Armor;   end
  def is_nil?;     @class == nil;          end
  #--------------------------------------------------------------------------
  # * Aquisição das informações do item
  #--------------------------------------------------------------------------
  def object
    return $data_skills[@item_id]  if is_skill?
    return $data_items[@item_id]   if is_item?
    return $data_weapons[@item_id] if is_weapon?
    return $data_armors[@item_id]  if is_armor?
    return nil
  end
  #--------------------------------------------------------------------------
  # * Configuração do objeto do item
  #--------------------------------------------------------------------------
  def object=(item)
    @class = item ? item.class : nil
    @item_id = item ? item.id : 0
  end
  #--------------------------------------------------------------------------
  # * Definir equipamento por ID
  #     is_weapon : flag de arma
  #     item_id   : ID da Arma/Armadura
  #--------------------------------------------------------------------------
  def set_equip(is_weapon, item_id)
    @class = is_weapon ? RPG::Weapon : RPG::Armor
    @item_id = item_id
  end
end
