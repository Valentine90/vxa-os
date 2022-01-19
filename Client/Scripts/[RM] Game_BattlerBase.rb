#==============================================================================
# ** Game_BattlerBase
#------------------------------------------------------------------------------
#  Esta classe gerencia os battlers. Contém os principais método de
# cálculo da características especiais.
# Esta classe é usada como superclasse da classe Game_Battler.
#==============================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Constantes (Características)
  #--------------------------------------------------------------------------
  FEATURE_ELEMENT_RATE  = 11              # Eficácia Elemental
  FEATURE_DEBUFF_RATE   = 12              # Eficácia dos Enfraquecimentos
  FEATURE_STATE_RATE    = 13              # Eficácia dos Estados
  FEATURE_STATE_RESIST  = 14              # Resistência a Estados
  FEATURE_PARAM         = 21              # Parametros Adicionais
  FEATURE_XPARAM        = 22              # Parametros Especiais
  FEATURE_SPARAM        = 23              # Habilidades Especiais
  FEATURE_ATK_ELEMENT   = 31              # Ataque Elemental
  FEATURE_ATK_STATE     = 32              # Estados Adicionais
  FEATURE_ATK_SPEED     = 33              # Velocidade de Ataque
  FEATURE_ATK_TIMES     = 34              # Numero de Ataques
  FEATURE_STYPE_ADD     = 41              # Tipo de Habilidade Adicionais
  FEATURE_STYPE_SEAL    = 42              # Tipo de Habilidades Seladas
  FEATURE_SKILL_ADD     = 43              # Habilidades Adicionais
  FEATURE_SKILL_SEAL    = 44              # Habilidades Seladas
  FEATURE_EQUIP_WTYPE   = 51              # Tipos de Armas
  FEATURE_EQUIP_ATYPE   = 52              # Tipos de Armaduras
  FEATURE_EQUIP_FIX     = 53              # Equipamentos Fixos
  FEATURE_EQUIP_SEAL    = 54              # Equipamentos Selados
  FEATURE_SLOT_TYPE     = 55              # Tipo de Slot
  FEATURE_ACTION_PLUS   = 61              # Número de Ações Adicionais
  FEATURE_SPECIAL_FLAG  = 62              # Flaf Especial
  FEATURE_COLLAPSE_TYPE = 63              # Tipo de Colapso
  FEATURE_PARTY_ABILITY = 64              # Habilidade de grupo
  #--------------------------------------------------------------------------
  # * Constantes (flag especial)
  #--------------------------------------------------------------------------
  FLAG_ID_AUTO_BATTLE   = 0               # Batalha automática
  FLAG_ID_GUARD         = 1               # Defesa
  FLAG_ID_SUBSTITUTE    = 2               # Substituto
  FLAG_ID_PRESERVE_TP   = 3               # Preservar TP
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :hp                       # HP
  attr_reader   :mp                       # MP
  attr_reader   :tp                       # TP
  #--------------------------------------------------------------------------
  # * Aquisição dos parametros
  #--------------------------------------------------------------------------
  def mhp;  param(0);   end    # HP Máximo
  def mmp;  param(1);   end    # MP Máximo
  def atk;  param(2);   end    # Ataque
  def def;  param(3);   end    # Defesa
  def mat;  param(4);   end    # Inteligência
  def mdf;  param(5);   end    # Resistência
  def agi;  param(6);   end    # Agilidade
  def luk;  param(7);   end    # Sorte
  def hit;  xparam(0);  end    # Precisão
  def eva;  xparam(1);  end    # Esquiva
  def cri;  xparam(2);  end    # Crítico
  def cev;  xparam(3);  end    # Esquiva Crítica
  def mev;  xparam(4);  end    # Esquiva Mágica
  def mrf;  xparam(5);  end    # Reflexão
  def cnt;  xparam(6);  end    # Contra Ataque
  def hrg;  xparam(7);  end    # Regeneração de HP
  def mrg;  xparam(8);  end    # Regeneração de SP
  def trg;  xparam(9);  end    # Regeneração de TP
  def tgr;  sparam(0);  end    # Taxa de Alvo
  def grd;  sparam(1);  end    # Taxa de Defesa
  def rec;  sparam(2);  end    # Taxa de Recuperação
  def pha;  sparam(3);  end    # Farmacologia
  def mcr;  sparam(4);  end    # Taxa de Custo de MP
  def tcr;  sparam(5);  end    # Taxa de Carregamento do TP
  def pdr;  sparam(6);  end    # Taxa de Dano Fídico
  def mdr;  sparam(7);  end    # Taxa de Dano Mágico
  def fdr;  sparam(8);  end    # Taxa de Dano por Terreno
  def exr;  sparam(9);  end    # Taxa de Experiência
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #--------------------------------------------------------------------------
  def initialize
    @hp = @mp = @tp = 0
    @hidden = false
    clear_param_plus
    clear_states
    clear_buffs
  end
  #--------------------------------------------------------------------------
  # * Limpeza dos adicionais dos parametros
  #--------------------------------------------------------------------------
  def clear_param_plus
    @param_plus = [0] * 8
  end
  #--------------------------------------------------------------------------
  # * Limpeza dos estados
  #--------------------------------------------------------------------------
  def clear_states
    @states = []
    @state_turns = {}
    @state_steps = {}
  end
  #--------------------------------------------------------------------------
  # * Remoção de estado
  #--------------------------------------------------------------------------
  def erase_state(state_id)
    @states.delete(state_id)
    @state_turns.delete(state_id)
    @state_steps.delete(state_id)
  end
  #--------------------------------------------------------------------------
  # * Limpeza dos fortalecimentos
  #--------------------------------------------------------------------------
  def clear_buffs
    @buffs = Array.new(8) { 0 }
    @buff_turns = {}
  end
  #--------------------------------------------------------------------------
  # * Definição do estado
  #     state_id : ID do estado
  #--------------------------------------------------------------------------
  def state?(state_id)
    @states.include?(state_id)
  end
  #--------------------------------------------------------------------------
  # * Definição do estado incapacitado
  #--------------------------------------------------------------------------
  def death_state?
    state?(death_state_id)
  end
  #--------------------------------------------------------------------------
  # * Aquisição da ID do stado incapacitado
  #--------------------------------------------------------------------------
  def death_state_id
    return 1
  end
  #--------------------------------------------------------------------------
  # * Aquisição da lista de estados
  #--------------------------------------------------------------------------
  def states
    @states.collect {|id| $data_states[id] }
  end
  #--------------------------------------------------------------------------
  # * Aquisição da lista de icones de estados
  #--------------------------------------------------------------------------
  def state_icons
    icons = states.collect {|state| state.icon_index }
    icons.delete(0)
    icons
  end
  #--------------------------------------------------------------------------
  # * Aquisição da lista de icones de fortalecimento/enfraquecimento
  #--------------------------------------------------------------------------
  def buff_icons
    icons = []
    @buffs.each_with_index {|lv, i| icons.push(buff_icon_index(lv, i)) }
    icons.delete(0)
    icons
  end
  #--------------------------------------------------------------------------
  # * Aquisição do índice de ícones de fortalecimento/enfraquecimento
  #     buff_level : Nível do fortalecimento
  #     param_id   : ID do parâmetro
  #--------------------------------------------------------------------------
  def buff_icon_index(buff_level, param_id)
    if buff_level > 0
      return ICON_BUFF_START + (buff_level - 1) * 8 + param_id
    elsif buff_level < 0
      return ICON_DEBUFF_START + (-buff_level - 1) * 8 + param_id 
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # * Aquisição da lista com todos estados
  #--------------------------------------------------------------------------
  def feature_objects
    states
  end
  #--------------------------------------------------------------------------
  # * Aquisição de todas caracteristicas do objeto
  #--------------------------------------------------------------------------
  def all_features
    feature_objects.inject([]) {|r, obj| r + obj.features }
  end
  #--------------------------------------------------------------------------
  # * Aquisição da lista de objetos (Limitado pelo código)
  #     code : código
  #--------------------------------------------------------------------------
  def features(code)
    all_features.select {|ft| ft.code == code }
  end
  #--------------------------------------------------------------------------
  # * Aquisição da lista de objetos (Limitado pelo código e ID)
  #     code : código
  #     id   : ID da característica
  #--------------------------------------------------------------------------
  def features_with_id(code, id)
    all_features.select {|ft| ft.code == code && ft.data_id == id }
  end
  #--------------------------------------------------------------------------
  # * Cálculo do valor total da característica 
  #     code : código
  #     id   : ID da característica
  #--------------------------------------------------------------------------
  def features_pi(code, id)
    features_with_id(code, id).inject(1.0) {|r, ft| r *= ft.value }
  end
  #--------------------------------------------------------------------------
  # * Somatório das características (ID específica)
  #     code : código
  #     id   : ID da característica
  #--------------------------------------------------------------------------
  def features_sum(code, id)
    features_with_id(code, id).inject(0.0) {|r, ft| r += ft.value }
  end
  #--------------------------------------------------------------------------
  # * Somatório das características (ID não específica)
  #     code : código
  #--------------------------------------------------------------------------
  def features_sum_all(code)
    features(code).inject(0.0) {|r, ft| r += ft.value }
  end
  #--------------------------------------------------------------------------
  # * Cálculo de um conjunto de características
  #     code : código
  #--------------------------------------------------------------------------
  def features_set(code)
    features(code).inject([]) {|r, ft| r |= [ft.data_id] }
  end
  #--------------------------------------------------------------------------
  # * Aquisição do valor base do parâmetro
  #     param_id : ID do parâmetro
  #--------------------------------------------------------------------------
  def param_base(param_id)
    return 0
  end
  #--------------------------------------------------------------------------
  # * Aquisição do valor adicional do parâmetro
  #     param_id : ID do parâmetro
  #--------------------------------------------------------------------------
  def param_plus(param_id)
    @param_plus[param_id]
  end
  #--------------------------------------------------------------------------
  # * Aquisição do valor mínimo do parâmetro
  #     param_id : ID do parâmetro
  #--------------------------------------------------------------------------
  def param_min(param_id)
    return 0 if param_id == 1  # MMP
    return 1
  end
  #--------------------------------------------------------------------------
  # * Aquisição do valor máximo do parâmetro
  #     param_id : ID do parâmetro
  #--------------------------------------------------------------------------
  def param_max(param_id)
    return 999999 if param_id == 0  # MHP
    return 9999   if param_id == 1  # MMP
    return 999
  end
  #--------------------------------------------------------------------------
  # * Aquisição da taxa de variação do parâmetro
  #     param_id : ID do parâmetro
  #--------------------------------------------------------------------------
  def param_rate(param_id)
    features_pi(FEATURE_PARAM, param_id)
  end
  #--------------------------------------------------------------------------
  # * Aquisição da taxa de variação por fortalecimento/enfraquecimento
  #     param_id : ID do parâmetro
  #--------------------------------------------------------------------------
  def param_buff_rate(param_id)
    @buffs[param_id] * 0.25 + 1.0
  end
  #--------------------------------------------------------------------------
  # * Aquisição do parâmetro base
  #     param_id : ID do parâmetro
  #--------------------------------------------------------------------------
  def param(param_id)
    value = param_base(param_id) + param_plus(param_id)
    value *= param_rate(param_id) * param_buff_rate(param_id)
    [[value, param_max(param_id)].min, param_min(param_id)].max.to_i
  end
  #--------------------------------------------------------------------------
  # * Aquisição do parâmetro especial
  #     xparam_id : ID do parâmetro
  #--------------------------------------------------------------------------
  def xparam(xparam_id)
    features_sum(FEATURE_XPARAM, xparam_id)
  end
  #--------------------------------------------------------------------------
  # * Aquisição do atributo especial
  #     sparam_id : ID do parâmetro
  #--------------------------------------------------------------------------
  def sparam(sparam_id)
    features_pi(FEATURE_SPARAM, sparam_id)
  end
  #--------------------------------------------------------------------------
  # * Valor de eficácia dos elementos
  #     element_id : ID do elemento
  #--------------------------------------------------------------------------
  def element_rate(element_id)
    features_pi(FEATURE_ELEMENT_RATE, element_id)
  end
  #--------------------------------------------------------------------------
  # * Valor de eficácia dos enfraquecimentos
  #     param_id : ID do parâmetro
  #--------------------------------------------------------------------------
  def debuff_rate(param_id)
    features_pi(FEATURE_DEBUFF_RATE, param_id)
  end
  #--------------------------------------------------------------------------
  # * Valor de eficácia dos estados
  #     element_id : ID do elemento
  #--------------------------------------------------------------------------
  def state_rate(state_id)
    features_pi(FEATURE_STATE_RATE, state_id)
  end
  #--------------------------------------------------------------------------
  # * Lista de resistência a estados
  #--------------------------------------------------------------------------
  def state_resist_set
    features_set(FEATURE_STATE_RESIST)
  end
  #--------------------------------------------------------------------------
  # * Definição de resistência a estados
  #     state_id : ID do estado
  #--------------------------------------------------------------------------
  def state_resist?(state_id)
    state_resist_set.include?(state_id)
  end
  #--------------------------------------------------------------------------
  # * Lista de elementos do ataque
  #--------------------------------------------------------------------------
  def atk_elements
    features_set(FEATURE_ATK_ELEMENT)
  end
  #--------------------------------------------------------------------------
  # * Lista de estados do ataque
  #--------------------------------------------------------------------------
  def atk_states
    features_set(FEATURE_ATK_STATE)
  end
  #--------------------------------------------------------------------------
  # * Aquisição da taxa de sucesso do estado do ataque
  #     state_id : ID do estado
  #--------------------------------------------------------------------------
  def atk_states_rate(state_id)
    features_sum(FEATURE_ATK_STATE, state_id)
  end
  #--------------------------------------------------------------------------
  # * Aquisição da velocidade do ataque
  #--------------------------------------------------------------------------
  def atk_speed
    features_sum_all(FEATURE_ATK_SPEED)
  end
  #--------------------------------------------------------------------------
  # * Aquisição do número de ataques adicionais
  #--------------------------------------------------------------------------
  def atk_times_add
    [features_sum_all(FEATURE_ATK_TIMES), 0].max
  end
  #--------------------------------------------------------------------------
  # * Aquisição dos tipos adicionais de habilidades
  #--------------------------------------------------------------------------
  def added_skill_types
    features_set(FEATURE_STYPE_ADD)
  end
  #--------------------------------------------------------------------------
  # * Definição de selo de tipo de habilidade
  #     stype_id : ID do tipo de habilidade
  #--------------------------------------------------------------------------
  def skill_type_sealed?(stype_id)
    features_set(FEATURE_STYPE_SEAL).include?(stype_id)
  end
  #--------------------------------------------------------------------------
  # * Aquisição das habilidades adicionais
  #--------------------------------------------------------------------------
  def added_skills
    features_set(FEATURE_SKILL_ADD)
  end
  #--------------------------------------------------------------------------
  # * Definição de habilidades seladas
  #     skill_id : ID da habilidade
  #--------------------------------------------------------------------------
  def skill_sealed?(skill_id)
    features_set(FEATURE_SKILL_SEAL).include?(skill_id)
  end
  #--------------------------------------------------------------------------
  # * Definição de tipos de armas equipáveis
  #     wtype_id : ID do tipo de arma
  #--------------------------------------------------------------------------
  def equip_wtype_ok?(wtype_id)
    features_set(FEATURE_EQUIP_WTYPE).include?(wtype_id)
  end
  #--------------------------------------------------------------------------
  # * Definição de tipos de armaduras equipáveis
  #     atype_id : ID do tipo de armadura
  #--------------------------------------------------------------------------
  def equip_atype_ok?(atype_id)
    features_set(FEATURE_EQUIP_ATYPE).include?(atype_id)
  end
  #--------------------------------------------------------------------------
  # * Definição de tipos de equipamento fixo
  #     etype_id : ID do tipo de equipamento
  #--------------------------------------------------------------------------
  def equip_type_fixed?(etype_id)
    features_set(FEATURE_EQUIP_FIX).include?(etype_id)
  end
  #--------------------------------------------------------------------------
  # * Definição de tipos de equipamentos selados
  #     etype_id : ID do tipo de equipamento
  #--------------------------------------------------------------------------
  def equip_type_sealed?(etype_id)
    features_set(FEATURE_EQUIP_SEAL).include?(etype_id)
  end
  #--------------------------------------------------------------------------
  # * Aquisição dos tipos de slot
  #--------------------------------------------------------------------------
  def slot_type
    features_set(FEATURE_SLOT_TYPE).max || 0
  end
  #--------------------------------------------------------------------------
  # * Definição de uso de duas armas
  #--------------------------------------------------------------------------
  def dual_wield?
    slot_type == 1
  end
  #--------------------------------------------------------------------------
  # * Aquisição da lista de numeros adicionais de ação
  #--------------------------------------------------------------------------
  def action_plus_set
    features(FEATURE_ACTION_PLUS).collect {|ft| ft.value }
  end
  #--------------------------------------------------------------------------
  # * Definição de flag especial
  #--------------------------------------------------------------------------
  def special_flag(flag_id)
    features(FEATURE_SPECIAL_FLAG).any? {|ft| ft.data_id == flag_id }
  end
  #--------------------------------------------------------------------------
  # * Aquisição do efeito de colapso
  #--------------------------------------------------------------------------
  def collapse_type
    features_set(FEATURE_COLLAPSE_TYPE).max || 0
  end
  #--------------------------------------------------------------------------
  # * Aquisição das habilidades do grupo
  #    ability_id : ID da habilidade
  #--------------------------------------------------------------------------
  def party_ability(ability_id)
    features(FEATURE_PARTY_ABILITY).any? {|ft| ft.data_id == ability_id }
  end
  #--------------------------------------------------------------------------
  # * Definição de batalha automática
  #--------------------------------------------------------------------------
  def auto_battle?
    special_flag(FLAG_ID_AUTO_BATTLE)
  end
  #--------------------------------------------------------------------------
  # * Definição de defesa
  #--------------------------------------------------------------------------
  def guard?
    special_flag(FLAG_ID_GUARD) && movable?
  end
  #--------------------------------------------------------------------------
  # * Definição de substituto
  #--------------------------------------------------------------------------
  def substitute?
    special_flag(FLAG_ID_SUBSTITUTE) && movable?
  end
  #--------------------------------------------------------------------------
  # * Definição de preservação de TP
  #--------------------------------------------------------------------------
  def preserve_tp?
    special_flag(FLAG_ID_PRESERVE_TP)
  end
  #--------------------------------------------------------------------------
  # * Adição de parâmetros
  #     param_id : ID do parâmetro
  #     value    : valor adicional
  #--------------------------------------------------------------------------
  def add_param(param_id, value)
    @param_plus[param_id] += value
    refresh
  end
  #--------------------------------------------------------------------------
  # * Mudança de HP
  #     hp : modificador
  #--------------------------------------------------------------------------
  def hp=(hp)
    @hp = hp
    refresh
  end
  #--------------------------------------------------------------------------
  # * Mudança de MP
  #     mp : modificador
  #--------------------------------------------------------------------------
  def mp=(mp)
    @mp = mp
    refresh
  end
  #--------------------------------------------------------------------------
  # * Mudança de HP (para eventos)
  #     value        : modificador
  #     enable_death : permitir incapacitação
  #--------------------------------------------------------------------------
  def change_hp(value, enable_death)
    if !enable_death && @hp + value <= 0
      self.hp = 1
    else
      self.hp += value
    end
  end
  #--------------------------------------------------------------------------
  # * Mudança de TP
  #     tp : modificador
  #--------------------------------------------------------------------------
  def tp=(tp)
    @tp = [[tp, max_tp].min, 0].max
  end
  #--------------------------------------------------------------------------
  # * Aquisição do TP Máximo
  #--------------------------------------------------------------------------
  def max_tp
    return 100
  end
  #--------------------------------------------------------------------------
  # * Renovação
  #--------------------------------------------------------------------------
  def refresh
    state_resist_set.each {|state_id| erase_state(state_id) }
    @hp = [[@hp, mhp].min, 0].max
    @mp = [[@mp, mmp].min, 0].max
    @hp == 0 ? add_state(death_state_id) : remove_state(death_state_id)
  end
  #--------------------------------------------------------------------------
  # * Recuperação completa
  #--------------------------------------------------------------------------
  def recover_all
    clear_states
    @hp = mhp
    @mp = mmp
  end
  #--------------------------------------------------------------------------
  # * Aquisição do percentual de HP
  #--------------------------------------------------------------------------
  def hp_rate
    @hp.to_f / mhp
  end
  #--------------------------------------------------------------------------
  # * Aquisição do percentual de MP
  #--------------------------------------------------------------------------
  def mp_rate
    mmp > 0 ? @mp.to_f / mmp : 0
  end
  #--------------------------------------------------------------------------
  # * Aquisição do percentual de TP
  #--------------------------------------------------------------------------
  def tp_rate
    @tp.to_f / 100
  end
  #--------------------------------------------------------------------------
  # * Esconder
  #--------------------------------------------------------------------------
  def hide
    @hidden = true
  end
  #--------------------------------------------------------------------------
  # * Aparecer
  #--------------------------------------------------------------------------
  def appear
    @hidden = false
  end
  #--------------------------------------------------------------------------
  # * Definição de estado oculto
  #--------------------------------------------------------------------------
  def hidden?
    @hidden
  end
  #--------------------------------------------------------------------------
  # * Definição de presença
  #--------------------------------------------------------------------------
  def exist?
    !hidden?
  end
  #--------------------------------------------------------------------------
  # * Definição de incapacitação
  #--------------------------------------------------------------------------
  def dead?
    exist? && death_state?
  end
  #--------------------------------------------------------------------------
  # * Definição de sobrevivência
  #--------------------------------------------------------------------------
  def alive?
    exist? && !death_state?
  end
  #--------------------------------------------------------------------------
  # * Definição de nenhuma restrição
  #--------------------------------------------------------------------------
  def normal?
    exist? && restriction == 0
  end
  #--------------------------------------------------------------------------
  # * Definição de entrar comandos
  #--------------------------------------------------------------------------
  def inputable?
    normal? && !auto_battle?
  end
  #--------------------------------------------------------------------------
  # * Definição de permissão de ação
  #--------------------------------------------------------------------------
  def movable?
    exist? && restriction < 4
  end
  #--------------------------------------------------------------------------
  # * Definição de confusão
  #--------------------------------------------------------------------------
  def confusion?
    exist? && restriction >= 1 && restriction <= 3
  end
  #--------------------------------------------------------------------------
  # * Definição de nível de confusão
  #--------------------------------------------------------------------------
  def confusion_level
    confusion? ? restriction : 0
  end
  #--------------------------------------------------------------------------
  # * Definição de herói
  #--------------------------------------------------------------------------
  def actor?
    return false
  end
  #--------------------------------------------------------------------------
  # * Definição de inimigo
  #--------------------------------------------------------------------------
  def enemy?
    return false
  end
  #--------------------------------------------------------------------------
  # * Organizar estados
  #    Lista classifica os estados em ordem decrecente de prioridade
  #--------------------------------------------------------------------------
  def sort_states
    @states = @states.sort_by {|id| [-$data_states[id].priority, id] }
  end
  #--------------------------------------------------------------------------
  # * Aquisição do maior nível de restrição
  #--------------------------------------------------------------------------
  def restriction
    states.collect {|state| state.restriction }.push(0).max
  end
  #--------------------------------------------------------------------------
  # * Aquisição da mensagem mais importante de permanencia de estado
  #--------------------------------------------------------------------------
  def most_important_state_text
    states.each {|state| return state.message3 unless state.message3.empty? }
    return ""
  end
  #--------------------------------------------------------------------------
  # * Definição de necessidade de arma para habilidade
  #     skill : habilidade
  #--------------------------------------------------------------------------
  def skill_wtype_ok?(skill)
    return true
  end
  #--------------------------------------------------------------------------
  # * Cálculo de custo de MP de habilidades
  #     skill : habilidade
  #--------------------------------------------------------------------------
  def skill_mp_cost(skill)
    (skill.mp_cost * mcr).to_i
  end
  #--------------------------------------------------------------------------
  # * Cálculo de custo de TP de habilidades
  #     skill : habilidade
  #--------------------------------------------------------------------------
  def skill_tp_cost(skill)
    skill.tp_cost
  end
  #--------------------------------------------------------------------------
  # * Definição de pagamento dos custos da habilidade
  #     skill : habilidade
  #--------------------------------------------------------------------------
  def skill_cost_payable?(skill)
    tp >= skill_tp_cost(skill) && mp >= skill_mp_cost(skill)
  end
  #--------------------------------------------------------------------------
  # * Pagar custos da habilidade
  #     skill : habilidade
  #--------------------------------------------------------------------------
  def pay_skill_cost(skill)
    self.mp -= skill_mp_cost(skill)
    self.tp -= skill_tp_cost(skill)
  end
  #--------------------------------------------------------------------------
  # * Definição de disponibilidade de uso de habilidades/itens
  #    item : habilidade/item
  #--------------------------------------------------------------------------
  def occasion_ok?(item)
    $game_party.in_battle ? item.battle_ok? : item.menu_ok?
  end
  #--------------------------------------------------------------------------
  # * Definição de condições de uso de habilidades/itens
  #    item : habilidade/item
  #--------------------------------------------------------------------------
  def usable_item_conditions_met?(item)
    movable? && occasion_ok?(item)
  end
  #--------------------------------------------------------------------------
  # * Definição de condições de uso de habilidades
  #     skill : habilidade
  #--------------------------------------------------------------------------
  def skill_conditions_met?(skill)
    usable_item_conditions_met?(skill) &&
    skill_wtype_ok?(skill) && skill_cost_payable?(skill) &&
    !skill_sealed?(skill.id) && !skill_type_sealed?(skill.stype_id)
  end
  #--------------------------------------------------------------------------
  # * Definição de condições de uso de itens
  #    item : item
  #--------------------------------------------------------------------------
  def item_conditions_met?(item)
    usable_item_conditions_met?(item) && $game_party.has_item?(item)
  end
  #--------------------------------------------------------------------------
  # * Definição de permissão de uso de habilidades/itens
  #    item : habilidade/item
  #--------------------------------------------------------------------------
  def usable?(item)
    return skill_conditions_met?(item) if item.is_a?(RPG::Skill)
    return item_conditions_met?(item)  if item.is_a?(RPG::Item)
    return false
  end
  #--------------------------------------------------------------------------
  # * Definição de possibilidade de equipar item.
  #     item : equipamento
  #--------------------------------------------------------------------------
  def equippable?(item)
    return false unless item.is_a?(RPG::EquipItem)
    return false if equip_type_sealed?(item.etype_id)
    return equip_wtype_ok?(item.wtype_id) if item.is_a?(RPG::Weapon)
    return equip_atype_ok?(item.atype_id) if item.is_a?(RPG::Armor)
    return false
  end
  #--------------------------------------------------------------------------
  # * Aquisição da ID da habilidade para ataques normais
  #--------------------------------------------------------------------------
  def attack_skill_id
    return 1
  end
  #--------------------------------------------------------------------------
  # * Aquisição da ID da habilidade para defesa
  #--------------------------------------------------------------------------
  def guard_skill_id
    return 2
  end
  #--------------------------------------------------------------------------
  # * Definição de uso ataques normais
  #--------------------------------------------------------------------------
  def attack_usable?
    usable?($data_skills[attack_skill_id])
  end
  #--------------------------------------------------------------------------
  # * Definição de uso de defesa
  #--------------------------------------------------------------------------
  def guard_usable?
    usable?($data_skills[guard_skill_id])
  end
end
