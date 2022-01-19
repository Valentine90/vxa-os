#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  Este script lida com a batalha dos inimigos.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Game_Enemy

  CONDITIONS_MET_TABLE = {
    2 => :conditions_met_hp?,
    3 => :conditions_met_mp?,
    4 => :conditions_met_state?,
    5 => :conditions_met_level?,
    6 => :conditions_met_switch?,
  }

  def update_enemy
    if in_battle?
      make_actions
    elsif dead? && Time.now > @revive_time
      revive
    end
  end
  
  def revive
    @hp = mhp
    @mp = mmp
    $network.send_enemy_revive(self)
    change_position unless @move_type == Enums::Move::FIXED
  end

  def die
    @revive_time = Time.now + $data_enemies[@enemy_id].revive_time
    clear_target_players(Enums::Target::ENEMY)
    clear_states
    clear_buffs
    treasure
    disable
    # Limpa o alvo após este ganhar experiência e ouro
    clear_target
  end

  def treasure
    if $network.clients[@target.id].in_party?
      # Não converte em inteiro aqui, pois o resultado provisório ainda será multiplicado pelo bônus VIP
      $network.clients[@target.id].party_share($data_enemies[@enemy_id].exp * EXP_BONUS, rand($data_enemies[@enemy_id].gold).to_i * GOLD_BONUS, @enemy_id)
    else
      # Converte eventual resultado decimal do bônus de experiência em inteiro
      $network.clients[@target.id].gain_exp(($data_enemies[@enemy_id].exp * EXP_BONUS * $network.clients[@target.id].vip_exp_bonus).to_i)
      # Amount será um número inteiro, ainda que o ouro seja 0 e em razão
      #disso o rand retorne um valor decimal
      $network.clients[@target.id].gain_gold((rand($data_enemies[@enemy_id].gold).to_i * GOLD_BONUS * $network.clients[@target.id].gold_rate * $network.clients[@target.id].vip_gold_bonus).to_i, false, true)
      $network.clients[@target.id].add_kills_count(@enemy_id)
    end
    drop_items
  end

  def drop_items
    $data_enemies[@enemy_id].drop_items.each do |drop|
      next if drop.kind == 0 || rand * drop.denominator > (DROP_BONUS + $network.clients[@target.id].drop_item_rate + $network.clients[@target.id].vip_drop_bonus - 2)
      break if $network.maps[@map_id].full_drops?
      $network.maps[@map_id].add_drop(drop.data_id, drop.kind, 1, @x, @y, $network.clients[@target.id].name, $network.clients[@target.id].party_id)
    end 
  end

  def disable
    $network.clients[@target.id].variables[$data_enemies[@enemy_id].disable_variable_id] += 1 if $data_enemies[@enemy_id].disable_variable_id > 0
    if $data_enemies[@enemy_id].disable_switch_id > Configs::MAX_PLAYER_SWITCHES
      $network.switches[$data_enemies[@enemy_id].disable_switch_id] = !$network.switches[$data_enemies[@enemy_id].disable_switch_id]
      # Possibilita que o inimigo reapareça ao ser ativado novamente
      $network.send_enemy_revive(self)
    elsif $data_enemies[@enemy_id].disable_switch_id > 0
      $network.clients[@target.id].switches[$data_enemies[@enemy_id].disable_switch_id] = !$network.clients[@target.id].switches[$data_enemies[@enemy_id].disable_switch_id]
    end
  end

  def change_position
    $network.maps[@map_id].revive_regions[@region_id - 1].size.times do
      region_id = rand($network.maps[@map_id].revive_regions[@region_id - 1].size)
      x = $network.maps[@map_id].revive_regions[@region_id - 1][region_id].x
      y = $network.maps[@map_id].revive_regions[@region_id - 1][region_id].y
      if passable?(x, y, 0)
        moveto(x, y)
        break
      end
    end
  end

  def feature_objects
    states + [$data_enemies[@enemy_id]]
  end
  
  def make_actions
    return if restriction == 4 || @action_time > Time.now
    action_list = $data_enemies[@enemy_id].actions.select { |a| action_valid?(a) }
    unless action_list.empty?
      action = action_list[rand(action_list.size)]
      @action_time = Time.now + Configs::ATTACK_TIME
      action.skill_id == attack_skill_id ? attack_normal : use_item(action.skill_id)
    end
  end

  def action_valid?(action)
    action_conditions_met?(action) && usable?($data_skills[action.skill_id])
  end

  def action_conditions_met?(action)
    method_name = CONDITIONS_MET_TABLE[action.condition_type]
    method_name ? send(method_name, action.condition_param1, action.condition_param2) : true
  end

  def conditions_met_hp?(param1, param2)
    hp_rate >= param1 && hp_rate <= param2
  end

  def conditions_met_mp?(param1, param2)
    mp_rate >= param1 && mp_rate <= param2
  end

  def conditions_met_state?(param1, param2)
    state?(param1)
  end

  def conditions_met_level?(param1, param2)
    $network.clients[@target.id] && valid_target?($network.clients[@target.id]) && $network.clients[@target.id].level >= param1
  end

  def conditions_met_switch?(param1, param2)
    $network.clients[@target.id] && valid_target?($network.clients[@target.id]) && $network.clients[@target.id].switches[param1]
  end

  def attack_normal
    $network.clients.each do |client|
      next if !client&.in_game? || client.map_id != @map_id || !in_front?(client)
      ani_index = $data_enemies[@enemy_id].ani_index || @character_index
      client.item_apply(self, $data_skills[attack_skill_id], $data_skills[attack_skill_id].animation_id, ani_index)
      break
    end
  end
  
  def use_item(item_id)
    item = $data_skills[item_id]
    case item.scope
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

  def item_attack_normal(item)
    target = get_target
    # Se não tem alvo, o alvo é um evento, inimigo morto, ou inimigo vivo fora do alcance
    return if !target || !valid_target?(target) || !in_range?(target, item.range)
    x, y = max_passage(target)
    unless blocked_passage?(target, x, y)
      $network.send_add_projectile(self, x, y, target, Enums::Projectile::SKILL, item.id) if Configs::RANGE_SKILLS.has_key?(item.id)
      target.item_apply(self, item, item.animation_id, item.ani_index)
      self.mp -= item.mp_cost
    end
  end

  def item_attack_area(item)
    used = false
    $network.clients.each do |client|
      if client&.in_game? && client.map_id == @map_id && in_range?(client, item.aoe)
        client.item_apply(self, item, 0, 8)
        used = true
      end
    end
    if used
      self.mp -= item.mp_cost
      $network.send_animation(self, item.animation_id, @id, 1, item.ani_index, Enums::Target::ENEMY)
    end
  end

  def item_recover(item)
    self.mp -= item.mp_cost
    item_apply(self, item, item.animation_id, item.ani_index)
  end

  def send_attack(hp_damage, mp_damage, critical, attacker_id, attacker_type, ani_index, animation_id, not_show_missed)
    $network.send_attack_enemy(@map_id, hp_damage, mp_damage, critical, attacker_id, attacker_type, ani_index, @id, animation_id)
  end

end
