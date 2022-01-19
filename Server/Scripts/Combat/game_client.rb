#==============================================================================
# ** Game_Client
#------------------------------------------------------------------------------
#  Este script lida com a batalha dos jogadores.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Game_Client < EventMachine::Connection

  EFFECT_COMMON_EVENT = 44

  def attack_normal
    return if restriction == 4
    @weapon_attack_time = Time.now + Configs::ATTACK_TIME
    ani_index = $data_weapons[weapon_id].ani_index || @character_index
    $network.maps[@map_id].events.each_value do |event|
      # Se é um evento, inimigo morto, ou inimigo vivo fora do alcance
      next if event.dead? || !in_front?(event)
      hit_enemy(event, $data_weapons[weapon_id].animation_id, ani_index, $data_skills[attack_skill_id])
      return
    end
    return unless $network.maps[@map_id].pvp
    return unless $network.maps[@map_id].total_players > 1
    $network.clients.each do |client|
      next if !client&.in_game? || client.map_id != @map_id || !in_front?(client) || client.admin? || protection_level?(client)
      hit_player(client, $data_weapons[weapon_id].animation_id, ani_index, $data_skills[attack_skill_id])
      break
    end
  end

  def attack_range
    return if restriction == 4
    @weapon_attack_time = Time.now + Configs::ATTACK_TIME
    return if Configs::RANGE_WEAPONS[weapon_id][:item_id] > 0 && !has_item?($data_items[Configs::RANGE_WEAPONS[weapon_id][:item_id]])
    return if Configs::RANGE_WEAPONS[weapon_id][:mp_cost] && mp < Configs::RANGE_WEAPONS[weapon_id][:mp_cost]
    target = get_target
    return unless target && in_range?(target, Configs::RANGE_WEAPONS[weapon_id][:range])
    lose_item($data_items[Configs::RANGE_WEAPONS[weapon_id][:item_id]], 1) if Configs::RANGE_WEAPONS[weapon_id][:item_id] > 0
    self.mp -= Configs::RANGE_WEAPONS[weapon_id][:mp_cost] if Configs::RANGE_WEAPONS[weapon_id][:mp_cost]
    x, y = max_passage(target)
    $network.send_add_projectile(self, x, y, target, Enums::Projectile::WEAPON, weapon_id)
    return if blocked_passage?(target, x, y)
    ani_index = $data_weapons[weapon_id].ani_index || @character_index
    if @target.type == Enums::Target::PLAYER && valid_target?(target) && $network.maps[@map_id].pvp && !target.admin? && !protection_level?(target)
      hit_player(target, $data_weapons[weapon_id].animation_id, ani_index, $data_skills[attack_skill_id])
    elsif @target.type == Enums::Target::ENEMY && !target.dead?
      hit_enemy(target, $data_weapons[weapon_id].animation_id, ani_index, $data_skills[attack_skill_id])
    end
  end

  def use_item(item)
    @item_attack_time = Time.now + Configs::COOLDOWN_SKILL_TIME
    # Se não tem o item ou ele não é usável
    return unless usable?(item)
    return if item.level > @level
    self.mp -= item.mp_cost if item.is_a?(RPG::Skill)
    consume_item(item) if item.is_a?(RPG::Item)
    item.effects.each { |effect| item_global_effect_apply(effect) }
    case item.scope
    when Enums::Item::SCOPE_ALL_ALLIES
      item_party_recovery(item)
    when Enums::Item::SCOPE_ENEMY..Enums::Item::SCOPE_ALLIES_KNOCKED_OUT
      if item.aoe?
        item_attack_area(item)
      else
        item_attack_normal(item)
      end
    when Enums::Item::SCOPE_USER
      item_recover(item)
    end
  end

  def consume_item(item)
    return unless item.consumable
    lose_item(item, 1)
    lose_trade_item(item, 1) if in_trade? && trade_item_number(@trade_items[item.id]) > item_number(item)
  end

  def item_global_effect_apply(effect)
    return unless effect.code == EFFECT_COMMON_EVENT && !@common_events[effect.data_id]&.running?
    @common_events[effect.data_id] = Game_Interpreter.new
    # O parâmetro event_id é diferente de 0 para que o waiting_event seja modificado no Game_Interpreter
    #e negativo para que seja identificado como evento comum no handle_event_command do cliente
    @common_events[effect.data_id].setup(self, $data_common_events[effect.data_id].list, -effect.data_id, $data_common_events[effect.data_id])
    @common_events.delete(effect.data_id) unless @common_events[effect.data_id].running?
  end
  
  def item_attack_normal(item)
    target = get_target
    # Se não tem alvo, o alvo é um evento, inimigo morto, ou inimigo vivo fora do alcance, ou o item é para aliado
    if !target || target.dead? || !in_range?(target, item.range) || @target.type == Enums::Target::ENEMY && item.for_friend?
      # Usa o item que afeta apenas aliados no próprio jogador
      item_apply(self, item, item.animation_id, item.ani_index) if item.for_friend?
      return
    end
    x, y = max_passage(target)
    $network.send_add_projectile(self, x, y, target, Enums::Projectile::SKILL, item.id) if item.is_a?(RPG::Skill) && Configs::RANGE_SKILLS.has_key?(item.id)
    return if blocked_passage?(target, x, y)
    if @target.type == Enums::Target::PLAYER && valid_target?(target)
      hit_player(target, item.animation_id, item.ani_index, item) if item.for_friend? || $network.maps[@map_id].pvp && !target.admin? && !protection_level?(target)
    elsif @target.type == Enums::Target::ENEMY
      hit_enemy(target, item.animation_id, item.ani_index, item)
    end
  end

  def item_attack_area(item)
    $network.maps[@map_id].events.each_value do |event|
      next if event.dead? || !in_range?(event, item.aoe)
      hit_enemy(event, 0, 8, item)
    end
    if $network.maps[@map_id].pvp && $network.maps[@map_id].total_players > 1
      $network.clients.each do |client|
        next if !client&.in_game? || client.map_id != @map_id || !in_range?(client, item.aoe) || client.admin? || protection_level?(client) || client == self
        hit_player(client, 0, 8, item)
      end
    end
    $network.send_animation(self, item.animation_id, @id, 0, item.ani_index, Enums::Target::PLAYER)
  end

  def item_recover(item)
    item_apply(self, item, item.animation_id, item.ani_index)
  end

  def protection_level?(target)
    @level < Configs::MIN_LEVEL_PVP || target.level < Configs::MIN_LEVEL_PVP
  end

  def hit_player(client, animation_id, ani_index, skill)
    change_target(client.id, Enums::Target::PLAYER)
    client.item_apply(self, skill, animation_id, ani_index)
  end

  def hit_enemy(event, animation_id, ani_index, skill)
    change_target(event.id, Enums::Target::ENEMY)
    event.target.id = @id
    event.item_apply(self, skill, animation_id, ani_index)
  end

  def send_attack(hp_damage, mp_damage, critical, attacker_id, attacker_type, ani_index, animation_id, not_show_missed)
    $network.send_attack_player(@map_id, hp_damage, mp_damage, critical, attacker_id, attacker_type, ani_index, @id, animation_id, not_show_missed)
  end
  
  def die
    lose_gold(@gold * LOSE_GOLD_RATE / 100)
    lose_exp(@exp * lose_exp_rate / 100)
    recover_all
    clear_states
    clear_buffs
    transfer(@revive_map_id, @revive_x, @revive_y, Enums::Dir::DOWN)
    if has_text?
      @event_interpreter.finalize
      close_event_message
    end
  end

end
