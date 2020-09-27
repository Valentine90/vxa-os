#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  Esta classe gerencia o grupo. Contém informações sobre dinheiro, itens.
# A instância desta classe é referenciada por $game_party.
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # * Constantes
  #--------------------------------------------------------------------------
  ABILITY_ENCOUNTER_HALF    = 0           # Reduzir taxa de encontros
  ABILITY_ENCOUNTER_NONE    = 1           # Anular taxa de encontro
  ABILITY_CANCEL_SURPRISE   = 2           # Cancelar surpresa
  ABILITY_RAISE_PREEMPTIVE  = 3           # Cancelar iniciativa
  ABILITY_GOLD_DOUBLE       = 4           # Dobrar dinheiro recebido
  ABILITY_DROP_ITEM_DOUBLE  = 5           # Dobrar taxa de aquisição de itens
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :gold                     # Dinheiro
  attr_reader   :steps                    # Número de passos
  attr_reader   :last_item                # Memória do cursor : itens
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #--------------------------------------------------------------------------
  def initialize
    super
    @gold = 0
    @steps = 0
    @last_item = Game_BaseItem.new
    @menu_actor_id = 0
    @target_actor_id = 0
    @actors = []
    init_all_items
  end
  #--------------------------------------------------------------------------
  # * Inicialização de todos itens
  #--------------------------------------------------------------------------
  def init_all_items
    @items = {}
    @weapons = {}
    @armors = {}
  end
  #--------------------------------------------------------------------------
  # * Definição de presença
  #--------------------------------------------------------------------------
  def exists
    !@actors.empty?
  end
  #--------------------------------------------------------------------------
  # * Lista de membros
  #--------------------------------------------------------------------------
  def members
    in_battle ? battle_members : all_members
  end
  #--------------------------------------------------------------------------
  # * Lista de todos os membros
  #--------------------------------------------------------------------------
  def all_members
    @actors.collect {|id| $game_actors[id] }
  end
  #--------------------------------------------------------------------------
  # * Lista de membros de batalha
  #--------------------------------------------------------------------------
  def battle_members
    all_members[0, max_battle_members].select {|actor| actor.exist? }
  end
  #--------------------------------------------------------------------------
  # * Número máximo de membros na batalha
  #--------------------------------------------------------------------------
  def max_battle_members
    return 4
  end
  #--------------------------------------------------------------------------
  # * Definição de lider
  #--------------------------------------------------------------------------
  def leader
    battle_members[0]
  end
  #--------------------------------------------------------------------------
  # * Lista de itens do grupo
  #--------------------------------------------------------------------------
  def items
    @items.keys.sort.collect {|id| $data_items[id] }
  end
  #--------------------------------------------------------------------------
  # * Lista de armas do grupo
  #--------------------------------------------------------------------------
  def weapons
    @weapons.keys.sort.collect {|id| $data_weapons[id] }
  end
  #--------------------------------------------------------------------------
  # * Lista de armadures do grupo
  #--------------------------------------------------------------------------
  def armors
    @armors.keys.sort.collect {|id| $data_armors[id] }
  end
  #--------------------------------------------------------------------------
  # * Lista de equipamentos do grupo
  #--------------------------------------------------------------------------
  def equip_items
    weapons + armors
  end
  #--------------------------------------------------------------------------
  # * Lista de todos os itens do grupo
  #--------------------------------------------------------------------------
  def all_items
    items + equip_items
  end
  #--------------------------------------------------------------------------
  # * Aquisição das informações da classe de determinado item
  #     item_class : classe do item
  #--------------------------------------------------------------------------
  def item_container(item_class)
    return @items   if item_class == RPG::Item
    return @weapons if item_class == RPG::Weapon
    return @armors  if item_class == RPG::Armor
    return nil
  end
  #--------------------------------------------------------------------------
  # * Configuração do grupo inicial
  #--------------------------------------------------------------------------
  def setup_starting_members
    @actors = $data_system.party_members.clone
  end
  #--------------------------------------------------------------------------
  # * Aquisição do nome do grupo
  #--------------------------------------------------------------------------
  def name
    return ""           if battle_members.size == 0
    return leader.name  if battle_members.size == 1
    return sprintf(Vocab::PartyName, leader.name)
  end
  #--------------------------------------------------------------------------
  # * Configuração do teste de combate
  #--------------------------------------------------------------------------
  def setup_battle_test
    setup_battle_test_members
    setup_battle_test_items
  end
  #--------------------------------------------------------------------------
  # * Configuração do grupo do teste de combate
  #--------------------------------------------------------------------------
  def setup_battle_test_members
    $data_system.test_battlers.each do |battler|
      actor = $game_actors[battler.actor_id]
      actor.change_level(battler.level, false)
      actor.init_equips(battler.equips)
      actor.recover_all
      add_actor(actor.id)
    end
  end
  #--------------------------------------------------------------------------
  # * Configuração dos itens do teste de combate
  #--------------------------------------------------------------------------
  def setup_battle_test_items
    $data_items.each do |item|
      gain_item(item, max_item_number(item)) if item && !item.name.empty?
    end
  end
  #--------------------------------------------------------------------------
  # * Aquisição do nível mais alto dos membros do grupo
  #--------------------------------------------------------------------------
  def highest_level
    lv = members.collect {|actor| actor.level }.max
  end
  #--------------------------------------------------------------------------
  # * Adição do herói
  #     actor_id : ID do herói
  #--------------------------------------------------------------------------
  def add_actor(actor_id)
    @actors.push(actor_id) unless @actors.include?(actor_id)
    $game_player.refresh
    $game_map.need_refresh = true
  end
  #--------------------------------------------------------------------------
  # * Remoção do herói
  #     actor_id : ID do herói
  #--------------------------------------------------------------------------
  def remove_actor(actor_id)
    @actors.delete(actor_id)
    $game_player.refresh
    $game_map.need_refresh = true
  end
  #--------------------------------------------------------------------------
  # * Ganhar dinheiro
  #     amount : quantia ganhaa
  #--------------------------------------------------------------------------
  def gain_gold(amount)
    @gold = [[@gold + amount, 0].max, max_gold].min
  end
  #--------------------------------------------------------------------------
  # * Perder dinheiro
  #     amount : quantia perdida
  #--------------------------------------------------------------------------
  def lose_gold(amount)
    gain_gold(-amount)
  end
  #--------------------------------------------------------------------------
  # * Aquisição do valor máximo de dinheiro
  #--------------------------------------------------------------------------
  def max_gold
    return 99999999
  end
  #--------------------------------------------------------------------------
  # * Aumentar número de passos
  #--------------------------------------------------------------------------
  def increase_steps
    @steps += 1
  end
  #--------------------------------------------------------------------------
  # * Aquisição do número de itens possuido
  #     item : item
  #--------------------------------------------------------------------------
  def item_number(item)
    container = item_container(item.class)
    container ? container[item.id] || 0 : 0
  end
  #--------------------------------------------------------------------------
  # * Aquisição do número máximo de itens permitido
  #     item : item
  #--------------------------------------------------------------------------
  def max_item_number(item)
    return 99
  end
  #--------------------------------------------------------------------------
  # * Definição de número máximo de itens
  #     item : item
  #--------------------------------------------------------------------------
  def item_max?(item)
    item_number(item) >= max_item_number(item)
  end
  #--------------------------------------------------------------------------
  # * Definição de posse de item
  #     include_equip : incluir itens equipados
  #--------------------------------------------------------------------------
  def has_item?(item, include_equip = false)
    return true if item_number(item) > 0
    return include_equip ? members_equip_include?(item) : false
  end
  #--------------------------------------------------------------------------
  # * Definição de item equipado
  #     item : item
  #--------------------------------------------------------------------------
  def members_equip_include?(item)
    members.any? {|actor| actor.equips.include?(item) }
  end
  #--------------------------------------------------------------------------
  # * Acrescentar item (redução)
  #     item          : item
  #     amount        : quantia alterada
  #     include_equip : incluir itens equipados
  #--------------------------------------------------------------------------
  def gain_item(item, amount, include_equip = false)
    container = item_container(item.class)
    return unless container
    last_number = item_number(item)
    new_number = last_number + amount
    container[item.id] = [[new_number, 0].max, max_item_number(item)].min
    container.delete(item.id) if container[item.id] == 0
    if include_equip && new_number < 0
      discard_members_equip(item, -new_number)
    end
    $game_map.need_refresh = true
  end
  #--------------------------------------------------------------------------
  # * Discartar equipamento
  #     item   : item
  #     amount : quantia descartada
  #--------------------------------------------------------------------------
  def discard_members_equip(item, amount)
    n = amount
    members.each do |actor|
      while n > 0 && actor.equips.include?(item)
        actor.discard_equip(item)
        n -= 1
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Reduzie item
  #     item          : item
  #     amount        : quantia alterada
  #     include_equip : incluir itens equipados  
  #--------------------------------------------------------------------------
  def lose_item(item, amount, include_equip = false)
    gain_item(item, -amount, include_equip)
  end
  #--------------------------------------------------------------------------
  # * Consumir item
  #    Se o objeto especificado é um item consumível, diminuir a quantia
  #     item : item
  #--------------------------------------------------------------------------
  def consume_item(item)
    lose_item(item, 1) if item.is_a?(RPG::Item) && item.consumable
  end
  #--------------------------------------------------------------------------
  # * Definição de permissão de uso do item
  #     item : item
  #--------------------------------------------------------------------------
  def usable?(item)
    members.any? {|actor| actor.usable?(item) }
  end
  #--------------------------------------------------------------------------
  # * Definição de entrada de comandos
  #--------------------------------------------------------------------------
  def inputable?
    members.any? {|actor| actor.inputable? }
  end
  #--------------------------------------------------------------------------
  # * Definição de derrota
  #--------------------------------------------------------------------------
  def all_dead?
    super && ($game_party.in_battle || members.size > 0)
  end
  #--------------------------------------------------------------------------
  # * Processamento após um passo
  #--------------------------------------------------------------------------
  def on_player_walk
    members.each {|actor| actor.on_player_walk }
  end
  #--------------------------------------------------------------------------
  # * Definição de herói para seleção no menu
  #--------------------------------------------------------------------------
  def menu_actor
    $game_actors[@menu_actor_id] || members[0]
  end
  #--------------------------------------------------------------------------
  # * Definição de herói selecionado no menu
  #     actor : herói
  #--------------------------------------------------------------------------
  def menu_actor=(actor)
    @menu_actor_id = actor.id
  end
  #--------------------------------------------------------------------------
  # * Selecionar próximo herói no menu
  #--------------------------------------------------------------------------
  def menu_actor_next
    index = members.index(menu_actor) || -1
    index = (index + 1) % members.size
    self.menu_actor = members[index]
  end
  #--------------------------------------------------------------------------
  # * Selecionar herói anterior no menu
  #--------------------------------------------------------------------------
  def menu_actor_prev
    index = members.index(menu_actor) || 1
    index = (index + members.size - 1) % members.size
    self.menu_actor = members[index]
  end
  #--------------------------------------------------------------------------
  # * Definição de herói para alvo de habilidades/itens
  #--------------------------------------------------------------------------
  def target_actor
    $game_actors[@target_actor_id] || members[0]
  end
  #--------------------------------------------------------------------------
  # * Definição de herói alvo de habilidades/itens
  #     actor : herói
  #--------------------------------------------------------------------------
  def target_actor=(actor)
    @target_actor_id = actor.id
  end
  #--------------------------------------------------------------------------
  # * Mudança de ordem
  #     index1 : índice do primeiro herói
  #     index2 : índice do segundo herói
  #--------------------------------------------------------------------------
  def swap_order(index1, index2)
    @actors[index1], @actors[index2] = @actors[index2], @actors[index1]
    $game_player.refresh
  end
  #--------------------------------------------------------------------------
  # * Heróis a serem exibidos no arquivo de save
  #--------------------------------------------------------------------------
  def characters_for_savefile
    battle_members.collect do |actor|
      [actor.character_name, actor.character_index]
    end
  end
  #--------------------------------------------------------------------------
  # * Definição de característica especial do grupo
  #     ability_id : ID da característica
  #--------------------------------------------------------------------------
  def party_ability(ability_id)
    battle_members.any? {|actor| actor.party_ability(ability_id) }
  end
  #--------------------------------------------------------------------------
  # * Definição de redução da taxa de encontros
  #--------------------------------------------------------------------------
  def encounter_half?
    party_ability(ABILITY_ENCOUNTER_HALF)
  end
  #--------------------------------------------------------------------------
  # * Definição de anulação da taxa de encontros
  #--------------------------------------------------------------------------
  def encounter_none?
    party_ability(ABILITY_ENCOUNTER_NONE)
  end
  #--------------------------------------------------------------------------
  # * Definição de cancelamento de surpresa
  #--------------------------------------------------------------------------
  def cancel_surprise?
    party_ability(ABILITY_CANCEL_SURPRISE)
  end
  #--------------------------------------------------------------------------
  # * Definição de cancelamento de iniciativa
  #--------------------------------------------------------------------------
  def raise_preemptive?
    party_ability(ABILITY_RAISE_PREEMPTIVE)
  end
  #--------------------------------------------------------------------------
  # * Definição de ganho dobrado de dinheiro
  #--------------------------------------------------------------------------
  def gold_double?
    party_ability(ABILITY_GOLD_DOUBLE)
  end
  #--------------------------------------------------------------------------
  # * Definição de chance dobrada de aquisição de itens
  #--------------------------------------------------------------------------
  def drop_item_double?
    party_ability(ABILITY_DROP_ITEM_DOUBLE)
  end
  #--------------------------------------------------------------------------
  # * Cálculo da probabilidade de iniciative
  #     troop_agi : agilidade média do grupo de inimigos
  #--------------------------------------------------------------------------
  def rate_preemptive(troop_agi)
    (agi >= troop_agi ? 0.05 : 0.03) * (raise_preemptive? ? 4 : 1)
  end
  #--------------------------------------------------------------------------
  # * Cálculo da probabilidade de surpresa
  #     troop_agi : agilidade média do grupo de inimigos
  #--------------------------------------------------------------------------
  def rate_surprise(troop_agi)
    cancel_surprise? ? 0 : (agi >= troop_agi ? 0.03 : 0.05)
  end
end
