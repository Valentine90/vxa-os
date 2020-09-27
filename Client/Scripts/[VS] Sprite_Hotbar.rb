#==============================================================================
# ** Sprite_Hotbar
#------------------------------------------------------------------------------
#  Esta classe lida com a exibição dos atalhos.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Sprite_Hotbar < Sprite2
  
  def initialize
    super
    self.bitmap = Bitmap.new(308, 40)
    self.x = adjust_x
    self.y = adjust_y
    self.z = 50
    @back = Cache.system('Hotbar')
    @iconset = Cache.system('Iconset')
    @dragable = true
    @last_item = nil
    create_desc
    refresh
    change_opacity
  end
  
  def adjust_x
    Graphics.width / 2 - 109
  end
  
  def adjust_y
    Graphics.height - 72
  end
  
  def slot_width
    34
  end
  
  def slot_height
    40
  end
  
  def item?
    return true if $cursor.object.is_a?(RPG::Skill)
    return false unless $cursor.object.is_a?(RPG::Item)
    return false unless $cursor.type == Enums::Mouse::ITEM
    return false unless $cursor.object.consumable
    return true
  end
  
  def create_desc
    @desc_sprite = Sprite_Desc.new
    # Deixa a janela de informações sobre o inventário
    @desc_sprite.z = self.z + 100
  end
  
  def refresh
    draw_background
    draw_items
  end
  
  def draw_background
    self.bitmap.clear
    self.bitmap.blt(0, 0, @back, self.bitmap.rect)
  end
  
  def draw_items
    $game_actors[1].hotbar.each_with_index do |item, i|
      draw_icon(item, i) if item
      self.bitmap.draw_text(slot_width * i + 5, 4, slot_width, 18, i + 1)
    end
  end
  
  def draw_icon(item, index)
    rect = Rect.new(item.icon_index % 16 * 24, item.icon_index / 16 * 24, 24, 24)
    item_enable = item.is_a?(RPG::Item) && $game_party.has_item?(item)
    # Se é uma habilidade aprendida (skill_learn) ou
    #adicional (added_skills)
    skill_enable = item.is_a?(RPG::Skill) && $game_actors[1].skills.include?(item)
    opacity = item_enable || skill_enable ? 255 : 160
    self.bitmap.blt(slot_width * index + 6, 7, @iconset, rect, opacity)
    self.bitmap.draw_text(slot_width * index, 19, slot_width, 18, $game_party.item_number(item), 2) if item.is_a?(RPG::Item)
  end
  
  def show_desc(item)
    return if @last_item == item
    @desc_sprite.refresh(item)
    @last_item = item
  end
  
  def hide_desc
    @desc_sprite.visible = false
    @last_item = nil
  end
  
  def update
    super
    change_opacity
    update_drop
    remove_item
    update_desc
  end
  
  def update_drop
    return if Mouse.press?(:L)
    return unless item?
    $game_actors[1].hotbar.each_index do |i|
      next unless in_area?(slot_width * i, 0, slot_width, slot_height)
      $network.send_player_hotbar(i, $cursor.type, $cursor.object.id)
      break
    end
  end
  
  def remove_item
    return unless Mouse.click?(:R)
    $game_actors[1].hotbar.each_with_index do |item, i|
      next unless in_area?(slot_width * i, 0, slot_width, slot_height) && item
      $network.send_player_hotbar(i, Enums::Hotbar::NONE, 0)
      break
    end
  end
  
  def update_desc
    index = -1
    $game_actors[1].hotbar.each_with_index do |item, i|
      next unless in_area?(slot_width * i, 0, slot_width, slot_height) && item 
      index = i
      break
    end
    if index >= 0 && !$cursor.object && !$dragging_window
      show_desc($game_actors[1].hotbar[index])
    else
      hide_desc
    end
  end
  
end
