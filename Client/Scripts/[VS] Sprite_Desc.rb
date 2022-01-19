#==============================================================================
# ** Sprite_Desc
#------------------------------------------------------------------------------
#  Esta classe lida com a exibição das informações de itens
# e habilidades.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Sprite_Desc < Sprite2
  
  def initialize
    super
    self.bitmap = Bitmap.new(215, 229)
    self.visible = false
  end
  
  def line_height
    18
  end
  
  def refresh(item)
    @item = item
    draw_basic
    draw_price
    draw_skill
    draw_item
    draw_weapon
    draw_armor
    draw_class
  end
  
  def draw_basic
    self.x = Mouse.x + 12 + self.bitmap.width > Graphics.width ? Graphics.width - self.bitmap.width : Mouse.x + 12
    self.y = Mouse.y + 12 + self.bitmap.height > Graphics.height ? Graphics.height - self.bitmap.height : Mouse.y + 12
    self.visible = true
    self.bitmap.clear
    self.bitmap.fill_rect(self.bitmap.rect, Color.new(0, 0, 0, 160))
    self.bitmap.font.color.set(name_color)
    self.bitmap.draw_text(0, 0, self.bitmap.width, line_height, $game_player.admin? ? "#{@item.name} (ID #{@item.id})" : @item.name, 1)
    self.bitmap.font.color.set(normal_color)
    $windows[:item].word_wrap(@item.description.delete("\n"), self.bitmap.width - 8).each_with_index do |text, i|
      self.bitmap.draw_text(0, 15 * i + line_height, self.bitmap.width, line_height, text, 1)
    end
  end
  
  def name_color
    return crisis_color if @item.is_a?(RPG::Item) && @item.key_item?
    return text_color(5) if @item.is_a?(RPG::EquipItem) && @item.vip?
    return system_color
  end
  
  def draw_skill
    return unless @item.is_a?(RPG::Skill)
    base_damage = @item.damage.eval($game_actors[1], Game_Battler.new, $game_variables).abs
    self.bitmap.draw_text(30, 88, 100, line_height, Vocab::MPCost)
    self.bitmap.draw_text(30, 106, 115, line_height, Vocab::Hit)
    self.bitmap.draw_text(140, 88, 40, line_height, @item.mp_cost, 2)
    self.bitmap.draw_text(145, 106, 35, line_height, "#{@item.success_rate}%", 2)
    if base_damage > 0
      self.bitmap.draw_text(30, 70, 105, line_height, Vocab::BaseDamage)
      self.bitmap.draw_text(130, 70, 50, line_height, format_number(base_damage), 2)
    end
  end
  
  def draw_item
    return unless @item.is_a?(RPG::Item)
    self.bitmap.draw_text(30, 70, 95, line_height, Vocab::Consumable)
    self.bitmap.draw_text(30, 88, 50, line_height, Vocab::ItemType)
    self.bitmap.draw_text(145, 70, 35, line_height, @item.consumable ? Vocab::Yes : Vocab::No, 2)
    self.bitmap.draw_text(92, 88, 90, line_height, @item.key_item? ? Vocab::key_item : Vocab::Normal, 2)
    if @item.level > 0
      self.bitmap.font.color.set($game_actors[1].level < @item.level ? text_color(10) : normal_color)
      self.bitmap.draw_text(30, 106, 55, line_height, "#{Vocab::level}:")
      self.bitmap.draw_text(142, 106, 40, line_height, @item.level, 2)
    end
    draw_soulbound(30, 124)
  end
  
  def draw_weapon
    return unless @item.is_a?(RPG::Weapon)
    (2...8).each do |param_id|
      if param_id > 4
        x = 110
        y = line_height * (param_id - 3) + 34
      else
        x = 0
        y = line_height * param_id + 34
      end
      self.bitmap.draw_text(10 + x, y, 35, line_height, "#{Vocab::param(param_id)}:")
      self.bitmap.draw_text(40 + x, y, 25, line_height, @item.params[param_id], 2)
    end
    draw_two_handed
    draw_level
    draw_difference_weapon_param
    draw_soulbound(10, 178)
  end
  
  def draw_two_handed
    if two_handed_weapon?
      self.bitmap.font.color.set(text_color(2))
      self.bitmap.draw_text(10, 160, 140, line_height, Vocab::TwoHanded)
    else
      self.bitmap.font.color.set(text_color(23))
      self.bitmap.draw_text(10, 160, 140, line_height, Vocab::OneHanded)
    end
  end
  
  def two_handed_weapon?
    @item.features.any? { |feature| feature.code == 54 && feature.data_id == 1 }
  end
  
  def draw_difference_weapon_param
    return if $windows[:equip].in_area? || !$game_actors[1].weapons[0]
    (2...8).each do |param_id|
      dif_param = @item.params[param_id] - $game_actors[1].weapons[0].params[param_id]
      if param_id > 4
        x = 109
        y = line_height * (param_id - 3) + 34
      else
        x = 0
        y = line_height * param_id + 34
      end
      if dif_param > 0
        dif_param = "+#{dif_param}"
        color_id = 5
      else
        color_id = 10
      end
      self.bitmap.font.color.set(text_color(color_id))
      self.bitmap.draw_text(60 + x, y, 35, line_height, dif_param, 2) if dif_param != 0
    end
  end
  
  def draw_armor
    return unless @item.is_a?(RPG::Armor)
    [3, 5, 6, 7, 0, 1].each_with_index do |param_id, i|
      if i > 2
        x = 110
        y = line_height * (i - 3) + 70
      else
        x = 0
        y = line_height * i + 70
      end
      self.bitmap.draw_text(10 + x, y, 40, line_height, "#{Vocab::param(param_id)}:")
      self.bitmap.draw_text(40 + x, y, 30, line_height, @item.params[param_id], 2)
    end
    draw_level
    draw_difference_armor_param
    draw_soulbound(10, 178)
  end
  
  def draw_difference_armor_param
    return if $windows[:equip].in_area? || !$game_actors[1].equips[@item.etype_id]
    [3, 5, 6, 7, 0, 1].each_with_index do |param_id, i|
      dif_param = @item.params[param_id] - $game_actors[1].equips[@item.etype_id].params[param_id]
      if i > 2
        x = 114
        y = line_height * (i - 3) + 70
      else
        x = 0
        y = line_height * i + 70
      end
      if dif_param > 0
        dif_param = "+#{dif_param}"
        color_id = 5
      else
        color_id = 10
      end
      self.bitmap.font.color.set(text_color(color_id))
      self.bitmap.draw_text(60 + x, y , 35, line_height, dif_param, 2) if dif_param != 0
    end
  end
  
  def draw_level
    return if @item.level == 0
    self.bitmap.font.color.set($game_actors[1].level < @item.level ? text_color(10) : normal_color)
    self.bitmap.draw_text(10, 124, 90, line_height, "#{Vocab::level}: #{@item.level}")
  end
  
  def draw_soulbound(x, y)
    return unless @item.soulbound?
    self.bitmap.font.color.set(text_color(3))
    self.bitmap.draw_text(x, y, 100, line_height, Vocab::Soulbound)
  end
  
  def draw_price
    return unless $windows[:shop].visible
    if $windows[:shop].in_area?
      self.bitmap.draw_text(0, 206, self.bitmap.width, line_height, "$ #{format_number($windows[:shop].price[@item])}", 1)
    elsif $windows[:item].in_area? || $windows[:equip].in_area?
      self.bitmap.draw_text(0, 206, self.bitmap.width, line_height, "$ #{format_number(@item.price / 2)}", 1)
    end
  end
  
  def draw_class
    return unless @item.is_a?(RPG::EquipItem)
    if $game_actors[1].equippable?(@item)
      self.bitmap.font.color.set(text_color(29))
      self.bitmap.draw_text(10, 142, self.bitmap.width + 32, line_height, "#{Vocab::Equipable} #{$game_actors[1].class.name}")
    else
      self.bitmap.font.color.set(text_color(10))
      self.bitmap.draw_text(10, 142, self.bitmap.width + 32, line_height, "#{Vocab::NotEquipable} #{$game_actors[1].class.name}")
    end
  end
  
end
