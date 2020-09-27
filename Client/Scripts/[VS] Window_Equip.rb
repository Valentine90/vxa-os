#==============================================================================
# ** Window_Equip
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de equipamentos.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Equip < Window_Base
  
  def initialize
    # Quando a resolução é alterada, a coordenada x é
    #reajustada no adjust_windows_position da Scene_Map
    super(adjust_x, 165, 212, 112)
    self.visible = false
    self.closable = true
    self.title = Vocab::item
    create_desc
  end
  
  def adjust_x
    Graphics.width - 274
  end
  
  def col_max
    3
  end
  
  def slot_width
    29
  end
  
  def slot_height
    29
  end
  
  def show
    super
    $windows[:item].show
  end
  
  def hide
    super
    $windows[:item].hide
  end
  
  def x=(x)
    super
    $windows[:item].x = x
  end
  
  def y=(y)
    super
    $windows[:item].y = y + height - 1
  end
  
  def sufficient_level?
    result = true
    if $game_actors[1].level < $windows[:item].item.level
      $error_msg = Vocab::InsufficientLevel
      result = false
    end
    result
  end
  
  def equip_vip?
    result = false
    if $windows[:item].item.vip? && !$network.vip?
      $error_msg = Vocab::EquipVIP
      result = true
    end
    result
  end
  
  def different_sex?
    result = false
    if $windows[:item].item.is_a?(RPG::Armor) && $windows[:item].item.sex < 2 && $windows[:item].item.sex != $game_actors[1].sex
      $error_msg = Vocab::DifferentSex
      result = true
    end
    result
  end
  
  def equip_slots
    return [5, 2, 6, 0, 3, 0, 7, 8, 4] if $game_actors[1].dual_wield?
    return [5, 2, 6, 0, 3, 1, 7, 8, 4]
  end
  
  def find_equip
    result = [nil, -1]
    equip_slots.each_with_index do |slot_id, i|
      x = i % col_max * slot_width + 62
      y = i / col_max * slot_height + 12
      if in_area?(x, y, slot_width, slot_height)
        result = [$game_actors[1].equips[slot_id], slot_id]
        break
      end
    end
    result
  end
  
  def refresh
    contents.clear
    bitmap = Cache.system('Equipments')
    contents.blt(50, 0, bitmap, bitmap.rect)
    equip_slots.each_with_index do |slot_id, i|
      equip = $game_actors[1].equips[slot_id]
      x = i % col_max * slot_width + 53
      y = i / col_max * slot_height + 3
      draw_icon(equip.icon_index, x, y) if equip
    end
  end
  
  def update
    super
    unequip_item
    update_drag
    update_drop
    update_desc
  end
  
  def unequip_item
    return unless Mouse.dbl_clk?(:L)
    equip = find_equip[0]
    $network.send_player_equip(0, equip.etype_id) if equip && !$game_party.full_items?(equip)
  end
  
  def update_drag
    return unless Mouse.press?(:L)
    return if $cursor.object
    return if $dragging_window
    equip = find_equip[0]
    $cursor.change_item(equip, Enums::Mouse::EQUIP) if equip
  end
  
  def update_drop
    return if Mouse.press?(:L)
    return unless $cursor.object
    return unless $cursor.type == Enums::Mouse::ITEM
    return unless $game_actors[1].equippable?($cursor.object)
    slot_id = find_equip[1]
    $network.send_player_equip($cursor.object.id, slot_id) if slot_id >= 0 && $cursor.object.etype_id == slot_id && sufficient_level? && !equip_vip? && !different_sex?
  end
  
  def update_desc
    return if $dragging_window
    equip = find_equip[0]
    if equip && !$cursor.object
      show_desc(equip)
    else
      hide_desc
    end
  end
  
end
