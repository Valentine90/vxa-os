#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  Esta classe gerencia os inimigos. Ela é utilizada internamente pela 
# classe Game_Troop ($game_troop).
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :index                    # Índice do inimigo na tropa
  attr_reader   :enemy_id                 # ID do inimigo
  attr_reader   :original_name            # Nome original
  attr_accessor :letter                   # Letra associado ao nome
  attr_accessor :plural                   # Flag de várias ocorrencias
  attr_accessor :screen_x                 # Coordenada X na tela
  attr_accessor :screen_y                 # Coordenada Y na tela
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #--------------------------------------------------------------------------
  def initialize(index, enemy_id)
    super()
    @index = index
    @enemy_id = enemy_id
    enemy = $data_enemies[@enemy_id]
    @original_name = enemy.name
    @letter = ""
    @plural = false
    @screen_x = 0
    @screen_y = 0
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    @hp = mhp
    @mp = mmp
  end
  #--------------------------------------------------------------------------
  # * Definição de inimigo
  #--------------------------------------------------------------------------
  def enemy?
    return true
  end
=begin
  #--------------------------------------------------------------------------
  # * Unidade aliada
  #--------------------------------------------------------------------------
  def friends_unit
    $game_troop
  end
=end
  #--------------------------------------------------------------------------
  # * Unidade inimiga
  #--------------------------------------------------------------------------
  def opponents_unit
    $game_party
  end
  #--------------------------------------------------------------------------
  # * Aquisição das informçãoes do inimigo
  #--------------------------------------------------------------------------
  def enemy
    $data_enemies[@enemy_id]
  end
  #--------------------------------------------------------------------------
  # * Lista com características do objeto
  #--------------------------------------------------------------------------
  def feature_objects
    super + [enemy]
  end
  #--------------------------------------------------------------------------
  # * Nome de exibição
  #--------------------------------------------------------------------------
  def name
    @original_name + (@plural ? letter : "")
  end
  #--------------------------------------------------------------------------
  # * Aquisição do valor base do parâmetro
  #     param_id : ID do parâmetro
  #--------------------------------------------------------------------------
  def param_base(param_id)
    enemy.params[param_id]
  end
  #--------------------------------------------------------------------------
  # * Aquisição de experiência
  #--------------------------------------------------------------------------
  def exp
    enemy.exp
  end
  #--------------------------------------------------------------------------
  # * Aquisição de dinheiro
  #--------------------------------------------------------------------------
  def gold
    enemy.gold
  end
  #--------------------------------------------------------------------------
  # * Lista de itens derrubados
  #--------------------------------------------------------------------------
  def make_drop_items
    enemy.drop_items.inject([]) do |r, di|
      if di.kind > 0 && rand * di.denominator < drop_item_rate
        r.push(item_object(di.kind, di.data_id))
      else
        r
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Modificador de taxa de aquisição de itens
  #--------------------------------------------------------------------------
  def drop_item_rate
    $game_party.drop_item_double? ? 2 : 1
  end
  #--------------------------------------------------------------------------
  # * Aquisição das informações do item
  #     kind    : tipo do item
  #     data_id : ID do item
  #--------------------------------------------------------------------------
  def item_object(kind, data_id)
    return $data_items  [data_id] if kind == 1
    return $data_weapons[data_id] if kind == 2
    return $data_armors [data_id] if kind == 3
    return nil
  end
  #--------------------------------------------------------------------------
  # * Definição de uso de sprites
  #--------------------------------------------------------------------------
  def use_sprite?
    return true
  end
  #--------------------------------------------------------------------------
  # * Aquisição do coordenada Z na tela
  #--------------------------------------------------------------------------
  def screen_z
    return 100
  end
  #--------------------------------------------------------------------------
  # * Execução dos efeitos de dano
  #--------------------------------------------------------------------------
  def perform_damage_effect
    @sprite_effect_type = :blink
    Sound.play_enemy_damage
  end
  #--------------------------------------------------------------------------
  # * Execução dos efeitos de colapso
  #--------------------------------------------------------------------------
  def perform_collapse_effect
    case collapse_type
    when 0
      @sprite_effect_type = :collapse
      Sound.play_enemy_collapse
    when 1
      @sprite_effect_type = :boss_collapse
      Sound.play_boss_collapse1
    when 2
      @sprite_effect_type = :instant_collapse
    end
  end
  #--------------------------------------------------------------------------
  # * Transformação
  #     enemy_id : ID do inimigo
  #--------------------------------------------------------------------------
  def transform(enemy_id)
    @enemy_id = enemy_id
    if enemy.name != @original_name
      @original_name = enemy.name
      @letter = ""
      @plural = false
    end
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    refresh
    make_actions unless @actions.empty?
  end
  #--------------------------------------------------------------------------
  # * Definição de atendimento das condições de uma ação
  #     action : ação
  #--------------------------------------------------------------------------
  def conditions_met?(action)
    method_table = {
      1 => :conditions_met_turns?,
      2 => :conditions_met_hp?,
      3 => :conditions_met_mp?,
      4 => :conditions_met_state?,
      5 => :conditions_met_party_level?,
      6 => :conditions_met_switch?,
    }
    method_name = method_table[action.condition_type]
    if method_name
      send(method_name, action.condition_param1, action.condition_param2)
    else
      true
    end
  end
  #--------------------------------------------------------------------------
  # * Definição de regras de decisão para condições [Número de turnos]
  #     param1 : turnos totais
  #     param2 : turnos múltiplos
  #--------------------------------------------------------------------------
  def conditions_met_turns?(param1, param2)
    n = $game_troop.turn_count
    if param2 == 0
      n == param1
    else
      n > 0 && n >= param1 && n % param2 == param1 % param2
    end
  end
  #--------------------------------------------------------------------------
  # * Definição de regras de decisão para condições [HP]
  #     param1 : valor mínimo
  #     param2 : valor máximo
  #--------------------------------------------------------------------------
  def conditions_met_hp?(param1, param2)
    hp_rate >= param1 && hp_rate <= param2
  end
  #--------------------------------------------------------------------------
  # * Definição de regras de decisão para condições [MP]
  #     param1 : valor mínimo
  #     param2 : valor máximo
  #--------------------------------------------------------------------------
  def conditions_met_mp?(param1, param2)
    mp_rate >= param1 && mp_rate <= param2
  end
  #--------------------------------------------------------------------------
  # * Definição de regras de decisão para condições [Estado]
  #     param1 : estado
  #--------------------------------------------------------------------------
  def conditions_met_state?(param1, param2)
    state?(param1)
  end
  #--------------------------------------------------------------------------
  # * Definição de regras de decisão para condições [Nível do Grupo]
  #     param1 : nível
  #--------------------------------------------------------------------------
  def conditions_met_party_level?(param1, param2)
    $game_party.highest_level >= param1
  end
  #--------------------------------------------------------------------------
  # * Definição de regras de decisão para condições [Switch]
  #     param1 : ID do switch
  #--------------------------------------------------------------------------
  def conditions_met_switch?(param1, param2)
    $game_switches[param1]
  end
  #--------------------------------------------------------------------------
  # * Definição de ação valida
  #     action : ação
  #--------------------------------------------------------------------------
  def action_valid?(action)
    conditions_met?(action) && usable?($data_skills[action.skill_id])
  end
  #--------------------------------------------------------------------------
  # * Definição de ação selecionada aleatóriamente
  #     action_list : lista de ações
  #     rating_zero : valor consideradocomo taxa zero
  #--------------------------------------------------------------------------
  def select_enemy_action(action_list, rating_zero)
    sum = action_list.inject(0) {|r, a| r += a.rating - rating_zero }
    return nil if sum <= 0
    value = rand(sum)
    action_list.each do |action|
      return action if value < action.rating - rating_zero
      value -= action.rating - rating_zero
    end
  end
  #--------------------------------------------------------------------------
  # * Definição de ações
  #--------------------------------------------------------------------------
  def make_actions
    super
    return if @actions.empty?
    action_list = enemy.actions.select {|a| action_valid?(a) }
    return if action_list.empty?
    rating_max = action_list.collect {|a| a.rating }.max
    rating_zero = rating_max - 3
    action_list.reject! {|a| a.rating <= rating_zero }
    @actions.each do |action|
      action.set_enemy_action(select_enemy_action(action_list, rating_zero))
    end
  end
end
