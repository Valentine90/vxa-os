#==============================================================================
# ** Sprite_Party
#------------------------------------------------------------------------------
#  Esta classe lida com a exibição dos membros do grupo.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Sprite_Party < Sprite2
  
  def initialize
    super
    self.bitmap = Bitmap.new(141, 39 * Configs::MAX_PARTY_MEMBERS)
    self.y = 121
    self.z = 50
    self.visible = false
    @exit_icon = Icon.new(nil, 9, 0, Configs::LEAVE_PARTY_ICON, Vocab::game_end) { $windows[:choice].show(Vocab::Ask, Enums::Choice::LEAVE_PARTY) }
    @exit_icon.visible = false
    @bitmap = Cache.system('PartyBase')
  end
  
  def refresh_icon_y
    @exit_icon.y = 39 * $game_actors[1].party_members.size + self.y + 5
  end
  
  def opacity(member_id)
    $game_map.players.has_key?(member_id) ? 255 : 160
  end
  
  def show
    self.visible = true
    @exit_icon.visible = true
    refresh
  end
  
  def hide
    self.visible = false
    @exit_icon.visible = false
  end
  
  def dispose
    super
    @exit_icon.dispose
  end
  
  def refresh
    self.bitmap.clear
    $game_actors[1].party_members.values.each_with_index do |member, i|
      draw_character(i, member)
      draw_paperdolls(i, member)
      draw_name(i, member)
      draw_level(i, member)
      draw_hp_bar(i, member)
    end
    refresh_icon_y
  end
  
  def draw_character(index, member)
    self.bitmap.blt(0, 39 * index, @bitmap, @bitmap.rect, opacity(member.id))
    return unless member.actor.character_name
    bitmap = Cache.character(member.actor.character_name)
    sign = member.actor.character_name[/^[\!\$]./]
    if sign && sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    src_rect = Rect.new((member.actor.character_index % 4 * 3 + 1) * cw, (member.actor.character_index / 4 * 4) * ch, cw, 24)
    self.bitmap.blt(10, 39 * index - 2, bitmap, src_rect, opacity(member.id))
  end
  
  def draw_paperdolls(index, member)
    # Armadura, amuleto, capacete, capa e acessório
    [3, 5, 2, 6, 4].each do |slot_id|
      next unless member.actor.equips[slot_id]
      draw_paperdoll(index, member.actor.equips[slot_id], member.actor.sex, opacity(member.id))
    end
  end
  
  def draw_paperdoll(index, equip, sex, opacity)
    return unless equip.paperdoll_name
    bitmap = Cache.paperdoll(equip.paperdoll_name, sex)
    sign = equip.paperdoll_name[/^[\!\$]./]
    if sign && sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    src_rect = Rect.new((equip.paperdoll_index % 4 * 3 + 1) * cw, (equip.paperdoll_index / 4 * 4) * ch, cw, 24)
    self.bitmap.blt(10, 39 * index - 2, bitmap, src_rect, opacity)
  end
  
  def draw_level(index, member)
    self.bitmap.draw_text(0, 39 * index + 1, self.bitmap.width - 2, 18, "#{Vocab::level_a}. #{member.actor.level}", 2)
  end
  
  def draw_name(index, member)
    self.bitmap.draw_text(47, 39 * index + 1, self.bitmap.width, 18, member.actor.name)
  end
  
  def draw_hp_bar(index, member)
    bar = Cache.system('PartyHPBar')
    self.bitmap.blt(4, 39 * index + 21, bar, Rect.new(0, 0, bar.width, bar.height / 2), opacity(member.id))
    rect = Rect.new(0, bar.height / 2, bar.width * member.actor.hp / member.actor.mhp, bar.height / 2)
    self.bitmap.blt(4, 39 * index + 21, bar, rect, opacity(member.id))
  end
  
  def update
    super
    @exit_icon.update
  end
  
end
