#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  Esta classe lida com um interpretador para executar os comandos de evento.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Game_Interpreter
  
  COMMAND_TABLE = {
    101 => :show_message,
    102 => :show_choice,
    103 => :store_number,
    104 => :select_item,
    105 => :show_scrolling_text,
    111 => :condition,
    113 => :break_cycle,
    115 => :stop_event,
    117 => :common_event,
    119 => :go_to_label,
    121 => :change_switch,
    122 => :change_variable,
    123 => :change_self_switches,
    124 => :default_event_command,
    125 => :change_gold,
    126 => :change_item,
    127 => :change_weapon,
    128 => :change_armor,
    138 => :default_event_command,
    201 => :transfer_player,
    203 => :change_event_position,
    204 => :default_event_command,
    212 => :show_animation,
    213 => :show_balloon,
    221 => :default_event_command,
    222 => :default_event_command,
    223 => :screen_tint,
    224 => :flash_effect,
    225 => :tremor_effect,
    230 => :wait,
    231 => :default_event_command,
    232 => :move_image,
    233 => :default_event_command,
    234 => :image_tone,
    235 => :default_event_command,
    236 => :climate_options,
    241 => :default_event_command,
    242 => :default_event_command,
    243 => :default_event_command,
    244 => :default_event_command,
    245 => :default_event_command,
    246 => :default_event_command,
    249 => :default_event_command,
    250 => :default_event_command,
    251 => :default_event_command,
    261 => :default_event_command,
    282 => :default_event_command,
    284 => :default_event_command,
    285 => :position_information,
    302 => :open_shop,
    311 => :change_hp,
    312 => :change_mp,
    313 => :change_state,
    314 => :recover_all,
    315 => :change_exp,
    316 => :change_level,
    317 => :change_param,
    318 => :change_skill,
    319 => :change_equip,
    321 => :change_class,
    322 => :change_graphic,
    353 => :game_over,
    355 => :call_script,
    402 => :choice,
    403 => :cancel,
    411 => :exception,
    413 => :repeat_above
  }

  attr_reader   :fiber
  
  def setup(client, list, event_id = 0, object = nil)
    @client = client
    # Salva o ID do mapa inicial, pois o jogador pode ser transferido
    #para outro mapa durante a execução dos comandos
    @map_id = @client.map_id if @client
    @event_id = event_id
    @list = list
    @object = object
    @index = 0
    @branch = {}
    @fiber = Fiber.new { run }
    @fiber.resume
  end

  def run
    while @list[@index] do
      execute_command
      @index += 1
    end
    finalize
  end

  def running?
    @fiber
  end
  
  def finalize
    @fiber = nil
    # Se o ID do evento é maior que 0 e não é o processo paralelo dos eventos que está sendo finalizado
    $network.maps[@map_id].events[@event_id].unlock(@client.id) if @event_id > 0 && @client
  end

  def execute_command
    # Se é um evento do mapa com condição de início processo paralelo
    return if !@client && ![111, 113, 115, 117, 119, 121, 124, 138, 203, 204, 213, 221, 222, 223, 224, 225, 230, 231, 232, 233, 234, 235, 236, 241, 242, 243, 244, 245, 246, 249, 250, 251, 261, 282, 284, 355, 411, 413].include?(@list[@index].code) 
    command = @list[@index]
    @params = command.parameters
    @indent = command.indent
    method_name = COMMAND_TABLE[command.code]
    send(method_name) if method_name
  end

  def command_skip
    @index += 1 while @list[@index + 1].indent > @indent
  end

  def next_event_code
    @list[@index + 1].code
  end

  def get_character(param)
    param < 0 ? @client : $network.maps[@map_id].events[param > 0 ? param : @event_id]
  end

  def operate_value(operation, operand_type, operand)
    value = operand_type == 0 ? operand : @client.variables[operand]
    operation == 0 ? value : -value
  end

  def default_event_command(initial_index = @index, final_index = @index + 1)
    if @client
      $network.send_event_command(@client, @event_id, initial_index, final_index)
    # Se é um evento do mapa com condição de início processo paralelo
    else
      $network.send_parallel_process_command(@object, initial_index, final_index)
    end
  end
  
  def show_message
    initial_index = @index
    @client.message_interpreter = self
    @index += 1 while next_event_code == 401
    case next_event_code
    when 102
      @index += 1
      $network.send_event_command(@client, @event_id, initial_index, @index)
      # Passa os parâmetros da lista para o setup_choices antes que @params seja resetado quando
      #o @fiber.resume for executado, após o Fiber.yield, nas mensagens de evento sem face
      setup_choices(@list[@index].parameters)
    when 103
      @index += 1
      $network.send_event_command(@client, @event_id, initial_index, @index)
      setup_num_input(@list[@index].parameters)
    when 104
      @index += 1
      $network.send_event_command(@client, @event_id, initial_index, @index)
      setup_item_choice(@list[@index].parameters)
    else
      $network.send_event_command(@client, @event_id, initial_index, @index)
      Fiber.yield
    end
  end

  def show_choice
    @client.message_interpreter = self
    default_event_command
    setup_choices(@params)
  end

  def setup_choices(params)
    Fiber.yield
    @branch[@indent] = [@client.choice, params[0].size].min
    @client.close_event_message
  end

  def store_number
    @client.message_interpreter = self
    default_event_command
    setup_num_input(@params)
  end

  def setup_num_input(params)
    Fiber.yield
    @client.variables[params[0]] = [@client.choice, 99_999_999].min
    @client.close_event_message
  end

  def select_item
    @client.message_interpreter = self
    default_event_command
    setup_item_choice(@params)
  end

  def setup_item_choice(params)
    Fiber.yield
    @client.variables[params[0]] = [@client.choice, $data_items.size].min
    @client.close_event_message
  end

  def show_scrolling_text
    initial_index = @index
    @index += 1 while next_event_code == 405
    $network.send_event_command(@client, @event_id, initial_index, @index)
  end

  def choice
    command_skip if @branch[@indent] != @params[0]
  end

  def cancel
    command_skip if @branch[@indent] != 4
  end

  def condition
    result = false
    case @params[0]
    when 0
      result = (@client.switches[@params[1]] == (@params[2] == 0)) if @params[1] <= Configs::MAX_PLAYER_SWITCHES
      result = ($network.switches[@params[1]] == (@params[2] == 0)) if @params[1] > Configs::MAX_PLAYER_SWITCHES
    when 1
      value1 = @client.variables[@params[1]]
      value2 = @params[2] == 0 ? @params[3] : @client.variables[@params[3]]
      case @params[4]
      when 0
        result = (value1 == value2)
      when 1
        result = (value1 >= value2)
      when 2
        result = (value1 <= value2)
      when 3
        result = (value1 > value2)
      when 4
        result = (value1 < value2)
      when 5
        result = (value1 != value2)
      end
    when 2
      if @event_id > 0
        key = [@map_id, @event_id, @params[1]]
        result = (@client.self_switches[key] == (@params[2] == 0))
      end
    when 4
      case @params[2]
      when 1
        result = (@client.name == @params[3])
      when 2
        result = (@client.class_id == @params[3])
      when 3
        result = (@client.skill_learn?(@params[3]))
      when 4
        result = (@client.weapon_id == @params[3])
      when 5
        result = (@client.equips[1, Configs::MAX_EQUIPS - 1].include?(@params[3]))
      when 6
        result = (@client.state?(@params[3]))
      end
    when 6
      character = get_character(@params[1])
      result = (character.direction == @params[2]) if character
    when 7
      case @params[2]
      when 0
        result = (@client.gold >= @params[1])
      when 1
        result = (@client.gold <= @params[1])
      when 2
        result = (@client.gold < @params[1])
      end
    when 8
      result = @client.has_item?($data_items[@params[1]])
    when 9
      result = @client.has_item?($data_weapons[@params[1]], @params[2])
    when 10
      result = @client.has_item?($data_armors[@params[1]], @params[2])
    when 12
      result = eval(@params[1])
    end
    @branch[@indent] = result
    command_skip if !@branch[@indent]
  end

  def exception
    command_skip if @branch[@indent]
  end

  def repeat_above
    begin
      @index -= 1
    end until @list[@index].indent == @indent
  end

  def break_cycle
    while true
      @index += 1
      return if @index >= @list.size - 1
      return if @list[@index].code == 413 && @list[@index].indent < @indent
    end
  end

  def stop_event
    @index = @list.size
  end

  def common_event
    common_event = $data_common_events[@params[0]]
    if common_event
      child = Game_Interpreter.new
      child.setup(@client, common_event.list, @event_id)
      child.run
    end
  end

  def go_to_label
    label_name = @params[0]
    @list.size.times do |i|
      if @list[i].code == 118 && @list[i].parameters[0] == label_name
        @index = i
        break
      end
    end
  end

  def change_switch
    value = (@params[2] == 0)
    (@params[0]..@params[1]).each do |switch_id|
      object = switch_id <= Configs::MAX_PLAYER_SWITCHES ? @client : $network
      object.switches[switch_id] = value
    end
  end

  def change_variable
    value = 0
    case @params[3]
    when 0
      value = @params[4]
    when 1
      value = @client.variables[@params[4]]
    when 2
      value = @params[4] + rand(@params[5] - @params[4] + 1)
    when 3
      value = game_data_operand(@params[4], @params[5], @params[6])
    when 4
      value = eval(@params[4])
    end
    # Muda individualmente a variável, já que a alteração
    #múltipla (desde x até y) não funciona
    operate_variable(@params[0], @params[2], value)
  end

  def game_data_operand(type, param1, param2)
    case type
    when 0
      return @client.item_number($data_items[param1])
    when 1
      return @client.item_number($data_weapons[param1])
    when 2
      return @client.item_number($data_armors[param1])
    when 3
      case param2
      when 0
        return @client.level
      when 1
        return @client.exp
      when 2
        return @client.hp
      when 3
        return @client.mp
      when 4..11
        return @client.param(param2 - 4)
      end
    when 5
      character = get_character(param1)
      if character
        case param2
        when 0
          return character.x
        when 1
          return character.y
        when 2
          return character.direction
        end
      end
    when 7
      case param1
      when 0
        return @client.map_id
      when 2
        return @client.gold
      end
    end
    0
  end

  def operate_variable(variable_id, operation_type, value)
    begin
      case operation_type
      when 0
        @client.variables[variable_id] = value
      when 1
        @client.variables[variable_id] += value
      when 2
        @client.variables[variable_id] -= value
      when 3
        @client.variables[variable_id] *= value
      when 4
        @client.variables[variable_id] /= value
      when 5
        @client.variables[variable_id] %= value
      end
    rescue
      @client.variables[variable_id] = 0
    end
  end

  def change_self_switches
    return if @event_id == 0
    key = [@map_id, @event_id, @params[0]]
    @client.self_switches[key] = (@params[1] == 0)
  end

  def change_gold
    value = operate_value(@params[0], @params[1], @params[2])
    @client.gain_gold(value, false, @params[0] == 0)
  end

  def change_item
    value = operate_value(@params[1], @params[2], @params[3])
    if @client.full_inventory?($data_items[@params[0]]) && value > 0
      $network.maps[@client.map_id].add_drop(@params[0], 1, value, @client.x, @client.y, @client.name)
      return
    end
    @client.gain_item($data_items[@params[0]], value, false, value > 0)
    # Se o jogador colocou o item na troca para não perdê-lo
    @client.lose_trade_item($data_items[@params[0]], value.abs) if @client.in_trade? && value < 0
  end

  def change_weapon
    value = operate_value(@params[1], @params[2], @params[3])
    if @client.full_inventory?($data_weapons[@params[0]]) && value > 0
      $network.maps[@client.map_id].add_drop(@params[0], 2, value, @client.x, @client.y, @client.name)
      return
    end
    @client.gain_item($data_weapons[@params[0]], value, false, value > 0)
    @client.lose_trade_item($data_weapons[@params[0]], value.abs) if @client.in_trade? && value < 0
  end

  def change_armor
    value = operate_value(@params[1], @params[2], @params[3])
    if @client.full_inventory?($data_armors[@params[0]]) && value > 0
      $network.maps[@client.map_id].add_drop(@params[0], 3, value, @client.x, @client.y, @client.name)
      return
    end
    @client.gain_item($data_armors[@params[0]], value, false, value > 0)
    @client.lose_trade_item($data_armors[@params[0]], value.abs) if @client.in_trade? && value < 0
  end

  def transfer_player
    if @params[0] == 0
      map_id = @params[1]
      x = @params[2]
      y = @params[3]
    else
      map_id = @client.variables[@params[1]]
      x = @client.variables[@params[2]]
      y = @client.variables[@params[3]]
    end
    @client.transfer(map_id, x, y, @params[4])
  end

  def change_event_position
    character = get_character(@params[0])
    return unless character
    character.direction = @params[4] if @params[4] > 0
    if @params[1] == 0
      character.moveto(@params[2], @params[3])
    elsif @params[1] == 1
      new_x = @client.variables[@params[2]]
      new_y = @client.variables[@params[3]]
      character.moveto(new_x, new_y)
    else
      character2 = get_character(@params[2])
      character.swap(character2) if character2
    end
  end
  
  def show_animation
    character = get_character(@params[0])
    type = @params[0] >= 0 ? Enums::Target::ENEMY : Enums::Target::PLAYER
    $network.send_animation(character, @params[1], character.id, type - 1, 8, type) if character
    wait($data_animations[@params[1]].frame_max * 4 + 1) if @params[2]
  end

  def show_balloon
    character = get_character(@params[0])
    type = character.is_a?(Game_Client) ? Enums::Target::PLAYER : Enums::Target::ENEMY
    $network.send_balloon(character, type, @params[1]) if character
    wait(76) if @params[2]
  end

  def screen_tint
    default_event_command
    wait(@params[1]) if @params[2]
  end

  def flash_effect
    default_event_command
    wait(@params[1]) if @params[2]
  end

  def tremor_effect
    default_event_command
    wait(@params[2]) if @params[3]
  end
  
  def wait(duration = @params[0])
    # Se o Processo Paralelo é a Condição de Início do evento
    if @object.is_a?(Game_Event)
      @object.parallel_process_waiting = Interpreter.new(nil, nil, @index + 1, Time.now + duration / 60)
    # Se o Esperar decorreu de uma interação do jogador com o evento, e não de um
    #item/habilidade ou de um evento comum com condição de início processo paralelo
    elsif @event_id > 0 && !@object
      @client.waiting_event = Interpreter.new(@list, @event_id, @index + 1, Time.now + duration / 60)
    # Evento comum
    else
      @client.parallel_events_waiting[@object.id] = Interpreter.new(nil, nil, @index + 1, Time.now + duration / 60)
    end
    Fiber.yield
  end

  def move_image
    default_event_command
    wait(@params[10]) if @params[11]
  end

  def image_tone
    default_event_command
    wait(@params[2]) if @params[3]
  end

  def climate_options
    default_event_command
    wait(@params[2]) if @params[3]
  end

  def position_information
    if @params[2] == 0
      x = @params[3]
      y = @params[4]
    else
      x = @client.variables[@params[3]]
      y = @client.variables[@params[4]]
    end
    case @params[1]
    when 0
      value = $network.maps[@map_id].terrain_tag(x, y)
    when 1
      value = $network.maps[@map_id].event_id_xy(x, y)
    when 2..4
      value = $network.maps[@map_id].tile_id(x, y, @params[1] - 2)
    else
      value = $network.maps[@map_id].region_id(x, y)
    end
    @client.variables[@params[0]] = value
  end

  def open_shop
    goods = [@params]
    initial_index = @index
    while next_event_code == 605
      @index += 1
      goods << @list[@index].parameters
    end
    unless @client.in_trade? || @client.in_bank?
      @client.open_shop(goods, @event_id, initial_index)
      Fiber.yield
    end
  end

  def change_hp
    value = operate_value(@params[2], @params[3], @params[4])
    @client.hp += value
  end

  def change_mp
    value = operate_value(@params[2], @params[3], @params[4])
    @client.mp += value
  end

  def change_state
    if @params[2] == 0
      @client.add_state(@params[3])
    else
      @client.remove_state(@params[3])
    end
  end

  def recover_all
    @client.recover_all
  end

  def change_exp
    value = operate_value(@params[2], @params[3], @params[4])
    @client.change_exp(@client.exp + value)
  end

  def change_level
    value = operate_value(@params[2], @params[3], @params[4])
    @client.change_level(@client.level + value)
  end

  def change_param
    value = operate_value(@params[3], @params[4], @params[5])
    @client.add_param(@params[2], value)
  end

  def change_skill
    if @params[2] == 0
      @client.learn_skill(@params[3])
    else
      @client.forget_skill(@params[3])
    end
  end

  def change_equip
    @client.change_equip(@params[1], @params[2])
  end

  def change_class
    @client.change_class(@params[1])
  end

  def change_graphic
    @client.set_graphic(@params[1], @params[2], @params[3], @params[4])
  end

  def game_over
    @client.die
  end

  def call_script
    initial_index = @index
    script = "#{@list[@index].parameters[0]}\n"
    while next_event_code == 655
      @index += 1
      script << "#{@list[@index].parameters[0]}\n"
    end
    if script.start_with?('[NG]')
      default_event_command(initial_index, @index)
    else
      eval(script)
    end
  end

  def chat_add(message, color_id)
    $network.player_chat_message(@client, message, color_id)
  end

  def check_point(map_id, x, y)
    @client.check_point(map_id, x, y)
  end

  def start_quest(quest_id)
		# Reduz o índice que foi configurado com um inteiro a mais
		#nos comandos de evento
    @client.start_quest(quest_id - 1)
  end

  def finish_quest(quest_id)
    @client.finish_quest(quest_id - 1)
  end

  def open_teleport(teleport_id)
    @client.open_teleport(teleport_id - 1)
    Fiber.yield
  end

  def open_bank
    # Carrega os itens comprados na loja toda vez que abre o banco,
    #pois o jogador pode ter comprado o item durante o jogo
    Database.load_distributor(@client)
    @client.open_bank
    Fiber.yield
  end

  def open_create_guild
    @client.open_create_guild
    # Se o jogador não está em uma guilda
    Fiber.yield if @client.creating_guild?
  end

end
