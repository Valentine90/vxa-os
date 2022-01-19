#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  Esta classe gerencia os heróis. Ela é utilizada internamente pela classe
# Game_Actors ($game_actors). A instância desta classe é referenciada
# pela classe Game_Party ($game_party).
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_accessor :name                     # Nome
  attr_accessor :nickname                 # Segundo nome (apelido)
  attr_reader   :character_name           # Nome do arquivo gráfico
  attr_reader   :character_index          # Índice do arquivo gráfico
  attr_reader   :face_name                # Nome da gráfico da face
  attr_reader   :face_index               # Índice do gráfico da face
  attr_reader   :class_id                 # ID da classe
  attr_reader   :level                    # Nível
  attr_reader   :action_input_index       # Índice de entrada da ação
  attr_reader   :last_skill               # Memória do cursor : habilidade
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #     actor_id : ID do herói
  #--------------------------------------------------------------------------
  def initialize(actor_id)
    super()
    setup(actor_id)
    @last_skill = Game_BaseItem.new
  end
  #--------------------------------------------------------------------------
  # * Configuração inicial
  #     actor_id : ID do herói
  #--------------------------------------------------------------------------
  def setup(actor_id)
    @actor_id = actor_id
    @name = actor.name
    @nickname = actor.nickname
    init_graphics
    @class_id = actor.class_id
    @level = actor.initial_level
    @exp = {}
    @equips = []
    # VXA-OS
    init_basic
    init_exp
    init_skills
    init_equips#(actor.equips)
    clear_param_plus
    recover_all
  end
  #--------------------------------------------------------------------------
  # * Aquisição do informações do herói
  #--------------------------------------------------------------------------
  def actor
    $data_actors[@actor_id]
  end
  #--------------------------------------------------------------------------
  # * Inicialização dos gráficos do herói
  #--------------------------------------------------------------------------
  def init_graphics
    @character_name = actor.character_name
    @character_index = actor.character_index
    @face_name = actor.face_name
    @face_index = actor.face_index
  end
  #--------------------------------------------------------------------------
  # * Aquisição da experiência total necessária para subir de nível
  #     level : Nível
  #--------------------------------------------------------------------------
  def exp_for_level(level)
    self.class.exp_for_level(level)
  end
  #--------------------------------------------------------------------------
  # * Inicialização da experiência
  #--------------------------------------------------------------------------
  def init_exp
    @exp[@class_id] = current_level_exp
  end
  #--------------------------------------------------------------------------
  # * Aquisição da experiência
  #--------------------------------------------------------------------------
  def exp
    @exp[@class_id]
  end
  #--------------------------------------------------------------------------
  # * Aquisição do valor de experiência do nível atual
  #--------------------------------------------------------------------------
  def current_level_exp
    exp_for_level(@level)
  end
  #--------------------------------------------------------------------------
  # * Aquisição da experiência para próximo nível
  #--------------------------------------------------------------------------
  def next_level_exp
    exp_for_level(@level + 1)
  end
  #--------------------------------------------------------------------------
  # * Aquisição do nível máximo
  #--------------------------------------------------------------------------
  def max_level
    actor.max_level
  end
  #--------------------------------------------------------------------------
  # * Definição de nível máximo
  #--------------------------------------------------------------------------
  def max_level?
    @level >= max_level
  end
  #--------------------------------------------------------------------------
  # * Inicialização das habilidades
  #--------------------------------------------------------------------------
  def init_skills
    @skills = []
=begin
    self.class.learnings.each do |learning|
      learn_skill(learning.skill_id) if learning.level <= @level
    end
=end
  end
  #--------------------------------------------------------------------------
  # * Inicialização do equipamento
  #     equips : equipamentos iniciais
  #--------------------------------------------------------------------------
  def init_equips#(equips)
    @equips = Array.new(equip_slots.size) { Game_BaseItem.new }
=begin
    equips.each_with_index do |item_id, i|
      etype_id = index_to_etype_id(i)
      slot_id = empty_slot(etype_id)
      @equips[slot_id].set_equip(etype_id == 0, item_id) if slot_id
    end
    refresh
=end
  end
  #--------------------------------------------------------------------------
  # * ID tipo com o índice definido pelo editor
  #     index : índice
  #--------------------------------------------------------------------------
  def index_to_etype_id(index)
    index == 1 && dual_wield? ? 0 : index
  end
  #--------------------------------------------------------------------------
  # * Definição de lista de slots pelo tipo de equipamentos
  #     etype_id : tipo de equipamento
  #--------------------------------------------------------------------------
  def slot_list(etype_id)
    result = []
    equip_slots.each_with_index {|e, i| result.push(i) if e == etype_id }
    result
  end
  #--------------------------------------------------------------------------
  # * Definição de slot de equipamento vazio
  #     etype_id : tipo de equipamento
  #--------------------------------------------------------------------------
  def empty_slot(etype_id)
    list = slot_list(etype_id)
    list.find {|i| @equips[i].is_nil? } || list[0]
  end
  #--------------------------------------------------------------------------
  # * Aquisição da lista de slots de equipamentos
  #--------------------------------------------------------------------------
  def equip_slots
    return [0,0,2,3,4] if dual_wield?       # Duas armas
    return [0,1,2,3,4]                      # Normal
  end
  #--------------------------------------------------------------------------
  # * Aquisição da lista de armas
  #--------------------------------------------------------------------------
  def weapons
    @equips.select {|item| item.is_weapon? }.collect {|item| item.object }
  end
  #--------------------------------------------------------------------------
  # * Aquisição da lista de armaduras
  #--------------------------------------------------------------------------
  def armors
    @equips.select {|item| item.is_armor? }.collect {|item| item.object }
  end
  #--------------------------------------------------------------------------
  # * Aquisição da lista de equipamentos
  #--------------------------------------------------------------------------
  def equips
    @equips.collect {|item| item.object }
  end
  #--------------------------------------------------------------------------
  # * Definição de mudança de equipamento
  #     slot_id : ID do slot
  #--------------------------------------------------------------------------
  def equip_change_ok?(slot_id)
    return false if equip_type_fixed?(equip_slots[slot_id])
    return false if equip_type_sealed?(equip_slots[slot_id])
    return true
  end
  #--------------------------------------------------------------------------
  # * Mudança de equipamentos
  #     slot_id : ID do slot
  #     item    : Armas/Amaduras (nil se vazio)
  #--------------------------------------------------------------------------
  def change_equip(slot_id, item)
    # VXA-OS
    #return unless trade_item_with_party(item, equips[slot_id])
    return if item && equip_slots[slot_id] != item.etype_id
    @equips[slot_id].object = item
    refresh
  end
  #--------------------------------------------------------------------------
  # * Forçar mudança de equipamentos
  #     slot_id : ID do slot
  #     item    : Armas/Amaduras (nil se vazio)
  #--------------------------------------------------------------------------
  def force_change_equip(slot_id, item)
    @equips[slot_id].object = item
    release_unequippable_items(false)
    refresh
  end
  #--------------------------------------------------------------------------
  # * Trocar item com membro do grupo
  #     new_item : item removido do grupo
  #     old_item : item devolvido ao grupo
  #--------------------------------------------------------------------------
  def trade_item_with_party(new_item, old_item)
    return false if new_item && !$game_party.has_item?(new_item)
    $game_party.gain_item(old_item, 1)
    $game_party.lose_item(new_item, 1)
    return true
  end
  #--------------------------------------------------------------------------
  # * Mudança de equipamentos (especificado pela ID)
  #     slot_id : ID do slot
  #     item_id : ID da Arma/Amadura
  #--------------------------------------------------------------------------
  def change_equip_by_id(slot_id, item_id)
    if equip_slots[slot_id] == 0
      change_equip(slot_id, $data_weapons[item_id])
    else
      change_equip(slot_id, $data_armors[item_id])
    end
  end
  #--------------------------------------------------------------------------
  # * Discartar equipamento
  #     item : Armas/Amaduras
  #--------------------------------------------------------------------------
  def discard_equip(item)
    slot_id = equips.index(item)
    @equips[slot_id].object = nil if slot_id
  end
  #--------------------------------------------------------------------------
  # * Remoção de equipamentos que não podem ser removidos
  #     item_gain : Voltar equipamento removido para o grupo
  #--------------------------------------------------------------------------
  def release_unequippable_items(item_gain = true)
    loop do
      last_equips = equips.dup
      @equips.each_with_index do |item, i|
        if !equippable?(item.object) || item.object.etype_id != equip_slots[i]
          trade_item_with_party(nil, item.object) if item_gain
          item.object = nil
        end
      end
      return if equips == last_equips
    end
  end
  #--------------------------------------------------------------------------
  # * Remoção de todos os equipamentos
  #--------------------------------------------------------------------------
  def clear_equipments
    equip_slots.size.times do |i|
      change_equip(i, nil) if equip_change_ok?(i)
    end
  end
  #--------------------------------------------------------------------------
  # * Equipar equipamentos mais fortes
  #--------------------------------------------------------------------------
  def optimize_equipments
    clear_equipments
    equip_slots.size.times do |i|
      next if !equip_change_ok?(i)
      items = $game_party.equip_items.select do |item|
        item.etype_id == equip_slots[i] &&
        equippable?(item) && item.performance >= 0
      end
      change_equip(i, items.max_by {|item| item.performance })
    end
  end
  #--------------------------------------------------------------------------
  # * Definição de arma necessária para uso de habilidades
  #     skill : habilidade
  #--------------------------------------------------------------------------
  def skill_wtype_ok?(skill)
    wtype_id1 = skill.required_wtype_id1
    wtype_id2 = skill.required_wtype_id2
    return true if wtype_id1 == 0 && wtype_id2 == 0
    return true if wtype_id1 > 0 && wtype_equipped?(wtype_id1)
    return true if wtype_id2 > 0 && wtype_equipped?(wtype_id2)
    return false
  end
  #--------------------------------------------------------------------------
  # * Definição de tipo de arma equipada
  #     wtype_id : ID do tipo de arma
  #--------------------------------------------------------------------------
  def wtype_equipped?(wtype_id)
    weapons.any? {|weapon| weapon.wtype_id == wtype_id }
  end
  #--------------------------------------------------------------------------
  # * Renovação
  #--------------------------------------------------------------------------
  def refresh
    # VXA-OS
    #release_unequippable_items
    super
  end
  #--------------------------------------------------------------------------
  # * Definição de herói
  #--------------------------------------------------------------------------
  def actor?
    return true
  end
  #--------------------------------------------------------------------------
  # * Unidade aliada
  #--------------------------------------------------------------------------
  def friends_unit
    $game_party
  end
=begin
  #--------------------------------------------------------------------------
  # * Unidade inimiga
  #--------------------------------------------------------------------------
  def opponents_unit
    $game_troop
  end
=end
  #--------------------------------------------------------------------------
  # * Aquisição da ID do herói
  #--------------------------------------------------------------------------
  def id
    @actor_id
  end
  #--------------------------------------------------------------------------
  # * Aquisição do índice do herói
  #--------------------------------------------------------------------------
  def index
    $game_party.members.index(self)
  end
  #--------------------------------------------------------------------------
  # * Definição de membro de batalha
  #--------------------------------------------------------------------------
  def battle_member?
    $game_party.battle_members.include?(self)
  end
  #--------------------------------------------------------------------------
  # * Classe do herói
  #--------------------------------------------------------------------------
  def class
    $data_classes[@class_id]
  end
  #--------------------------------------------------------------------------
  # * Lista de habilidades do herói
  #--------------------------------------------------------------------------
  def skills
    (@skills | added_skills).sort.collect {|id| $data_skills[id] }
  end
  #--------------------------------------------------------------------------
  # * Lista de habilidades que estão disponíveis atualmente
  #--------------------------------------------------------------------------
  def usable_skills
    skills.select {|skill| usable?(skill) }
  end
  #--------------------------------------------------------------------------
  # * Lista com características do objeto
  #--------------------------------------------------------------------------
  def feature_objects
    super + [actor] + [self.class] + equips.compact
  end
  #--------------------------------------------------------------------------
  # * Lista de elementos do ataque
  #--------------------------------------------------------------------------
  def atk_elements
    set = super
    set |= [1] if weapons.compact.empty?  # Desarmado : Elemento Físico
    return set
  end
  #--------------------------------------------------------------------------
  # * Aquisição do valor máximo do parâmetro
  #     param_id : ID do parâmetro
  #--------------------------------------------------------------------------
  def param_max(param_id)
    return 9999 if param_id == 0  # MHP
    return super
  end
  #--------------------------------------------------------------------------
  # * Aquisição do valor base do parâmetro
  #     param_id : ID do parâmetro
  #--------------------------------------------------------------------------
  def param_base(param_id)
    self.class.params[param_id, @level]
  end
  #--------------------------------------------------------------------------
  # * Aquisição do valor adicional do parâmetro
  #     param_id : ID do parâmetro
  #--------------------------------------------------------------------------
  def param_plus(param_id)
    equips.compact.inject(super) {|r, item| r += item.params[param_id] }
  end
  #--------------------------------------------------------------------------
  # * Aquisição da ID da animação de ataque normal
  #--------------------------------------------------------------------------
  def atk_animation_id1
    if dual_wield?
      return weapons[0].animation_id if weapons[0]
      return weapons[1] ? 0 : 1
    else
      return weapons[0] ? weapons[0].animation_id : 1
    end
  end
  #--------------------------------------------------------------------------
  # * Aquisição da ID da animação de ataque normal (Empunhando duas armas)
  #--------------------------------------------------------------------------
  def atk_animation_id2
    if dual_wield?
      return weapons[1] ? weapons[1].animation_id : 0
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # * Mudança de experiência
  #     exp  : valor alterado
  #     show : mostra mudança de nível
  #--------------------------------------------------------------------------
  def change_exp(exp, show)
    @exp[@class_id] = [exp, 0].max
    last_level = @level
    last_skills = skills
    level_up while !max_level? && self.exp >= next_level_exp
    level_down while self.exp < current_level_exp
    display_level_up(skills - last_skills) if show && @level > last_level
    refresh
  end
  #--------------------------------------------------------------------------
  # * Aquisição da experiência
  #--------------------------------------------------------------------------
  def exp
    @exp[@class_id]
  end
  #--------------------------------------------------------------------------
  # * Aumento de nível
  #--------------------------------------------------------------------------
  def level_up
    @level += 1
=begin
    self.class.learnings.each do |learning|
      learn_skill(learning.skill_id) if learning.level == @level
    end
=end
  end
  #--------------------------------------------------------------------------
  # * Redução de nível
  #--------------------------------------------------------------------------
  def level_down
    @level -= 1
  end
=begin
  #--------------------------------------------------------------------------
  # * Mostra mensagem de aumento de nível
  #     new_skills : Conjunto de habilidades recém-adquiridas
  #--------------------------------------------------------------------------
  def display_level_up(new_skills)
    $game_message.new_page
    $game_message.add(sprintf(Vocab::LevelUp, @name, Vocab::level, @level))
    new_skills.each do |skill|
      $game_message.add(sprintf(Vocab::ObtainSkill, skill.name))
    end
  end
=end
  #--------------------------------------------------------------------------
  # * Ganho de experiência (Considerando a taxa de aquisição de experiência)
  #     exp : experiência ganha
  #--------------------------------------------------------------------------
  def gain_exp(exp)
    change_exp(self.exp + (exp * final_exp_rate).to_i, true)
  end
  #--------------------------------------------------------------------------
  # * Cálculo final da taxa de experiência adquirida
  #--------------------------------------------------------------------------
  def final_exp_rate
    exr * (battle_member? ? 1 : reserve_members_exp_rate)
  end
  #--------------------------------------------------------------------------
  # * Taxa de experiência de membros na reseva
  #--------------------------------------------------------------------------
  def reserve_members_exp_rate
    $data_system.opt_extra_exp ? 1 : 0
  end
  #--------------------------------------------------------------------------
  # * Mudança de nível
  #     show : mostra mudança de nível
  #--------------------------------------------------------------------------
  def change_level(level, show)
    level = [[level, max_level].min, 1].max
    change_exp(exp_for_level(level), show)
  end
  #--------------------------------------------------------------------------
  # * Aprender habilidade
  #     skill_id : ID da habilidade
  #--------------------------------------------------------------------------
  def learn_skill(skill_id)
    unless skill_learn?($data_skills[skill_id])
      @skills.push(skill_id)
      @skills.sort!
    end
  end
  #--------------------------------------------------------------------------
  # * Esquecer habilidade
  #     skill_id : ID da habilidade
  #--------------------------------------------------------------------------
  def forget_skill(skill_id)
    @skills.delete(skill_id)
  end
  #--------------------------------------------------------------------------
  # * Definição de habilidade aprendia
  #     skill : habilidade
  #--------------------------------------------------------------------------
  def skill_learn?(skill)
    skill.is_a?(RPG::Skill) && @skills.include?(skill.id)
  end
  #--------------------------------------------------------------------------
  # * Descrição do herói
  #--------------------------------------------------------------------------
  def description
    actor.description
  end
  #--------------------------------------------------------------------------
  # * Mudança de classe
  #     keep_exp : manter experiência
  #--------------------------------------------------------------------------
  def change_class(class_id, keep_exp = false)
    @exp[class_id] = exp if keep_exp
    @class_id = class_id
    change_exp(@exp[@class_id] || 0, false)
    refresh
  end
  #--------------------------------------------------------------------------
  # * Modificação dos gráficos
  #     character_name  : nome do arquivo gráfico
  #     character_index : índice do arquivo gráfico
  #     face_name       : nome do arquivo de face
  #     face_index      : índice do arquivo de face
  #--------------------------------------------------------------------------
  def set_graphic(character_name, character_index, face_name, face_index)
    @character_name = character_name
    @character_index = character_index
    @face_name = face_name
    @face_index = face_index
  end
  #--------------------------------------------------------------------------
  # * Definição de uso de sprites
  #--------------------------------------------------------------------------
  def use_sprite?
    return false
  end
  #--------------------------------------------------------------------------
  # * Execução dos efeitos de dano
  #--------------------------------------------------------------------------
  def perform_damage_effect
    $game_troop.screen.start_shake(5, 5, 10)
    @sprite_effect_type = :blink
    Sound.play_actor_damage
  end
  #--------------------------------------------------------------------------
  # * Execução dos efeitos de colapso
  #--------------------------------------------------------------------------
  def perform_collapse_effect
    if $game_party.in_battle
      @sprite_effect_type = :collapse
      Sound.play_actor_collapse
    end
  end
  #--------------------------------------------------------------------------
  # * Criação da lista de ações possíveis
  #--------------------------------------------------------------------------
  def make_action_list
    list = []
    list.push(Game_Action.new(self).set_attack.evaluate)
    usable_skills.each do |skill|
      list.push(Game_Action.new(self).set_skill(skill.id).evaluate)
    end
    list
  end
  #--------------------------------------------------------------------------
  # * Definição de ações automáticas
  #--------------------------------------------------------------------------
  def make_auto_battle_actions
    @actions.size.times do |i|
      @actions = make_action_list.max_by {|action| action.value }
    end
  end
  #--------------------------------------------------------------------------
  # * Definição de ações quando em confusão
  #--------------------------------------------------------------------------
  def make_confusion_actions
    @actions.size.times do |i|
      @actions[i].set_confusion
    end
  end
  #--------------------------------------------------------------------------
  # * Definição de ações
  #--------------------------------------------------------------------------
  def make_actions
    super
    if auto_battle?
      make_auto_battle_actions
    elsif confusion?
      make_confusion_actions
    end
  end
  #--------------------------------------------------------------------------
  # * Processamento após um passo
  #--------------------------------------------------------------------------
  def on_player_walk
    @result.clear
    check_floor_effect
    if $game_player.normal_walk?
      turn_end_on_map
      states.each {|state| update_state_steps(state) }
      show_added_states
      show_removed_states
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização dos estados após um passo
  #     state : estados
  #--------------------------------------------------------------------------
  def update_state_steps(state)
    if state.remove_by_walking
      @state_steps[state.id] -= 1 if @state_steps[state.id] > 0
      remove_state(state.id) if @state_steps[state.id] == 0
    end
  end
  #--------------------------------------------------------------------------
  # * Mostrar estados adicionados
  #--------------------------------------------------------------------------
  def show_added_states
    @result.added_state_objects.each do |state|
      $game_message.add(name + state.message1) unless state.message1.empty?
    end
  end
  #--------------------------------------------------------------------------
  # * Mostrar estados removidos
  #--------------------------------------------------------------------------
  def show_removed_states
    @result.removed_state_objects.each do |state|
      $game_message.add(name + state.message4) unless state.message4.empty?
    end
  end
  #--------------------------------------------------------------------------
  # * Definição de número de passos equivalentes a 1 turno
  #--------------------------------------------------------------------------
  def steps_for_turn
    return 20
  end
  #--------------------------------------------------------------------------
  # * Finalização de turno no mapa
  #--------------------------------------------------------------------------
  def turn_end_on_map
    if $game_party.steps % steps_for_turn == 0
      on_turn_end
      # VXA-OS
      perform_map_damage_effect if @result.hp_damage
    end
  end
  #--------------------------------------------------------------------------
  # * Definição de um efeito de terreno
  #--------------------------------------------------------------------------
  def check_floor_effect
    execute_floor_damage if $game_player.on_damage_floor?
  end
  #--------------------------------------------------------------------------
  # * Execução do dano de terreno
  #--------------------------------------------------------------------------
  def execute_floor_damage
    damage = (basic_floor_damage * fdr).to_i
    self.hp -= [damage, max_floor_damage].min
    perform_map_damage_effect if damage > 0
  end
  #--------------------------------------------------------------------------
  # * Aquisição do dano basico de terreno
  #--------------------------------------------------------------------------
  def basic_floor_damage
    return 10
  end
  #--------------------------------------------------------------------------
  # * Aquisição do dano máximo de terreno
  #--------------------------------------------------------------------------
  def max_floor_damage
    $data_system.opt_floor_death ? hp : [hp - 1, 0].max
  end
  #--------------------------------------------------------------------------
  # * Execução dos efeitos do dano no mapa
  #--------------------------------------------------------------------------
  def perform_map_damage_effect
    $game_map.screen.start_flash_for_damage
  end
  #--------------------------------------------------------------------------
  # * Limpeza das ações
  #--------------------------------------------------------------------------
  def clear_actions
    super
    @action_input_index = 0
  end
  #--------------------------------------------------------------------------
  # * Aquisição do tipo de ação
  #--------------------------------------------------------------------------
  def input
    @actions[@action_input_index]
  end
  #--------------------------------------------------------------------------
  # * Próxima entrada de comandos 
  #--------------------------------------------------------------------------
  def next_command
    return false if @action_input_index >= @actions.size - 1
    @action_input_index += 1
    return true
  end
  #--------------------------------------------------------------------------
  # * Entrada de comandos anterior
  #--------------------------------------------------------------------------
  def prior_command
    return false if @action_input_index <= 0
    @action_input_index -= 1
    return true
  end
end
