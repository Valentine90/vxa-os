#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  Um interpretador para executar os comandos de evento. Esta classe é usada
# internamente pelas classes Game_Map, Game_Troop e Game_Event.
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :map_id             # ID do mapa
  attr_reader   :event_id           # ID do evento (apenas evento comun)
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #     depth : profundidade
  #--------------------------------------------------------------------------
  def initialize(depth = 0)
    @depth = depth
    check_overflow
    clear
  end
  #--------------------------------------------------------------------------
  # * Verificar se há excesso de eventos
  #    Profundidades superiores a 100 normalmente não são utilizadas
  #    
  #--------------------------------------------------------------------------
  def check_overflow
    if @depth >= 100
      msgbox(Vocab::EventOverflow)
      exit
    end
  end
  #--------------------------------------------------------------------------
  # * Limpeza
  #--------------------------------------------------------------------------
  def clear
    @map_id = 0
    @event_id = 0
    @list = nil                       # Lista de ações
    @index = 0                        # Índice
    @branch = {}                      # Ramificação dos dados
    @fiber = nil                      # Fibra
  end
  #--------------------------------------------------------------------------
  # * Configuração do evento
  #     list     : lista de ações
  #     event_id : ID do evento
  #--------------------------------------------------------------------------
  def setup(list, event_id = 0)
    clear
    @map_id = $game_map.map_id
    @event_id = event_id
    @list = list
    create_fiber
  end
  #--------------------------------------------------------------------------
  # * Criação de uma fibra
  #--------------------------------------------------------------------------
  def create_fiber
    @fiber = Fiber.new { run } if @list
  end
  #--------------------------------------------------------------------------
  # * Despejo de um objeto
  #   A fibra não é compatível com o Marshal.
  #   Execução do local do evento para salvar um processo.
  #--------------------------------------------------------------------------
  def marshal_dump
    [@depth, @map_id, @event_id, @list, @index + 1, @branch]
  end
  #--------------------------------------------------------------------------
  # * Carregando um objeto
  #     obj : objetos que foram jogados em marshal_dump (array)
  #     retorna os dados se necessário re-criar a fibra.
  #--------------------------------------------------------------------------
  def marshal_load(obj)
    @depth, @map_id, @event_id, @list, @index, @branch = obj
    create_fiber
  end
  #--------------------------------------------------------------------------
  # * Definição de quando o evento é acionado o mesmo mapa
  #--------------------------------------------------------------------------
  def same_map?
    @map_id == $game_map.map_id
  end
=begin
  #--------------------------------------------------------------------------
  # * Configuração de chamada de evento comum reservado
  #--------------------------------------------------------------------------
  def setup_reserved_common_event
    if $game_temp.common_event_reserved?
      setup($game_temp.reserved_common_event.list)
      $game_temp.clear_common_event
      true
    else
      false
    end
  end
=end
  #--------------------------------------------------------------------------
  # * Execução
  #--------------------------------------------------------------------------
  def run
    wait_for_message
    while @list[@index] do
      execute_command
      @index += 1
    end
    Fiber.yield
    @fiber = nil
  end
  #--------------------------------------------------------------------------
  # * Definição de execução
  #--------------------------------------------------------------------------
  def running?
    @fiber != nil
  end
  #--------------------------------------------------------------------------
  # * Atualização da tela
  #--------------------------------------------------------------------------
  def update
    @fiber.resume if @fiber
  end
=begin
  #--------------------------------------------------------------------------
  # * Iterador para personagens (ID)
  #     param : 1 Se ID acima、0 intacton
  #--------------------------------------------------------------------------
  def iterate_actor_id(param)
    if param == 0
      $game_party.members.each {|actor| yield actor }
    else
      actor = $game_actors[param]
      yield actor if actor
    end
  end
  #--------------------------------------------------------------------------
  # * Iterador para personagens (variável)
  #     param1 : 0 se fixo,、1 Se variável especificada
  #     param2 : ID do personagem ou variável
  #--------------------------------------------------------------------------
  def iterate_actor_var(param1, param2)
    if param1 == 0
      iterate_actor_id(param2) {|actor| yield actor }
    else
      iterate_actor_id($game_variables[param2]) {|actor| yield actor }
    end
  end
  #--------------------------------------------------------------------------
  # * Iterador para personagens (índice)
  #     param : 0 Se ID acima,-1 intacton
  #--------------------------------------------------------------------------
  def iterate_actor_index(param)
    if param < 0
      $game_party.members.each {|actor| yield actor }
    else
      actor = $game_party.members[param]
      yield actor if actor
    end
  end
  #--------------------------------------------------------------------------
  # * Iterador para inimigos (índice) 
  #     param : 0 Se ID acima,-1 intacton
  #--------------------------------------------------------------------------
  def iterate_enemy_index(param)
    if param < 0
      $game_troop.members.each {|enemy| yield enemy }
    else
      enemy = $game_troop.members[param]
      yield enemy if enemy
    end
  end
  #--------------------------------------------------------------------------
  # * Iterador para lutadores (grupo de inimigo ou personagens)
  #     param1 : 0 se inimigos, 1 se personagens
  #     param2 : Índice de inimigos, ID se personagem
  #--------------------------------------------------------------------------
  def iterate_battler(param1, param2)
    if $game_party.in_battle
      if param1 == 0
        iterate_enemy_index(param2) {|enemy| yield enemy }
      else
        iterate_actor_id(param2) {|actor| yield actor }
      end
    end
  end
=end
  #--------------------------------------------------------------------------
  # * VXA-OS
  #--------------------------------------------------------------------------
  def screen
    $game_map.screen
  end
  #--------------------------------------------------------------------------
  # * Execução do comando
  #--------------------------------------------------------------------------
  def execute_command
    command = @list[@index]
    @params = command.parameters
    @indent = command.indent
    method_name = "command_#{command.code}"
    send(method_name) if respond_to?(method_name)
  end
=begin
  #--------------------------------------------------------------------------
  # * Pular comando
  #--------------------------------------------------------------------------
  def command_skip
    @index += 1 while @list[@index + 1].indent > @indent
  end
=end
  #--------------------------------------------------------------------------
  # * Próximo comano do evento
  #--------------------------------------------------------------------------
  def next_event_code
    @list[@index + 1].code
  end
  #--------------------------------------------------------------------------
  # * Aquisição do personagem
  #     param : -1 se jogador, 0 se mesmo evento, ID se maior que zero
  #--------------------------------------------------------------------------
  def get_character(param)
    if $game_party.in_battle
      nil
    elsif param < 0
      $game_player
    else
      events = same_map? ? $game_map.events : {}
      events[param > 0 ? param : @event_id]
    end
  end
=begin
  #--------------------------------------------------------------------------
  # * Cálculo do valor da operação
  #     operation    : operação (0: soma,  1: subtração)
  #     operand_type : tipo de operando (0: constante, 1: variável)
  #     operand      : operando (valor numérico ou ID da variável)
  #--------------------------------------------------------------------------
  def operate_value(operation, operand_type, operand)
    value = operand_type == 0 ? operand : $game_variables[operand]
    operation == 0 ? value : -value
  end
=end
  #--------------------------------------------------------------------------
  # * Tempo de espera
  #     duration : duração
  #--------------------------------------------------------------------------
  def wait(duration)
    duration.times { Fiber.yield }
  end
  #--------------------------------------------------------------------------
  # * Espera para exibição da mensagem
  #--------------------------------------------------------------------------
  def wait_for_message
    Fiber.yield while $game_message.busy?
  end
  #--------------------------------------------------------------------------
  # * Mostrar Mensagem
  #--------------------------------------------------------------------------
  def command_101
    wait_for_message
    $game_message.face_name = @params[0]
    $game_message.face_index = @params[1]
    $game_message.background = @params[2]
    $game_message.position = @params[3]
    while next_event_code == 401       # Texto
      @index += 1
      $game_message.add(@list[@index].parameters[0])
    end
    case next_event_code
    when 102  # Mostrar escolhas
      @index += 1
      setup_choices(@list[@index].parameters)
    when 103  # Entrada numérica
      @index += 1
      setup_num_input(@list[@index].parameters)
    when 104  # Selecionar item
      @index += 1
      setup_item_choice(@list[@index].parameters)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # * Mostrar escolhas
  #--------------------------------------------------------------------------
  def command_102
    wait_for_message
    setup_choices(@params)
    Fiber.yield while $game_message.choice?
  end
  #--------------------------------------------------------------------------
  # * Configuação de escolhas
  #     params : parâmetros
  #--------------------------------------------------------------------------
  def setup_choices(params)
    params[0].each {|s| $game_message.choices.push(s) }
    $game_message.choice_cancel_type = params[1]
    $game_message.choice_proc = Proc.new {|n| @branch[@indent] = n }
  end
=begin
  #--------------------------------------------------------------------------
  # * [**] Escolha
  #--------------------------------------------------------------------------
  def command_402
    command_skip if @branch[@indent] != @params[0]
  end
  #--------------------------------------------------------------------------
  # * Se cancelar
  #--------------------------------------------------------------------------
  def command_403
    command_skip if @branch[@indent] != 4
  end
=end
  #--------------------------------------------------------------------------
  # * Entrada numérica
  #--------------------------------------------------------------------------
  def command_103
    wait_for_message
    setup_num_input(@params)
    Fiber.yield while $game_message.num_input?
  end
  #--------------------------------------------------------------------------
  # * Configuração de entrada numérica
  #     params : parâmetros
  #--------------------------------------------------------------------------
  def setup_num_input(params)
    $game_message.num_input_variable_id = params[0]
    $game_message.num_input_digits_max = params[1]
  end
  #--------------------------------------------------------------------------
  # *  Selecionar item
  #--------------------------------------------------------------------------
  def command_104
    wait_for_message
    setup_item_choice(@params)
    Fiber.yield while $game_message.item_choice?
  end
  #--------------------------------------------------------------------------
  # * Configuração da seleção de itens
  #     params : parâmetros
  #--------------------------------------------------------------------------
  def setup_item_choice(params)
    $game_message.item_choice_variable_id = params[0]
  end
  #--------------------------------------------------------------------------
  # * Mostrar texto em rolagem
  #--------------------------------------------------------------------------
  def command_105
    Fiber.yield while $game_message.visible
    $game_message.scroll_mode = true
    $game_message.scroll_speed = @params[0]
    $game_message.scroll_no_fast = @params[1]
    while next_event_code == 405
      @index += 1
      $game_message.add(@list[@index].parameters[0])
    end
    wait_for_message
  end
=begin
  #--------------------------------------------------------------------------
  # * Comentários
  #--------------------------------------------------------------------------
  def command_108
    @comments = [@params[0]]
    while next_event_code == 408
      @index += 1
      @comments.push(@list[@index].parameters[0])
    end
  end
  #--------------------------------------------------------------------------
  # * Condições
  #--------------------------------------------------------------------------
  def command_111
    result = false
    case @params[0]
    when 0  # Switch
      result = ($game_switches[@params[1]] == (@params[2] == 0))
    when 1  # Variável
      value1 = $game_variables[@params[1]]
      if @params[2] == 0
        value2 = @params[3]
      else
        value2 = $game_variables[@params[3]]
      end
      case @params[4]
      when 0  # Igual a
        result = (value1 == value2)
      when 1  # Maior ou igual
        result = (value1 >= value2)
      when 2  # Menor ou igual
        result = (value1 <= value2)
      when 3  # Maior que
        result = (value1 > value2)
      when 4  # Menor que
        result = (value1 < value2)
      when 5  # Diferente
        result = (value1 != value2)
      end
    when 2  # Switch Local
      if @event_id > 0
        key = [@map_id, @event_id, @params[1]]
        result = ($game_self_switches[key] == (@params[2] == 0))
      end
    when 3  # Tempo
      if $game_timer.working?
        if @params[2] == 0
          result = ($game_timer.sec >= @params[1])
        else
          result = ($game_timer.sec <= @params[1])
        end
      end
    when 4  # Herói
      actor = $game_actors[@params[1]]
      if actor
        case @params[2]
        when 0  # Está no grupo
          result = ($game_party.members.include?(actor))
        when 1  # Nome
          result = (actor.name == @params[3])
        when 2  # Classe
          result = (actor.class_id == @params[3])
        when 3  # Habilidade
          result = (actor.skill_learn?($data_skills[@params[3]]))
        when 4  # Arma
          result = (actor.weapons.include?($data_weapons[@params[3]]))
        when 5  # Armadura
          result = (actor.armors.include?($data_armors[@params[3]]))
        when 6  # Estado
          result = (actor.state?(@params[3]))
        end
      end
    when 5  # Inimigo
      enemy = $game_troop.members[@params[1]]
      if enemy
        case @params[2]
        when 0  # Vivo
          result = (enemy.alive?)
        when 1  # Estado
          result = (enemy.state?(@params[3]))
        end
      end
    when 6  # Personagem
      character = get_character(@params[1])
      if character
        result = (character.direction == @params[2])
      end
    when 7  # Dinheiro
      case @params[2]
      when 0  # Maior ou igual
        result = ($game_party.gold >= @params[1])
      when 1  # Menor ou igual
        result = ($game_party.gold <= @params[1])
      when 2  # Menor
        result = ($game_party.gold < @params[1])
      end
    when 8  # Item
      result = $game_party.has_item?($data_items[@params[1]])
    when 9  # Arma
      result = $game_party.has_item?($data_weapons[@params[1]], @params[2])
    when 10  # Armadura
      result = $game_party.has_item?($data_armors[@params[1]], @params[2])
    when 11  # Tecla
      result = Input.press?(@params[1])
    when 12  # Script
      script = @params[1].gsub('@client', '$game_player')
      result = eval(script)
    when 13  # Veículo
      result = ($game_player.vehicle == $game_map.vehicles[@params[1]])
    end
    @branch[@indent] = result
    command_skip if !@branch[@indent]
  end
  #--------------------------------------------------------------------------
  # * Excessão
  #--------------------------------------------------------------------------
  def command_411
    command_skip if @branch[@indent]
  end
  #--------------------------------------------------------------------------
  # * Iniciar ciclo
  #--------------------------------------------------------------------------
  def command_112
  end
  #--------------------------------------------------------------------------
  # * Repetir acima
  #--------------------------------------------------------------------------
  def command_413
    begin
      @index -= 1
    end until @list[@index].indent == @indent
  end
  #--------------------------------------------------------------------------
  # * Romper ciclo
  #--------------------------------------------------------------------------
  def command_113
    loop do
      @index += 1
      return if @index >= @list.size - 1
      return if @list[@index].code == 413 && @list[@index].indent < @indent
    end
  end
  #--------------------------------------------------------------------------
  # * Sair do processamento do evento
  #--------------------------------------------------------------------------
  def command_115
    @index = @list.size
  end
  #--------------------------------------------------------------------------
  # * Chamar evento comum
  #--------------------------------------------------------------------------
  def command_117
    common_event = $data_common_events[@params[0]]
    if common_event
      child = Game_Interpreter.new(@depth + 1)
      child.setup(common_event.list, same_map? ? @event_id : 0)
      child.run
    end
  end
  #--------------------------------------------------------------------------
  # * Label
  #--------------------------------------------------------------------------
  def command_118
  end
  #--------------------------------------------------------------------------
  # * Ir para label
  #--------------------------------------------------------------------------
  def command_119
    label_name = @params[0]
    @list.size.times do |i|
      if @list[i].code == 118 && @list[i].parameters[0] == label_name
        @index = i
        return
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Controle de switches
  #--------------------------------------------------------------------------
  def command_121
    (@params[0]..@params[1]).each do |i|
      $game_switches[i] = (@params[2] == 0)
    end
  end
  #--------------------------------------------------------------------------
  # * Controle de variáveis
  #--------------------------------------------------------------------------
  def command_122
    value = 0
    case @params[3]  # Operando
    when 0  # Constante
      value = @params[4]
    when 1  # Variáveis
      value = $game_variables[@params[4]]
    when 2  # Aleatório
      value = @params[4] + rand(@params[5] - @params[4] + 1)
    when 3  # Informação do Jogo
      value = game_data_operand(@params[4], @params[5], @params[6])
    when 4  # Script
      value = eval(@params[4])
    end
    (@params[0]..@params[1]).each do |i|
      operate_variable(i, @params[2], value)
    end
  end
  #--------------------------------------------------------------------------
  # * Operando informações do jogo
  #--------------------------------------------------------------------------
  def game_data_operand(type, param1, param2)
    case type
    when 0  # Item
      return $game_party.item_number($data_items[param1])
    when 1  # Arma
      return $game_party.item_number($data_weapons[param1])
    when 2  # Armadura
      return $game_party.item_number($data_armors[param1])
    when 3  # Personagens
      actor = $game_actors[param1]
      if actor
        case param2
        when 0      # Nível
          return actor.level
        when 1      # Experiência
          return actor.exp
        when 2      # HP
          return actor.hp
        when 3      # MP
          return actor.mp
        when 4..11  # Parâmetro
          return actor.param(param2 - 4)
        end
      end
    when 4  # Inimigos
      enemy = $game_troop.members[param1]
      if enemy
        case param2
        when 0      # HP
          return enemy.hp
        when 1      # MP
          return enemy.mp
        when 2..9   # Parâmetro
          return enemy.param(param2 - 2)
        end
      end
    when 5  # Character
      character = get_character(param1)
      if character
        case param2
        when 0  # Coordenada X
          return character.x
        when 1  # Coordenada Y
          return character.y
        when 2  # Direção
          return character.direction
        when 3  # Coordenada  X na tela
          return character.screen_x
        when 4  # Coordenada  Y na tela
          return character.screen_y
        end
      end
    when 6  # Grupo
      actor = $game_party.members[param1]
      return actor ? actor.id : 0
    when 7  # Outros
      case param1
      when 0  # ID do mapa
        return $game_map.map_id
      when 1  # Número de membros no grupo
        return $game_party.members.size
      when 2  # Dinheiro
        return $game_party.gold
      when 3  # Passos
        return $game_party.steps
      when 4  # Tempo de jogo
        return Graphics.frame_count / Graphics.frame_rate
      when 5  # Cronômetro
        return $game_timer.sec
      when 6  # Número de saves
        return $game_system.save_count
      when 7  # Número de batalhas
        return $game_system.battle_count
      end
    end
    return 0
  end
  #--------------------------------------------------------------------------
  # * Operando variáveis
  #--------------------------------------------------------------------------
  def operate_variable(variable_id, operation_type, value)
    begin
      case operation_type
      when 0  # Substituição
        $game_variables[variable_id] = value
      when 1  # Soma
        $game_variables[variable_id] += value
      when 2  # Subtração
        $game_variables[variable_id] -= value
      when 3  # Multiplicação
        $game_variables[variable_id] *= value
      when 4  # Divisão
        $game_variables[variable_id] /= value
      when 5  # Resto
        $game_variables[variable_id] %= value
      end
    rescue
      $game_variables[variable_id] = 0
    end
  end
  #--------------------------------------------------------------------------
  # * Controle de switch local
  #--------------------------------------------------------------------------
  def command_123
    if @event_id > 0
      key = [@map_id, @event_id, @params[0]]
      $game_self_switches[key] = (@params[1] == 0)
    end
  end
=end
  #--------------------------------------------------------------------------
  # * Controle do cronômetro
  #--------------------------------------------------------------------------
  def command_124
    if @params[0] == 0  # Início
      $game_timer.start(@params[1] * Graphics.frame_rate)
    else                # Parada
      $game_timer.stop
    end
  end
=begin
  #--------------------------------------------------------------------------
  # * Mudança de dinheiro
  #--------------------------------------------------------------------------
  def command_125
    value = operate_value(@params[0], @params[1], @params[2])
    $game_party.gain_gold(value)
  end
  #--------------------------------------------------------------------------
  # * Mudança de itens
  #--------------------------------------------------------------------------
  def command_126
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_items[@params[0]], value)
  end
  #--------------------------------------------------------------------------
  # * Mudança de armas
  #--------------------------------------------------------------------------
  def command_127
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_weapons[@params[0]], value, @params[4])
  end
  #--------------------------------------------------------------------------
  # * Mudança de armaduras
  #--------------------------------------------------------------------------
  def command_128
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_armors[@params[0]], value, @params[4])
  end
  #--------------------------------------------------------------------------
  # * Mudança de grupo
  #--------------------------------------------------------------------------
  def command_129
    actor = $game_actors[@params[0]]
    if actor
      if @params[1] == 0    # Adicionar
        if @params[2] == 1  # Inicialização
          $game_actors[@params[0]].setup(@params[0])
        end
        $game_party.add_actor(@params[0])
      else                  # Remover
        $game_party.remove_actor(@params[0])
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Mudança de BGM de batalha
  #--------------------------------------------------------------------------
  def command_132
    $game_system.battle_bgm = @params[0]
  end
  #--------------------------------------------------------------------------
  # * Mudança de ME de fim de batalha
  #--------------------------------------------------------------------------
  def command_133
    $game_system.battle_end_me = @params[0]
  end
  #--------------------------------------------------------------------------
  # * Mudança de permissão de save
  #--------------------------------------------------------------------------
  def command_134
    $game_system.save_disabled = (@params[0] == 0)
  end
  #--------------------------------------------------------------------------
  # * Mudança de permissão de menu
  #--------------------------------------------------------------------------
  def command_135
    $game_system.menu_disabled = (@params[0] == 0)
  end
  #--------------------------------------------------------------------------
  # * Mudança de permissão de encontros
  #--------------------------------------------------------------------------
  def command_136
    $game_system.encounter_disabled = (@params[0] == 0)
    $game_player.make_encounter_count
  end
  #--------------------------------------------------------------------------
  # * Mudança de permissão de formação
  #--------------------------------------------------------------------------
  def command_137
    $game_system.formation_disabled = (@params[0] == 0)
  end
=end
  #--------------------------------------------------------------------------
  # * Mudança de cor da janela
  #--------------------------------------------------------------------------
  def command_138
    $game_system.window_tone = @params[0]
  end
=begin
  #--------------------------------------------------------------------------
  # * Transferência do jogador
  #--------------------------------------------------------------------------
  def command_201
    return if $game_party.in_battle
    Fiber.yield while $game_player.transfer? || $game_message.visible
    if @params[0] == 0                      # Definição direta
      map_id = @params[1]
      x = @params[2]
      y = @params[3]
    else                                    # Definição por variáveis
      map_id = $game_variables[@params[1]]
      x = $game_variables[@params[2]]
      y = $game_variables[@params[3]]
    end
    $game_player.reserve_transfer(map_id, x, y, @params[4])
    $game_temp.fade_type = @params[5]
    Fiber.yield while $game_player.transfer?
  end
  #--------------------------------------------------------------------------
  # Definir posição do veículo
  #--------------------------------------------------------------------------
  def command_202
    if @params[1] == 0                      # Definição direta
      map_id = @params[2]
      x = @params[3]
      y = @params[4]
    else                                    # Definição por variáveis
      map_id = $game_variables[@params[2]]
      x = $game_variables[@params[3]]
      y = $game_variables[@params[4]]
    end
    vehicle = $game_map.vehicles[@params[0]]
    vehicle.set_location(map_id, x, y) if vehicle
  end
  #--------------------------------------------------------------------------
  # Definir posição do evento
  #--------------------------------------------------------------------------
  def command_203
    character = get_character(@params[0])
    if character
      if @params[1] == 0                      # Definição direta
        character.moveto(@params[2], @params[3])
      elsif @params[1] == 1                   # Definição por variáveis
        new_x = $game_variables[@params[2]]
        new_y = $game_variables[@params[3]]
        character.moveto(new_x, new_y)
      else                                    # trocar com outro evento
        character2 = get_character(@params[2])
        character.swap(character2) if character2
      end
      character.set_direction(@params[4]) if @params[4] > 0
    end
  end
=end
  #--------------------------------------------------------------------------
  # * Rolagem do mapa
  #--------------------------------------------------------------------------
  def command_204
    return if $game_party.in_battle
    Fiber.yield while $game_map.scrolling?
    $game_map.start_scroll(@params[0], @params[1], @params[2])
  end
=begin
  #--------------------------------------------------------------------------
  # * Definir rota de movimento
  #--------------------------------------------------------------------------
  def command_205
    $game_map.refresh if $game_map.need_refresh
    character = get_character(@params[0])
    if character
      character.force_move_route(@params[1])
      Fiber.yield while character.move_route_forcing if @params[1].wait
    end
  end
  #--------------------------------------------------------------------------
  # * Embarcar/Desembarcar do veículo
  #--------------------------------------------------------------------------
  def command_206
    $game_player.get_on_off_vehicle
  end
=end
  #--------------------------------------------------------------------------
  # * Mudança de transparência
  #--------------------------------------------------------------------------
  def command_211
    $game_player.transparent = (@params[0] == 0)
  end
=begin
  #--------------------------------------------------------------------------
  # * Mostrar Animação
  #--------------------------------------------------------------------------
  def command_212
    character = get_character(@params[0])
    if character
      character.animation_id = @params[1]
      Fiber.yield while character.animation_id > 0 if @params[2]
    end
  end
  #--------------------------------------------------------------------------
  # * Mostrar ícone de emoção
  #--------------------------------------------------------------------------
  def command_213
    character = get_character(@params[0])
    if character
      character.balloon_id = @params[1]
      Fiber.yield while character.balloon_id > 0 if @params[2]
    end
  end
=end
  #--------------------------------------------------------------------------
  # * Apagar evento 
  #--------------------------------------------------------------------------
  def command_214
    $game_map.events[@event_id].erase if same_map? && @event_id > 0
  end
=begin
  #--------------------------------------------------------------------------
  # * Mudança de exibição de seguidores
  #--------------------------------------------------------------------------
  def command_216
    $game_player.followers.visible = (@params[0] == 0)
    $game_player.refresh
  end
  #--------------------------------------------------------------------------
  # * Reunir seguidores
  #--------------------------------------------------------------------------
  def command_217
    return if $game_party.in_battle
    $game_player.followers.gather
    Fiber.yield until $game_player.followers.gather?
  end
=end
  #--------------------------------------------------------------------------
  # * Fade out
  #--------------------------------------------------------------------------
  def command_221
    Fiber.yield while $game_message.visible
    screen.start_fadeout(30)
    wait(30)
  end
  #--------------------------------------------------------------------------
  # * Fade in
  #--------------------------------------------------------------------------
  def command_222
    Fiber.yield while $game_message.visible
    screen.start_fadein(30)
    wait(30)
  end
  #--------------------------------------------------------------------------
  # * Tonalidade de tela
  #--------------------------------------------------------------------------
  def command_223
    screen.start_tone_change(@params[0], @params[1])
    wait(@params[1]) if @params[2]
  end
  #--------------------------------------------------------------------------
  # * Efeito de flash
  #--------------------------------------------------------------------------
  def command_224
    screen.start_flash(@params[0], @params[1])
    wait(@params[1]) if @params[2]
  end
  #--------------------------------------------------------------------------
  # * Efeito de tremor
  #--------------------------------------------------------------------------
  def command_225
    screen.start_shake(@params[0], @params[1], @params[2])
    wait(@params[1]) if @params[2]
  end
=begin
  #--------------------------------------------------------------------------
  # * Tempo de espera
  #--------------------------------------------------------------------------
  def command_230
    wait(@params[0])
  end
=end
  #--------------------------------------------------------------------------
  # * Mostrar imagem
  #--------------------------------------------------------------------------
  def command_231
    if @params[3] == 0    # Definição direta
      x = @params[4]
      y = @params[5]
    else                  # Definição por variáveis
      x = $game_variables[@params[4]]
      y = $game_variables[@params[5]]
    end
    screen.pictures[@params[0]].show(@params[1], @params[2],
      x, y, @params[6], @params[7], @params[8], @params[9])
  end
  #--------------------------------------------------------------------------
  # * Mover imagem
  #--------------------------------------------------------------------------
  def command_232
    if @params[3] == 0    # Definição direta
      x = @params[4]
      y = @params[5]
    else                  # Definição por variáveis
      x = $game_variables[@params[4]]
      y = $game_variables[@params[5]]
    end
    screen.pictures[@params[0]].move(@params[2], x, y, @params[6],
      @params[7], @params[8], @params[9], @params[10])
    wait(@params[10]) if @params[11]
  end
  #--------------------------------------------------------------------------
  # * Rotação da imagem
  #--------------------------------------------------------------------------
  def command_233
    screen.pictures[@params[0]].rotate(@params[1])
  end
  #--------------------------------------------------------------------------
  # * Tonalidade da imagem
  #--------------------------------------------------------------------------
  def command_234
    screen.pictures[@params[0]].start_tone_change(@params[1], @params[2])
    wait(@params[2]) if @params[3]
  end
  #--------------------------------------------------------------------------
  # * Apagar imagem
  #--------------------------------------------------------------------------
  def command_235
    screen.pictures[@params[0]].erase
  end
  #--------------------------------------------------------------------------
  # * Definir efeito de clima
  #--------------------------------------------------------------------------
  def command_236
    return if $game_party.in_battle
    screen.change_weather(@params[0], @params[1], @params[2])
    wait(@params[2]) if @params[3]
  end
  #--------------------------------------------------------------------------
  # * Reproduzir BGM
  #--------------------------------------------------------------------------
  def command_241
    @params[0].play
  end
  #--------------------------------------------------------------------------
  # * Parar BGM
  #--------------------------------------------------------------------------
  def command_242
    RPG::BGM.fade(@params[0] * 1000)
  end
  #--------------------------------------------------------------------------
  # * Memorizar BGM
  #--------------------------------------------------------------------------
  def command_243
    $game_system.save_bgm
  end
  #--------------------------------------------------------------------------
  # * Continuar BGM
  #--------------------------------------------------------------------------
  def command_244
    $game_system.replay_bgm
  end
  #--------------------------------------------------------------------------
  # * Reproduzir BGS
  #--------------------------------------------------------------------------
  def command_245
    @params[0].play
  end
  #--------------------------------------------------------------------------
  # * Parar BGS
  #--------------------------------------------------------------------------
  def command_246
    RPG::BGS.fade(@params[0] * 1000)
  end
  #--------------------------------------------------------------------------
  # * Reproduzir ME
  #--------------------------------------------------------------------------
  def command_249
    @params[0].play
  end
  #--------------------------------------------------------------------------
  # * Reproduzir SE
  #--------------------------------------------------------------------------
  def command_250
    @params[0].play
  end
  #--------------------------------------------------------------------------
  # * Parar SE
  #--------------------------------------------------------------------------
  def command_251
    RPG::SE.stop
  end
  #--------------------------------------------------------------------------
  # * Reproduzir filme
  #--------------------------------------------------------------------------
  def command_261
    Fiber.yield while $game_message.visible
    Fiber.yield
    name = @params[0]
    Graphics.play_movie('Movies/' + name) unless name.empty?
  end
  #--------------------------------------------------------------------------
  # * Mudança de exibição de nome do mapa
  #--------------------------------------------------------------------------
  def command_281
    $game_map.name_display = (@params[0] == 0)
  end
  #--------------------------------------------------------------------------
  # * Mudança de tileset
  #--------------------------------------------------------------------------
  def command_282
    $game_map.change_tileset(@params[0])
  end
=begin
  #--------------------------------------------------------------------------
  # * Mudança de fundo de batalha
  #--------------------------------------------------------------------------
  def command_283
    $game_map.change_battleback(@params[0], @params[1])
  end
=end
  #--------------------------------------------------------------------------
  # * Mudança de panorama
  #--------------------------------------------------------------------------
  def command_284
    $game_map.change_parallax(@params[0], @params[1], @params[2],
                              @params[3], @params[4])
  end
=begin
  #--------------------------------------------------------------------------
  # * Aquisição das informações de uma posição específica
  #--------------------------------------------------------------------------
  def command_285
    if @params[2] == 0      # Definição direta
      x = @params[3]
      y = @params[4]
    else                    # Definição por variáveis
      x = $game_variables[@params[3]]
      y = $game_variables[@params[4]]
    end
    case @params[1]
    when 0      # ID de terreno
      value = $game_map.terrain_tag(x, y)
    when 1      # ID do evento
      value = $game_map.event_id_xy(x, y)
    when 2..4   # ID do tile
      value = $game_map.tile_id(x, y, @params[1] - 2)
    else        # ID da região
      value = $game_map.region_id(x, y)
    end
    $game_variables[@params[0]] = value
  end
  #--------------------------------------------------------------------------
  # * Processamento da batalha
  #--------------------------------------------------------------------------
  def command_301
    return if $game_party.in_battle
    if @params[0] == 0                      # Definição direta
      troop_id = @params[1]
    elsif @params[0] == 1                   # Definição por variáveis
      troop_id = $game_variables[@params[1]]
    else                                    # Grupo espefico do mapa
      troop_id = $game_player.make_encounter_troop_id
    end
    if $data_troops[troop_id]
      BattleManager.setup(troop_id, @params[2], @params[3])
      BattleManager.event_proc = Proc.new {|n| @branch[@indent] = n }
      $game_player.make_encounter_count
      SceneManager.call(Scene_Battle)
    end
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # * Se vencer
  #--------------------------------------------------------------------------
  def command_601
    command_skip if @branch[@indent] != 0
  end
  #--------------------------------------------------------------------------
  # * Se fugir
  #--------------------------------------------------------------------------
  def command_602
    command_skip if @branch[@indent] != 1
  end
  #--------------------------------------------------------------------------
  # * Se perder
  #--------------------------------------------------------------------------
  def command_603
    command_skip if @branch[@indent] != 2
  end
  #--------------------------------------------------------------------------
  # * Processamento da loja
  #--------------------------------------------------------------------------
  def command_302
    return if $game_party.in_battle
    goods = [@params]
    while next_event_code == 605
      @index += 1
      goods.push(@list[@index].parameters)
    end
    SceneManager.call(Scene_Shop)
    SceneManager.scene.prepare(goods, @params[4])
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # * Processamento da entrada de nome
  #--------------------------------------------------------------------------
  def command_303
    return if $game_party.in_battle
    if $data_actors[@params[0]]
      SceneManager.call(Scene_Name)
      SceneManager.scene.prepare(@params[0], @params[1])
      Fiber.yield
    end
  end
  #--------------------------------------------------------------------------
  # * Mudança de HP
  #--------------------------------------------------------------------------
  def command_311
    value = operate_value(@params[2], @params[3], @params[4])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      next if actor.dead?
      actor.change_hp(value, @params[5])
      actor.perform_collapse_effect if actor.dead?
    end
    SceneManager.goto(Scene_Gameover) if $game_party.all_dead?
  end
  #--------------------------------------------------------------------------
  # * Mudança de MP
  #--------------------------------------------------------------------------
  def command_312
    value = operate_value(@params[2], @params[3], @params[4])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.mp += value
    end
  end
  #--------------------------------------------------------------------------
  # * Mudança de estado
  #--------------------------------------------------------------------------
  def command_313
    iterate_actor_var(@params[0], @params[1]) do |actor|
      already_dead = actor.dead?
      if @params[2] == 0
        actor.add_state(@params[3])
      else
        actor.remove_state(@params[3])
      end
      actor.perform_collapse_effect if actor.dead? && !already_dead
    end
  end
  #--------------------------------------------------------------------------
  # * Curar tudo
  #--------------------------------------------------------------------------
  def command_314
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.recover_all
    end
  end
  #--------------------------------------------------------------------------
  # * Mudança de experiência
  #--------------------------------------------------------------------------
  def command_315
    value = operate_value(@params[2], @params[3], @params[4])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.change_exp(actor.exp + value, @params[5])
    end
  end
  #--------------------------------------------------------------------------
  # * Mudança de nível
  #--------------------------------------------------------------------------
  def command_316
    value = operate_value(@params[2], @params[3], @params[4])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.change_level(actor.level + value, @params[5])
    end
  end
  #--------------------------------------------------------------------------
  # * Mudança de parâmetros
  #--------------------------------------------------------------------------
  def command_317
    value = operate_value(@params[3], @params[4], @params[5])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.add_param(@params[2], value)
    end
  end
  #--------------------------------------------------------------------------
  # * Mudança de habilidades
  #--------------------------------------------------------------------------
  def command_318
    iterate_actor_var(@params[0], @params[1]) do |actor|
      if @params[2] == 0
        actor.learn_skill(@params[3])
      else
        actor.forget_skill(@params[3])
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Mudança de equipamentos
  #--------------------------------------------------------------------------
  def command_319
    actor = $game_actors[@params[0]]
    actor.change_equip_by_id(@params[1], @params[2]) if actor
  end
  #--------------------------------------------------------------------------
  # * Mudança de nome
  #--------------------------------------------------------------------------
  def command_320
    actor = $game_actors[@params[0]]
    actor.name = @params[1] if actor
  end
  #--------------------------------------------------------------------------
  # * Mudança de classe
  #--------------------------------------------------------------------------
  def command_321
    actor = $game_actors[@params[0]]
    actor.change_class(@params[1]) if actor && $data_classes[@params[1]]
  end
  #--------------------------------------------------------------------------
  # * Mudança de gráfico do personagem
  #--------------------------------------------------------------------------
  def command_322
    actor = $game_actors[@params[0]]
    if actor
      actor.set_graphic(@params[1], @params[2], @params[3], @params[4])
    end
    $game_player.refresh
  end
  #--------------------------------------------------------------------------
  # * Mudança de gráfico do veículo
  #--------------------------------------------------------------------------
  def command_323
    vehicle = $game_map.vehicles[@params[0]]
    vehicle.set_graphic(@params[1], @params[2]) if vehicle
  end
  #--------------------------------------------------------------------------
  # * Mudança de segundo nome
  #--------------------------------------------------------------------------
  def command_324
    actor = $game_actors[@params[0]]
    actor.nickname = @params[1] if actor
  end
  #--------------------------------------------------------------------------
  # * Mudança de HP do inimigo
  #--------------------------------------------------------------------------
  def command_331
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_enemy_index(@params[0]) do |enemy|
      return if enemy.dead?
      enemy.change_hp(value, @params[4])
      enemy.perform_collapse_effect if enemy.dead?
    end
  end
  #--------------------------------------------------------------------------
  # * Mudança de MP do inimigo
  #--------------------------------------------------------------------------
  def command_332
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.mp += value
    end
  end
  #--------------------------------------------------------------------------
  # * Mudança de estado do inimigo
  #--------------------------------------------------------------------------
  def command_333
    iterate_enemy_index(@params[0]) do |enemy|
      already_dead = enemy.dead?
      if @params[1] == 0
        enemy.add_state(@params[2])
      else
        enemy.remove_state(@params[2])
      end
      enemy.perform_collapse_effect if enemy.dead? && !already_dead
    end
  end
  #--------------------------------------------------------------------------
  # * Curar tudo (inimigos)
  #--------------------------------------------------------------------------
  def command_334
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.recover_all
    end
  end
  #--------------------------------------------------------------------------
  # * Aparecimento de inimigos
  #--------------------------------------------------------------------------
  def command_335
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.appear
      $game_troop.make_unique_names
    end
  end
  #--------------------------------------------------------------------------
  # * Transformação de inimigos
  #--------------------------------------------------------------------------
  def command_336
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.transform(@params[1])
      $game_troop.make_unique_names
    end
  end
  #--------------------------------------------------------------------------
  # * Mostrar animação de batalha
  #--------------------------------------------------------------------------
  def command_337
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.animation_id = @params[1] if enemy.alive?
    end
  end
  #--------------------------------------------------------------------------
  # * Forçar ação
  #--------------------------------------------------------------------------
  def command_339
    iterate_battler(@params[0], @params[1]) do |battler|
      next if battler.death_state?
      battler.force_action(@params[2], @params[3])
      BattleManager.force_action(battler)
      Fiber.yield while BattleManager.action_forced?
    end
  end
  #--------------------------------------------------------------------------
  # * Suspender combate
  #--------------------------------------------------------------------------
  def command_340
    BattleManager.abort
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # * Abrir menu principal
  #--------------------------------------------------------------------------
  def command_351
    return if $game_party.in_battle
    SceneManager.call(Scene_Menu)
    Window_MenuCommand::init_command_position
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # * Abrir menu de save
  #--------------------------------------------------------------------------
  def command_352
    return if $game_party.in_battle
    SceneManager.call(Scene_Save)
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # * Game Over
  #--------------------------------------------------------------------------
  def command_353
    SceneManager.goto(Scene_Gameover)
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # * Retornar à tela de título
  #--------------------------------------------------------------------------
  def command_354
    SceneManager.goto(Scene_Title)
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # * Chamar script
  #--------------------------------------------------------------------------
  def command_355
    script = @list[@index].parameters[0] + "\n"
    while next_event_code == 655
      @index += 1
      script += @list[@index].parameters[0] + "\n"
    end
    eval(script)
  end
=end
end
