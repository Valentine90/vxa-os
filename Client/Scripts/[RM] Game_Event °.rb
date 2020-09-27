#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
#  Esta classe gerencia os eventos. Ela controla funções incluindo a mudança
# de páginas de event por condições determinadas, e processos paralelos.
# Esta classe é usada internamente pela classe Game_Map. 
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :trigger                  # Desencadeador
  attr_reader   :list                     # lista de ações
  #attr_reader   :starting                 # Flag de execução
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #     event : RPG::Event
  #--------------------------------------------------------------------------
  def initialize(map_id, event)
    super()
    @map_id = map_id
    @event = event
    @id = @event.id
    moveto(@event.x, @event.y)
    refresh
  end
  #--------------------------------------------------------------------------
  # * Inicialização de variáveis públicas
  #--------------------------------------------------------------------------
  def init_public_members
    super
    @trigger = 0
    @list = nil
    #@starting = false
  end
  #--------------------------------------------------------------------------
  # * Inicialização de variáveis privadas
  #--------------------------------------------------------------------------
  def init_private_members
    super
    @move_type = 0                        # Tipo de movimento
    @erased = false                       # Evento apagado temporariamente
    # VXA-OS
    @quest_icon = false
    @page = nil                           # Página
  end
  #--------------------------------------------------------------------------
  # * Detectar colisão com personagens
  #     x : coordenada X
  #     y : coordenada Y
  #--------------------------------------------------------------------------
  def collide_with_characters?(x, y)
    super || collide_with_player_characters?(x, y)
  end
  #--------------------------------------------------------------------------
  # * Detectar colisão com jogadores
  #     x : coordenada X
  #     y : coordenada Y
  #--------------------------------------------------------------------------
  def collide_with_player_characters?(x, y)
    normal_priority? && $game_player.collide?(x, y)
  end
  #--------------------------------------------------------------------------
  # * Trava (parar o processamento de eventos em andamento)
  #--------------------------------------------------------------------------
  def lock
    unless @locked
      @prelock_direction = @direction
      turn_toward_player
      @locked = true
    end
  end
  #--------------------------------------------------------------------------
  # * Destravar
  #--------------------------------------------------------------------------
  def unlock
    if @locked
      @locked = false
      set_direction(@prelock_direction)
    end
  end
=begin
  #--------------------------------------------------------------------------
  # * Atualização da parada
  #--------------------------------------------------------------------------
  def update_stop
    super
    update_self_movement unless @move_route_forcing
  end
  #--------------------------------------------------------------------------
  # * Atualização de movimento
  #--------------------------------------------------------------------------
  def update_self_movement
    if near_the_screen? && @stop_count > stop_count_threshold
      case @move_type
      when 1;  move_type_random
      when 2;  move_type_toward_player
      when 3;  move_type_custom
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Definição de área visível da tela
  #     dx : determina área horizontal dentro da tela
  #     dy : determina área vertical dentro da tela
  #--------------------------------------------------------------------------
  def near_the_screen?(dx = 12, dy = 8)
    ax = $game_map.adjust_x(@real_x) - Graphics.width / 2 / 32
    ay = $game_map.adjust_y(@real_y) - Graphics.height / 2 / 32
    ax >= -dx && ax <= dx && ay >= -dy && ay <= dy
  end
  #--------------------------------------------------------------------------
  # * Cálculo do limite da contagem para iniciar o movimento automático
  #--------------------------------------------------------------------------
  def stop_count_threshold
    30 * (5 - @move_frequency)
  end
  #--------------------------------------------------------------------------
  # * Tipo de movimento : aleatório
  #--------------------------------------------------------------------------
  def move_type_random
    case rand(6)
    when 0..1;  move_random
    when 2..4;  move_forward
    when 5;     @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # * Tipo de movimento : em direção ao jogador
  #--------------------------------------------------------------------------
  def move_type_toward_player
    if near_the_player?
      case rand(6)
      when 0..3;  move_toward_player
      when 4;     move_random
      when 5;     move_forward
      end
    else
      move_random
    end
  end
  #--------------------------------------------------------------------------
  # * Definição de próximidade ao jogador
  #--------------------------------------------------------------------------
  def near_the_player?
    sx = distance_x_from($game_player.x).abs
    sy = distance_y_from($game_player.y).abs
    sx + sy < 20
  end
  #--------------------------------------------------------------------------
  # * Tipo de movimento : personalizado
  #--------------------------------------------------------------------------
  def move_type_custom
    update_routine_move
  end
  #--------------------------------------------------------------------------
  # * Limpando flag de execução
  #--------------------------------------------------------------------------
  def clear_starting_flag
    @starting = false
  end
  #--------------------------------------------------------------------------
  # * Definição de lista de execução vazia
  #--------------------------------------------------------------------------
  def empty?
    !@list || @list.size <= 1
  end
=end
  #--------------------------------------------------------------------------
  # * Definição de inclusão de qualquer desencadeador especificado
  #     triggers : desencadeadores
  #--------------------------------------------------------------------------
  def trigger_in?(triggers)
    triggers.include?(@trigger)
  end
=begin
  #--------------------------------------------------------------------------
  # * Inicialização do processo
  #--------------------------------------------------------------------------
  def start
    return if empty?
    @starting = true
    lock if trigger_in?([0,1,2])
  end
=end
  #--------------------------------------------------------------------------
  # * Apagar temporariamente
  #--------------------------------------------------------------------------
  def erase
    @erased = true
    refresh
  end
  #--------------------------------------------------------------------------
  # * Renovação
  #--------------------------------------------------------------------------
  def refresh
    new_page = @erased ? nil : find_proper_page
    setup_page(new_page) if !new_page || new_page != @page
    # VXA-OS
    refresh_quest_icon if new_page
  end
  #--------------------------------------------------------------------------
  # * Cumprir os critérios para encontrar a página de eventos
  #--------------------------------------------------------------------------
  def find_proper_page
    @event.pages.reverse.find {|page| conditions_met?(page) }
  end
  #--------------------------------------------------------------------------
  # * Definição de atendimento das condições de uma página
  #     page : página da condição
  #--------------------------------------------------------------------------
  def conditions_met?(page)
    c = page.condition
    if c.switch1_valid
      return false unless $game_switches[c.switch1_id]
    end
    if c.switch2_valid
      return false unless $game_switches[c.switch2_id]
    end
    if c.variable_valid
      return false if $game_variables[c.variable_id] < c.variable_value
    end
    if c.self_switch_valid
      key = [@map_id, @event.id, c.self_switch_ch]
      return false if $game_self_switches[key] != true
    end
    if c.item_valid
      item = $data_items[c.item_id]
      return false unless $game_party.has_item?(item)
    end
    if c.actor_valid
      actor = $game_actors[c.actor_id]
      return false unless $game_party.members.include?(actor)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Configurar nova página
  #     new_page : nova pagina
  #--------------------------------------------------------------------------
  def setup_page(new_page)
    @page = new_page
    if @page
      setup_page_settings
    else
      clear_page_settings
    end
    update_bush_depth
    #clear_starting_flag
    #check_event_trigger_auto
  end
  #--------------------------------------------------------------------------
  # * Limpeza das configurações da página
  #--------------------------------------------------------------------------
  def clear_page_settings
    @tile_id          = 0
    @character_name   = ""
    @character_index  = 0
    @move_type        = 0
    @through          = true
    # VXA-OS
    @boss             = false
    @trigger          = nil
    @list             = nil
    @interpreter      = nil
    @actor            = nil
  end
  #--------------------------------------------------------------------------
  # * Definir configurações da página
  #--------------------------------------------------------------------------
  def setup_page_settings
    @tile_id          = @page.graphic.tile_id
    @character_name   = @page.graphic.character_name
    @character_index  = @page.graphic.character_index
    if @original_direction != @page.graphic.direction
      @direction          = @page.graphic.direction
      @original_direction = @direction
      @prelock_direction  = 0
    end
    if @original_pattern != @page.graphic.pattern
      @pattern            = @page.graphic.pattern
      @original_pattern   = @pattern
    end
    @move_type          = @page.move_type
    @move_speed         = @page.move_speed
    @move_frequency     = @page.move_frequency
    @move_route         = @page.move_route
    @move_route_index   = 0
    @move_route_forcing = false
    @walk_anime         = @page.walk_anime
    @step_anime         = @page.step_anime
    @direction_fix      = @page.direction_fix
    @through            = @page.through
    @priority_type      = @page.priority_type
    @trigger            = @page.trigger
    @list               = @page.list
    @interpreter = @trigger == 4 ? Game_Interpreter.new : nil
    # VXA-OS
    setup_enemy_settings
  end
=begin
  #--------------------------------------------------------------------------
  # * Definição de ativação de evento por toque
  #     x : coordenada X
  #     y : coordenada Y
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    return if $game_map.interpreter.running?
    if @trigger == 2 && $game_player.pos?(x, y)
      start if !jumping? && normal_priority?
    end
  end
  #--------------------------------------------------------------------------
  # * Definição de ativação de evento automático
  #--------------------------------------------------------------------------
  def check_event_trigger_auto
    start if @trigger == 3
  end
=end
  #--------------------------------------------------------------------------
  # * Atualização da tela
  #--------------------------------------------------------------------------
  def update
    super
    #check_event_trigger_auto
    return unless @interpreter
    #@interpreter.setup(@list, @event.id) unless @interpreter.running?
    @interpreter.update
  end
end
