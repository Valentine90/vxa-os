#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  Esta classe gerencia os battlers. Controla a adição de sprites e ações 
# dos lutadores durante o combate.
# É usada como a superclasse das classes Game_Enemy e Game_Actor.
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Constantes (Efeitos)
  #--------------------------------------------------------------------------
  EFFECT_RECOVER_HP     = 11              # Recuperação de HP
  EFFECT_RECOVER_MP     = 12              # Recuperação de MP
  EFFECT_GAIN_TP        = 13              # Aumento de TP
  EFFECT_ADD_STATE      = 21              # Etados adicionais
  EFFECT_REMOVE_STATE   = 22              # Etados removidos
  EFFECT_ADD_BUFF       = 31              # Fortalecimentos adicionais
  EFFECT_ADD_DEBUFF     = 32              # Enfraquecimentos adicionais
  EFFECT_REMOVE_BUFF    = 33              # Fortalecimentos removidos
  EFFECT_REMOVE_DEBUFF  = 34              # Enfraquecimentos removidos
  EFFECT_SPECIAL        = 41              # Efeitos especiais
  EFFECT_GROW           = 42              # Crecimento
  EFFECT_LEARN_SKILL    = 43              # Aprender habilidade
  EFFECT_COMMON_EVENT   = 44              # Evento comun
  #--------------------------------------------------------------------------
  # * Constantes (Efeitos Especiais)
  #--------------------------------------------------------------------------
  SPECIAL_EFFECT_ESCAPE = 0               # Fuga
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :battler_name             # Nome do arquivo gráfico
  attr_reader   :battler_hue              # Tonalidade do arquivo gráfico
  attr_reader   :action_times             # Número de ações
  attr_reader   :actions                  # Lista de ações
  attr_reader   :speed                    # Velocidade da ação
  attr_reader   :result                   # Resultado da ação
  attr_accessor :last_target_index        # Último alvp
  attr_accessor :animation_id             # ID da animação
  attr_accessor :animation_mirror         # Flag de inversão de animação
  attr_accessor :sprite_effect_type       # Efeitos de sprite
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #--------------------------------------------------------------------------
  def initialize
    @battler_name = ""
    @battler_hue = 0
    @actions = []
    @speed = 0
    @result = Game_ActionResult.new(self)
    @last_target_index = 0
    @guarding = false
    clear_sprite_effects
    super
  end
  #--------------------------------------------------------------------------
  # * Limpeza dos efeitos dos sprites
  #--------------------------------------------------------------------------
  def clear_sprite_effects
    @animation_id = 0
    @animation_mirror = false
    @sprite_effect_type = nil
  end
  #--------------------------------------------------------------------------
  # * Limpeza das ações
  #--------------------------------------------------------------------------
  def clear_actions
    @actions.clear
  end
  #--------------------------------------------------------------------------
  # * Limpeza dos estados
  #--------------------------------------------------------------------------
  def clear_states
    super
    @result.clear_status_effects
  end
  #--------------------------------------------------------------------------
  # * Adição de estado
  #     state_id : ID do estado
  #--------------------------------------------------------------------------
  def add_state(state_id)
    if state_addable?(state_id)
      add_new_state(state_id) unless state?(state_id)
      reset_state_counts(state_id)
      @result.added_states.push(state_id).uniq!
    end
  end
  #--------------------------------------------------------------------------
  # * Definição de adição de estados
  #     state_id : ID do estado
  #--------------------------------------------------------------------------
  def state_addable?(state_id)
    alive? && $data_states[state_id] && !state_resist?(state_id) &&
      !state_removed?(state_id) && !state_restrict?(state_id)
  end
  #--------------------------------------------------------------------------
  # * Definição de remoção de estados
  #     state_id : ID do estado
  #--------------------------------------------------------------------------
  def state_removed?(state_id)
    @result.removed_states.include?(state_id)
  end
  #--------------------------------------------------------------------------
  # * Definição de estados invalidados por uma restrição comportamental
  #     state_id : ID do estado
  #--------------------------------------------------------------------------
  def state_restrict?(state_id)
    $data_states[state_id].remove_by_restriction && restriction > 0
  end
  #--------------------------------------------------------------------------
  # * Adição de um novo estado
  #     state_id : ID do estado
  #--------------------------------------------------------------------------
  def add_new_state(state_id)
    # VXA-OS
    #die if state_id == death_state_id
    @states.push(state_id)
    on_restrict if restriction > 0
    sort_states
    refresh
  end
  #--------------------------------------------------------------------------
  # * Ação quando há uma restrição
  #--------------------------------------------------------------------------
  def on_restrict
    clear_actions
    # VXA-OS
=begin
    states.each do |state|
      remove_state(state.id) if state.remove_by_restriction
    end
=end
  end
  #--------------------------------------------------------------------------
  # * Redefinição do contador dos estados
  #     state_id : ID do estado
  #--------------------------------------------------------------------------
  def reset_state_counts(state_id)
    state = $data_states[state_id]
    variance = 1 + [state.max_turns - state.min_turns, 0].max
    @state_turns[state_id] = state.min_turns + rand(variance)
    @state_steps[state_id] = state.steps_to_remove
  end
  #--------------------------------------------------------------------------
  # * Remoção de estado
  #     state_id : ID do estado
  #--------------------------------------------------------------------------
  def remove_state(state_id)
    if state?(state_id)
      # VXA-OS
      #revive if state_id == death_state_id
      erase_state(state_id)
      refresh
      @result.removed_states.push(state_id).uniq!
    end
  end
  #--------------------------------------------------------------------------
  # * Adição de incapacitação
  #--------------------------------------------------------------------------
  def die
    @hp = 0
    clear_states
    clear_buffs
  end
=begin
  #--------------------------------------------------------------------------
  # * Remoção de incapacitação
  #--------------------------------------------------------------------------
  def revive
    @hp = 1 if @hp == 0
  end
=end
  #--------------------------------------------------------------------------
  # * Fuga
  #--------------------------------------------------------------------------
  def escape
    hide if $game_party.in_battle
    clear_actions
    clear_states
    Sound.play_escape
  end
  #--------------------------------------------------------------------------
  # * Adição de fortalecimento
  #     param_id : ID do parâmetro
  #     turns    : turnos
  #--------------------------------------------------------------------------
  def add_buff(param_id, turns)
    return unless alive?
    @buffs[param_id] += 1 unless buff_max?(param_id)
    erase_buff(param_id) if debuff?(param_id)
    overwrite_buff_turns(param_id, turns)
    @result.added_buffs.push(param_id).uniq!
    refresh
  end
  #--------------------------------------------------------------------------
  # * Adição de enfraquecimento
  #     param_id : ID do parâmetro
  #     turns    : turnos
  #--------------------------------------------------------------------------
  def add_debuff(param_id, turns)
    return unless alive?
    @buffs[param_id] -= 1 unless debuff_max?(param_id)
    erase_buff(param_id) if buff?(param_id)
    overwrite_buff_turns(param_id, turns)
    @result.added_debuffs.push(param_id).uniq!
    refresh
  end
  #--------------------------------------------------------------------------
  # * Remoção de fortalecimento/enfraquecimento
  #     param_id : ID do parâmetro
  #--------------------------------------------------------------------------
  def remove_buff(param_id)
    return unless alive?
    return if @buffs[param_id] == 0
    erase_buff(param_id)
    @buff_turns.delete(param_id)
    @result.removed_buffs.push(param_id).uniq!
    refresh
  end
  #--------------------------------------------------------------------------
  # * Limpeza dos fortalecimento/enfraquecimento
  #     param_id : ID do parâmetro
  #--------------------------------------------------------------------------
  def erase_buff(param_id)
    @buffs[param_id] = 0
    @buff_turns[param_id] = 0
  end
  #--------------------------------------------------------------------------
  # * Definição de fortalecimento
  #     param_id : ID do parâmetro
  #--------------------------------------------------------------------------
  def buff?(param_id)
    @buffs[param_id] > 0
  end
  #--------------------------------------------------------------------------
  # * Definição de enfraquecimento
  #     param_id : ID do parâmetro
  #--------------------------------------------------------------------------
  def debuff?(param_id)
    @buffs[param_id] < 0
  end
  #--------------------------------------------------------------------------
  # * Definição de nível máximo de fortalecimento
  #     param_id : ID do parâmetro
  #--------------------------------------------------------------------------
  def buff_max?(param_id)
    @buffs[param_id] == 2
  end
  #--------------------------------------------------------------------------
  # * Definição de nível máximo de enfraquecimento
  #     param_id : ID do parâmetro
  #--------------------------------------------------------------------------
  def debuff_max?(param_id)
    @buffs[param_id] == -2
  end
  #--------------------------------------------------------------------------
  # * Substituir o número de turnos do fortalecimento/enfraquecimento 
  #    Se o novo valor for menor, não haverão modificação
  #     param_id : ID do parâmetro
  #     turns    : turnos
  #--------------------------------------------------------------------------
  def overwrite_buff_turns(param_id, turns)
    @buff_turns[param_id] = turns if @buff_turns[param_id].to_i < turns
  end
  #--------------------------------------------------------------------------
  # * Atualização da contagem de estados
  #--------------------------------------------------------------------------
  def update_state_turns
    states.each do |state|
      @state_turns[state.id] -= 1 if @state_turns[state.id] > 0
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização da contagem de fortalecimento/enfraquecimento
  #--------------------------------------------------------------------------
  def update_buff_turns
    @buff_turns.keys.each do |param_id|
      @buff_turns[param_id] -= 1 if @buff_turns[param_id] > 0
    end
  end
  #--------------------------------------------------------------------------
  # * Remoção de estados ao fim do comabate
  #--------------------------------------------------------------------------
  def remove_battle_states
    states.each do |state|
      remove_state(state.id) if state.remove_at_battle_end
    end
  end
  #--------------------------------------------------------------------------
  # * Remoção de todos fortalecimentos/enfraquecimentos
  #--------------------------------------------------------------------------
  def remove_all_buffs
    @buffs.size.times {|param_id| remove_buff(param_id) }
  end
  #--------------------------------------------------------------------------
  # * Limpeza dos estados autmaticamente
  #     timing : tempo (1:fim da ação, 2:fim do turno)
  #--------------------------------------------------------------------------
  def remove_states_auto(timing)
    states.each do |state|
      if @state_turns[state.id] == 0 && state.auto_removal_timing == timing
        remove_state(state.id)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Limpeza dos fortalecimentos/enfraquecimentos autmaticamente
  #--------------------------------------------------------------------------
  def remove_buffs_auto
    @buffs.size.times do |param_id|
      next if @buffs[param_id] == 0 || @buff_turns[param_id] > 0
      remove_buff(param_id)
    end
  end
  #--------------------------------------------------------------------------
  # * Limpeza dos estados por dano
  #--------------------------------------------------------------------------
  def remove_states_by_damage
    states.each do |state|
      if state.remove_by_damage && rand(100) < state.chance_by_damage
        remove_state(state.id)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Definição de o número de ações
  #--------------------------------------------------------------------------
  def make_action_times
    action_plus_set.inject(1) {|r, p| rand < p ? r + 1 : r }
  end
  #--------------------------------------------------------------------------
  # * Criação da ações do combate
  #--------------------------------------------------------------------------
  def make_actions
    clear_actions
    return unless movable?
    @actions = Array.new(make_action_times) { Game_Action.new(self) }
  end
  #--------------------------------------------------------------------------
  # * Definição de velocidade da ação
  #--------------------------------------------------------------------------
  def make_speed
    @speed = @actions.collect {|action| action.speed }.min || 0
  end
  #--------------------------------------------------------------------------
  # * Aquisição das ações atuais
  #--------------------------------------------------------------------------
  def current_action
    @actions[0]
  end
  #--------------------------------------------------------------------------
  # * Remoção de ação atual
  #--------------------------------------------------------------------------
  def remove_current_action
    @actions.shift
  end
  #--------------------------------------------------------------------------
  # * Forçar ação
  #     skill_id     : ID da habilidade
  #     target_index : índice do alvo
  #--------------------------------------------------------------------------
  def force_action(skill_id, target_index)
    clear_actions
    action = Game_Action.new(self, true)
    action.set_skill(skill_id)
    if target_index == -2
      action.target_index = last_target_index
    elsif target_index == -1
      action.decide_random_target
    else
      action.target_index = target_index
    end
    @actions.push(action)
  end
  #--------------------------------------------------------------------------
  # * Cálculo de dano
  #     user : usuário
  #     item : habilidade/item
  #--------------------------------------------------------------------------
  def make_damage_value(user, item)
    value = item.damage.eval(user, self, $game_variables)
    value *= item_element_rate(user, item)
    value *= pdr if item.physical?
    value *= mdr if item.magical?
    value *= rec if item.damage.recover?
    value = apply_critical(value) if @result.critical
    value = apply_variance(value, item.damage.variance)
    value = apply_guard(value)
    @result.make_damage(value.to_i, item)
  end
  #--------------------------------------------------------------------------
  # * Aquisição do modificador de elemento de habilidades/itens
  #     user : usuário
  #     item : habilidade/item
  #--------------------------------------------------------------------------
  def item_element_rate(user, item)
    if item.damage.element_id < 0
      user.atk_elements.empty? ? 1.0 : elements_max_rate(user.atk_elements)
    else
      element_rate(item.damage.element_id)
    end
  end
  #--------------------------------------------------------------------------
  # * Aquisição do valor máximo da modificação de elementos
  #     elements : Lista de IDs dos elementos
  #    Fixa os valores mais eficazes de um determinado elemento
  #--------------------------------------------------------------------------
  def elements_max_rate(elements)
    elements.inject([0.0]) {|r, i| r.push(element_rate(i)) }.max
  end
  #--------------------------------------------------------------------------
  # * Aplicar dano crítico
  #     damage : dano base
  #--------------------------------------------------------------------------
  def apply_critical(damage)
    damage * 3
  end
  #--------------------------------------------------------------------------
  # * Aplicar variação de dano
  #     damage   : dano base
  #     variance : grau de variação
  #--------------------------------------------------------------------------
  def apply_variance(damage, variance)
    amp = [damage.abs * variance / 100, 0].max.to_i
    var = rand(amp + 1) + rand(amp + 1) - amp
    damage >= 0 ? damage + var : damage - var
  end
  #--------------------------------------------------------------------------
  # * Aplicar defesa
  #     damage : dano base
  #--------------------------------------------------------------------------
  def apply_guard(damage)
    damage / (damage > 0 && guard? ? 2 * grd : 1)
  end
  #--------------------------------------------------------------------------
  # * Processamento do dano
  #     user : usuário
  #--------------------------------------------------------------------------
  def execute_damage(user)
    on_damage(@result.hp_damage) if @result.hp_damage > 0
    self.hp -= @result.hp_damage
    self.mp -= @result.mp_damage
    user.hp += @result.hp_drain
    user.mp += @result.mp_drain
  end
  #--------------------------------------------------------------------------
  # * Usando habilidade/item
  #     item :  habilidade/item
  #--------------------------------------------------------------------------
  def use_item(item)
    pay_skill_cost(item) if item.is_a?(RPG::Skill)
    consume_item(item)   if item.is_a?(RPG::Item)
    item.effects.each {|effect| item_global_effect_apply(effect) }
  end
  #--------------------------------------------------------------------------
  # * Consumir item
  #     item : item consumido
  #--------------------------------------------------------------------------
  def consume_item(item)
    $game_party.consume_item(item)
  end
=begin
  #--------------------------------------------------------------------------
  # * Definição de chamade de evento comum
  #     effect : efeito
  #--------------------------------------------------------------------------
  def item_global_effect_apply(effect)
    if effect.code == EFFECT_COMMON_EVENT
      $game_temp.reserve_common_event(effect.data_id)
    end
  end
=end
  #--------------------------------------------------------------------------
  # * Testar a aplicação de habilidades/itens
  #    Para determinar proibição de recuperação quando se usa em um alvo
  #    completamente recuperado.
  #     user : usuário
  #     item : habilidade/item
  #--------------------------------------------------------------------------
  def item_test(user, item)
    return false if item.for_dead_friend? != dead?
    return true if $game_party.in_battle
    return true if item.for_opponent?
    return true if item.damage.recover? && item.damage.to_hp? && hp < mhp
    return true if item.damage.recover? && item.damage.to_mp? && mp < mmp
    return true if item_has_any_valid_effects?(user, item)
    return false
  end
  #--------------------------------------------------------------------------
  # * Definição de estados válido para habilidade/item
  #     user : usuário
  #     item : habilidade/item
  #--------------------------------------------------------------------------
  def item_has_any_valid_effects?(user, item)
    item.effects.any? {|effect| item_effect_test(user, item, effect) }
  end
  #--------------------------------------------------------------------------
  # * Cálculo da taxa de contra-ataque de habilidades/itens
  #     user : usuário
  #     item : habilidade/item
  #--------------------------------------------------------------------------
  def item_cnt(user, item)
    return 0 unless item.physical?          # Verifcar se e ataque físico
    return 0 unless opposite?(user)         # Aliados não contra-atacam
    return cnt                              # Taxa de contra-ataque
  end
  #--------------------------------------------------------------------------
  # * Cálculo da taxa de reflexão de habilidades/itens
  #     user : usuário
  #     item : habilidade/item
  #--------------------------------------------------------------------------
  def item_mrf(user, item)
    return mrf if item.magical?             # Verifcar se é magia
    return 0
  end
  #--------------------------------------------------------------------------
  # * Cálculo da taxa de precisão de habilidades/itens
  #     user : usuário
  #     item : habilidade/item
  #--------------------------------------------------------------------------
  def item_hit(user, item)
    rate = item.success_rate * 0.01         # Aquisição da taxa de sucesso
    rate *= user.hit if item.physical?      # Ataque físico: multiplicar precisão
    return rate                             # Taxa de precisão
  end
  #--------------------------------------------------------------------------
  # * Cálculo da taxa de esquiva de habilidades/itens
  #     user : usuário
  #     item : habilidade/item
  #--------------------------------------------------------------------------
  def item_eva(user, item)
    return eva if item.physical?            # Esquiva para ataques físicos
    return mev if item.magical?             # Esquiva Mágica para magias
    return 0
  end
  #--------------------------------------------------------------------------
  # * Cálculo da taxa de crítico de habilidades/itens
  #     user : usuário
  #     item : habilidade/item
  #--------------------------------------------------------------------------
  def item_cri(user, item)
    item.damage.critical ? user.cri * (1 - cev) : 0
  end
  #--------------------------------------------------------------------------
  # * Aplicar ataque normal
  #     attacker : atacantes
  #--------------------------------------------------------------------------
  def attack_apply(attacker)
    item_apply(attacker, $data_skills[attacker.attack_skill_id])
  end
  #--------------------------------------------------------------------------
  # * Aplicar habilidades/itens
  #     user : usuário
  #     item : habilidade/item
  #--------------------------------------------------------------------------
  def item_apply(user, item)
    @result.clear
    @result.used = item_test(user, item)
    @result.missed = (@result.used && rand >= item_hit(user, item))
    @result.evaded = (!@result.missed && rand < item_eva(user, item))
    if @result.hit?
      unless item.damage.none?
        @result.critical = (rand < item_cri(user, item))
        make_damage_value(user, item)
        execute_damage(user)
      end
      item.effects.each {|effect| item_effect_apply(user, item, effect) }
      item_user_effect(user, item)
    end
  end
  #--------------------------------------------------------------------------
  # * Testar efeito do uso de habilidades/itens
  #     user   : usuário
  #     item   : habilidade/item
  #     effect : efeito
  #--------------------------------------------------------------------------
  def item_effect_test(user, item, effect)
    case effect.code
    when EFFECT_RECOVER_HP
      hp < mhp || effect.value1 < 0 || effect.value2 < 0
    when EFFECT_RECOVER_MP
      mp < mmp || effect.value1 < 0 || effect.value2 < 0
    when EFFECT_ADD_STATE
      !state?(effect.data_id)
    when EFFECT_REMOVE_STATE
      state?(effect.data_id)
    when EFFECT_ADD_BUFF
      !buff_max?(effect.data_id)
    when EFFECT_ADD_DEBUFF
      !debuff_max?(effect.data_id)
    when EFFECT_REMOVE_BUFF
      buff?(effect.data_id)
    when EFFECT_REMOVE_DEBUFF
      debuff?(effect.data_id)
    when EFFECT_LEARN_SKILL
      actor? && !skills.include?($data_skills[effect.data_id])
    else
      true
    end
  end
  #--------------------------------------------------------------------------
  # * Aplicar efeito do uso habilidades/itens
  #     user   : usuário
  #     item   : habilidade/item
  #     effect : efeito
  #--------------------------------------------------------------------------
  def item_effect_apply(user, item, effect)
    method_table = {
      EFFECT_RECOVER_HP    => :item_effect_recover_hp,
      EFFECT_RECOVER_MP    => :item_effect_recover_mp,
      EFFECT_GAIN_TP       => :item_effect_gain_tp,
      EFFECT_ADD_STATE     => :item_effect_add_state,
      EFFECT_REMOVE_STATE  => :item_effect_remove_state,
      EFFECT_ADD_BUFF      => :item_effect_add_buff,
      EFFECT_ADD_DEBUFF    => :item_effect_add_debuff,
      EFFECT_REMOVE_BUFF   => :item_effect_remove_buff,
      EFFECT_REMOVE_DEBUFF => :item_effect_remove_debuff,
      EFFECT_SPECIAL       => :item_effect_special,
      EFFECT_GROW          => :item_effect_grow,
      EFFECT_LEARN_SKILL   => :item_effect_learn_skill,
      EFFECT_COMMON_EVENT  => :item_effect_common_event,
    }
    method_name = method_table[effect.code]
    send(method_name, user, item, effect) if method_name
  end
  #--------------------------------------------------------------------------
  # * Efeito do uso [Recuperar HP]
  #     user   : usuário
  #     item   : habilidade/item
  #     effect : efeito
  #--------------------------------------------------------------------------
  def item_effect_recover_hp(user, item, effect)
    value = (mhp * effect.value1 + effect.value2) * rec
    value *= user.pha if item.is_a?(RPG::Item)
    value = value.to_i
    @result.hp_damage -= value
    @result.success = true
    self.hp += value
  end
  #--------------------------------------------------------------------------
  # * Efeito do uso [Recuperar MP]
  #     user   : usuário
  #     item   : habilidade/item
  #     effect : efeito
  #--------------------------------------------------------------------------
  def item_effect_recover_mp(user, item, effect)
    value = (mmp * effect.value1 + effect.value2) * rec
    value *= user.pha if item.is_a?(RPG::Item)
    value = value.to_i
    @result.mp_damage -= value
    @result.success = true if value != 0
    self.mp += value
  end
  #--------------------------------------------------------------------------
  # * Efeito do uso [Aumentar TP]
  #     user   : usuário
  #     item   : habilidade/item
  #     effect : efeito
  #--------------------------------------------------------------------------
  def item_effect_gain_tp(user, item, effect)
    value = effect.value1.to_i
    @result.tp_damage -= value
    @result.success = true if value != 0
    self.tp += value
  end
  #--------------------------------------------------------------------------
  # * Efeito do uso [Adição de Estado]
  #     user   : usuário
  #     item   : habilidade/item
  #     effect : efeito
  #--------------------------------------------------------------------------
  def item_effect_add_state(user, item, effect)
    if effect.data_id == 0
      item_effect_add_state_attack(user, item, effect)
    else
      item_effect_add_state_normal(user, item, effect)
    end
  end
  #--------------------------------------------------------------------------
  # * Efeito do uso [Adição de Estado]:Ataques normais
  #     user   : usuário
  #     item   : habilidade/item
  #     effect : efeito
  #--------------------------------------------------------------------------
  def item_effect_add_state_attack(user, item, effect)
    user.atk_states.each do |state_id|
      chance = effect.value1
      chance *= state_rate(state_id)
      chance *= user.atk_states_rate(state_id)
      chance *= luk_effect_rate(user)
      if rand < chance
        add_state(state_id)
        @result.success = true
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Efeito do uso [Adição de Estado]:normal
  #     user   : usuário
  #     item   : habilidade/item
  #     effect : efeito
  #--------------------------------------------------------------------------
  def item_effect_add_state_normal(user, item, effect)
    chance = effect.value1
    chance *= state_rate(effect.data_id) if opposite?(user)
    chance *= luk_effect_rate(user)      if opposite?(user)
    if rand < chance
      add_state(effect.data_id)
      @result.success = true
    end
  end
  #--------------------------------------------------------------------------
  # * Efeito do uso [Remoção de Estado]
  #     user   : usuário
  #     item   : habilidade/item
  #     effect : efeito
  #--------------------------------------------------------------------------
  def item_effect_remove_state(user, item, effect)
    chance = effect.value1
    if rand < chance
      remove_state(effect.data_id)
      @result.success = true
    end
  end
  #--------------------------------------------------------------------------
  # * Efeito do uso [Adição de Fortalecimento]
  #     user   : usuário
  #     item   : habilidade/item
  #     effect : efeito
  #--------------------------------------------------------------------------
  def item_effect_add_buff(user, item, effect)
    add_buff(effect.data_id, effect.value1)
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # * Efeito do uso [Adição de Enfraquecimento]
  #     user   : usuário
  #     item   : habilidade/item
  #     effect : efeito
  #--------------------------------------------------------------------------
  def item_effect_add_debuff(user, item, effect)
    chance = debuff_rate(effect.data_id) * luk_effect_rate(user)
    if rand < chance
      add_debuff(effect.data_id, effect.value1)
      @result.success = true
    end
  end
  #--------------------------------------------------------------------------
  # * Efeito do uso [Remoção de Fortalecimento]
  #     user   : usuário
  #     item   : habilidade/item
  #     effect : efeito
  #--------------------------------------------------------------------------
  def item_effect_remove_buff(user, item, effect)
    remove_buff(effect.data_id) if @buffs[effect.data_id] > 0
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # * Efeito do uso [Remoção de Enfraquecimento]
  #     user   : usuário
  #     item   : habilidade/item
  #     effect : efeito
  #--------------------------------------------------------------------------
  def item_effect_remove_debuff(user, item, effect)
    remove_buff(effect.data_id) if @buffs[effect.data_id] < 0
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # * Efeito do uso [Efeitos Especiais]
  #     user   : usuário
  #     item   : habilidade/item
  #     effect : efeito
  #--------------------------------------------------------------------------
  def item_effect_special(user, item, effect)
    case effect.data_id
    when SPECIAL_EFFECT_ESCAPE
      escape
    end
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # * Efeito do uso [Crescimento]
  #     user   : usuário
  #     item   : habilidade/item
  #     effect : efeito
  #--------------------------------------------------------------------------
  def item_effect_grow(user, item, effect)
    add_param(effect.data_id, effect.value1.to_i)
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # * Efeito do uso [Aprender Habilidade]
  #     user   : usuário
  #     item   : habilidade/item
  #     effect : efeito
  #--------------------------------------------------------------------------
  def item_effect_learn_skill(user, item, effect)
    learn_skill(effect.data_id) if actor?
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # * Efeito do uso [Evento Comun]
  #     user   : usuário
  #     item   : habilidade/item
  #     effect : efeito
  #--------------------------------------------------------------------------
  def item_effect_common_event(user, item, effect)
  end
  #--------------------------------------------------------------------------
  # * Efeitos colaterais de uso de habilidades/itens
  #     user   : usuário
  #     item   : habilidade/item
  #--------------------------------------------------------------------------
  def item_user_effect(user, item)
    user.tp += item.tp_gain * user.tcr
  end
  #--------------------------------------------------------------------------
  # * Definição de taxa de mudança por sorte
  #     user   : usuário  
  #--------------------------------------------------------------------------
  def luk_effect_rate(user)
    [1.0 + (user.luk - luk) * 0.001, 0.0].max
  end
  #--------------------------------------------------------------------------
  # * Definição de ação contra alvo inimigo
  #     battler : lutador
  #--------------------------------------------------------------------------
  def opposite?(battler)
    actor? != battler.actor?
  end
  #--------------------------------------------------------------------------
  # * Efeito do dano no mapa
  #--------------------------------------------------------------------------
  def perform_map_damage_effect
  end
  #--------------------------------------------------------------------------
  # * TP Inicial
  #--------------------------------------------------------------------------
  def init_tp
    self.tp = rand * 25
  end
  #--------------------------------------------------------------------------
  # * Limpeza do TP
  #--------------------------------------------------------------------------
  def clear_tp
    self.tp = 0
  end
  #--------------------------------------------------------------------------
  # * Carregamento do TP por dano
  #     damage_rate : taxa de dano
  #--------------------------------------------------------------------------
  def charge_tp_by_damage(damage_rate)
    self.tp += 50 * damage_rate * tcr
  end
=begin
  #--------------------------------------------------------------------------
  # * Regenear HP
  #--------------------------------------------------------------------------
  def regenerate_hp
    damage = -(mhp * hrg).to_i
    perform_map_damage_effect if $game_party.in_battle && damage > 0
    @result.hp_damage = [damage, max_slip_damage].min
    self.hp -= @result.hp_damage
  end
  #--------------------------------------------------------------------------
  # * Aquisição do valor máximo de danos contínuos
  #--------------------------------------------------------------------------
  def max_slip_damage
    $data_system.opt_slip_death ? hp : [hp - 1, 0].max
  end
  #--------------------------------------------------------------------------
  # * Regenear MP
  #--------------------------------------------------------------------------
  def regenerate_mp
    @result.mp_damage = -(mmp * mrg).to_i
    self.mp -= @result.mp_damage
  end
  #--------------------------------------------------------------------------
  # * Regenear TP
  #--------------------------------------------------------------------------
  def regenerate_tp
    self.tp += 100 * trg
  end
  #--------------------------------------------------------------------------
  # * Regenear tudo
  #--------------------------------------------------------------------------
  def regenerate_all
    if alive?
      regenerate_hp
      regenerate_mp
      regenerate_tp
    end
  end
=end
  #--------------------------------------------------------------------------
  # * Execução do inicio de batalha
  #--------------------------------------------------------------------------
  def on_battle_start
    init_tp unless preserve_tp?
  end
  #--------------------------------------------------------------------------
  # * Execução do fim da ação
  #--------------------------------------------------------------------------
  def on_action_end
    @result.clear
    remove_states_auto(1)
    remove_buffs_auto
  end
  #--------------------------------------------------------------------------
  # * Execução do fim do turno
  #--------------------------------------------------------------------------
  def on_turn_end
    @result.clear
    # VXA-OS
    #regenerate_all
    update_state_turns
    update_buff_turns
    remove_states_auto(2)
  end
  #--------------------------------------------------------------------------
  # * Execução do fim de batalha
  #--------------------------------------------------------------------------
  def on_battle_end
    @result.clear
    remove_battle_states
    remove_all_buffs
    clear_actions
    clear_tp unless preserve_tp?
    appear
  end
  #--------------------------------------------------------------------------
  # * Execução do dano
  #     value : valor
  #--------------------------------------------------------------------------
  def on_damage(value)
    remove_states_by_damage
    charge_tp_by_damage(value.to_f / mhp)
  end
end
