#==============================================================================
# ** Game_CharacterBase
#------------------------------------------------------------------------------
#  Esta classe gerencia os personagens. Comum a todos os persongens, armazena
# informações básicas como coordenadas e gráficos
# Esta classe é usada como superclasse da classe Game_Character.
#==============================================================================

class Game_CharacterBase
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :id                       # ID
  attr_reader   :x                        # Coordenada X (Coordenada lógica)
  attr_reader   :y                        # Coordenada Y (Coordenada lógica)
  attr_reader   :real_x                   # Coordenada X (Coordenada real)
  attr_reader   :real_y                   # Coordenada X (Coordenada real)
  attr_reader   :tile_id                  # ID do terreno (0 se desativado)
  attr_reader   :character_name           # Nome do arquivo gráfico
  attr_reader   :character_index          # Índice do arquivo gráfico
  attr_reader   :move_speed               # Velocidade de movimento
  attr_reader   :move_frequency           # Frequência de movimento
  attr_reader   :walk_anime               # Amimação em movimento
  attr_reader   :step_anime               # Amimação parado
  attr_reader   :direction_fix            # Direção fixa
  attr_reader   :opacity                  # Opacidade
  attr_reader   :blend_type               # Sinteticidade
  attr_reader   :direction                # Direção
  attr_reader   :pattern                  # Padrão
  attr_reader   :priority_type            # Prioridade
  attr_reader   :through                  # Atravessar
  attr_reader   :bush_depth               # Altura do gramado
  attr_accessor :animation_id             # ID de animação
  attr_accessor :balloon_id               # ID de emoção
  attr_accessor :transparent              # Transparência
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #--------------------------------------------------------------------------
  def initialize
    init_public_members
    init_private_members
  end
  #--------------------------------------------------------------------------
  # * Inicialização de variáveis públicas
  #--------------------------------------------------------------------------
  def init_public_members
    @id = 0
    @x = 0
    @y = 0
    @real_x = 0
    @real_y = 0
    @tile_id = 0
    @character_name = ""
    @character_index = 0
    @move_speed = 4
    @move_frequency = 6
    @walk_anime = true
    @step_anime = false
    @direction_fix = false
    @opacity = 255
    @blend_type = 0
    @direction = 2
    @pattern = 1
    @priority_type = 1
    @through = false
    @bush_depth = 0
    @animation_id = 0
    @balloon_id = 0
    @transparent = false
  end
  #--------------------------------------------------------------------------
  # * Inicialização de variáveis privadas
  #--------------------------------------------------------------------------
  def init_private_members
    @original_direction = 2               # Direção original
    @original_pattern = 1                 # Padrão original
    @anime_count = 0                      # Contador de animação
    @stop_count = 0                       # Contador de parada
    @jump_count = 0                       # Contador de salto
    @jump_peak = 0                        # Pico da contagem de salto
    @locked = false                       # Travar
    @prelock_direction = 0                # Direção antes de travar
    @move_succeed = true                  # Sucesso do movimento
  end
  #--------------------------------------------------------------------------
  # * Definição de correspondência de coordenadas
  #     x : coordenada X
  #     y : coordenada Y
  #--------------------------------------------------------------------------
  def pos?(x, y)
    @x == x && @y == y
  end
  #--------------------------------------------------------------------------
  # * Definição de correspondência de coordenadas （sem atravessar）
  #     x : coordenada X
  #     y : coordenada Y
  #--------------------------------------------------------------------------
  def pos_nt?(x, y)
    pos?(x, y) && !@through
  end
  #--------------------------------------------------------------------------
  # * Definição de prioridade normal
  #--------------------------------------------------------------------------
  def normal_priority?
    @priority_type == 1
  end
  #--------------------------------------------------------------------------
  # * Definição de movimento
  #--------------------------------------------------------------------------
  def moving?
    @real_x != @x || @real_y != @y
  end
  #--------------------------------------------------------------------------
  # * Definição de salto
  #--------------------------------------------------------------------------
  def jumping?
    @jump_count > 0
  end
  #--------------------------------------------------------------------------
  # * Aquisição da altura do salto
  #--------------------------------------------------------------------------
  def jump_height
    (@jump_peak * @jump_peak - (@jump_count - @jump_peak).abs ** 2) / 2
  end
  #--------------------------------------------------------------------------
  # * Definição de parada
  #--------------------------------------------------------------------------
  def stopping?
    !moving? && !jumping?
  end
  #--------------------------------------------------------------------------
  # * Aquisição da velocidade de movimento (considerando corrida)
  #--------------------------------------------------------------------------
  def real_move_speed
    @move_speed + (dash? ? 1 : 0)
  end
  #--------------------------------------------------------------------------
  # * Cálculo da distância percorrida por quadro
  #--------------------------------------------------------------------------
  def distance_per_frame
    2 ** real_move_speed / 256.0
  end
  #--------------------------------------------------------------------------
  # * Definição de corrida
  #--------------------------------------------------------------------------
  def dash?
    return false
  end
=begin
  #--------------------------------------------------------------------------
  # * Definição de estado de atravessar durante debug
  #--------------------------------------------------------------------------
  def debug_through?
    return false
  end
=end
  #--------------------------------------------------------------------------
  # * Alinhamento
  #--------------------------------------------------------------------------
  def straighten
    @pattern = 1 if @walk_anime || @step_anime
    @anime_count = 0
  end
  #--------------------------------------------------------------------------
  # * Inverter direção
  #     d : direção （2,4,6,8）
  #--------------------------------------------------------------------------
  def reverse_dir(d)
    return 10 - d
  end
  #--------------------------------------------------------------------------
  # * Definição de passabilidade
  #     x : coordenada X
  #     y : coordenada Y
  #     d : direção （2,4,6,8）
  #--------------------------------------------------------------------------
  def passable?(x, y, d)
    x2 = $game_map.round_x_with_direction(x, d)
    y2 = $game_map.round_y_with_direction(y, d)
    return false unless $game_map.valid?(x2, y2)
    # VXA-OS
    return true if @through #|| debug_through?
    return false unless map_passable?(x, y, d)
    return false unless map_passable?(x2, y2, reverse_dir(d))
    return false if collide_with_characters?(x2, y2)
    return true
  end
  #--------------------------------------------------------------------------
  # * Definição de passabilidade diagonal
  #     horz : direção horizontal （4 or 6）
  #     vert : direção veritical  （2 or 8）
  #--------------------------------------------------------------------------
  def diagonal_passable?(x, y, horz, vert)
    x2 = $game_map.round_x_with_direction(x, horz)
    y2 = $game_map.round_y_with_direction(y, vert)
    (passable?(x, y, vert) && passable?(x, y2, horz)) ||
    (passable?(x, y, horz) && passable?(x2, y, vert))
  end
  #--------------------------------------------------------------------------
  # * Definição de passagem no mapa
  #     x : coordenada X
  #     y : coordenada Y
  #     d : direção （2,4,6,8）
  #--------------------------------------------------------------------------
  def map_passable?(x, y, d)
    $game_map.passable?(x, y, d)
  end
  #--------------------------------------------------------------------------
  # * Detectar colisão com personagens
  #     x : coordenada X
  #     y : coordenada Y
  #--------------------------------------------------------------------------
  def collide_with_characters?(x, y)
    collide_with_events?(x, y) || collide_with_vehicles?(x, y)
  end
  #--------------------------------------------------------------------------
  # * Detectar colisão com eventos
  #     x : coordenada X
  #     y : coordenada Y
  #--------------------------------------------------------------------------
  def collide_with_events?(x, y)
    $game_map.events_xy_nt(x, y).any? do |event|
      event.normal_priority? || self.is_a?(Game_Event)
    end
  end
  #--------------------------------------------------------------------------
  # * Detectar colisão com veículos
  #     x : coordenada X
  #     y : coordenada Y
  #--------------------------------------------------------------------------
  def collide_with_vehicles?(x, y)
    $game_map.boat.pos_nt?(x, y) || $game_map.ship.pos_nt?(x, y)
  end
  #--------------------------------------------------------------------------
  # * Mover para posição específica
  #     x : coordenada X
  #     y : coordenada Y
  #--------------------------------------------------------------------------
  def moveto(x, y)
    @x = x % $game_map.width
    @y = y % $game_map.height
    @real_x = @x
    @real_y = @y
    @prelock_direction = 0
    straighten
    update_bush_depth
  end
  #--------------------------------------------------------------------------
  # * Definição de direção
  #     d : direção （2,4,6,8）
  #--------------------------------------------------------------------------
  def set_direction(d)
    @direction = d if !@direction_fix && d != 0
    @stop_count = 0
  end
  #--------------------------------------------------------------------------
  # * Definição de tile
  #--------------------------------------------------------------------------
  def tile?
    @tile_id > 0 && @priority_type == 0
  end
  #--------------------------------------------------------------------------
  # * Definição de objeto do personagem
  #--------------------------------------------------------------------------
  def object_character?
    @tile_id > 0 || @character_name[0, 1] == '!'
  end
  #--------------------------------------------------------------------------
  # * Aquisição da mudança de posição sobre tile
  #--------------------------------------------------------------------------
  def shift_y
    object_character? ? 0 : 4
  end
  #--------------------------------------------------------------------------
  # * Definição de coordenada X na tela
  #--------------------------------------------------------------------------
  def screen_x
    $game_map.adjust_x(@real_x) * 32 + 16
  end
  #--------------------------------------------------------------------------
  # * Definição de coordenada Y na tela
  #--------------------------------------------------------------------------
  def screen_y
    $game_map.adjust_y(@real_y) * 32 + 32 - shift_y - jump_height
  end
  #--------------------------------------------------------------------------
  # * Definição de coordenada Z na tela
  #--------------------------------------------------------------------------
  def screen_z
    @priority_type * 100
  end
  #--------------------------------------------------------------------------
  # * Atualização da tela
  #--------------------------------------------------------------------------
  def update
    update_animation
    # VXA-OS
    select_player_target
    update_animate_attack
    return update_jump if jumping?
    return update_move if moving?
    return update_stop
  end
  #--------------------------------------------------------------------------
  # * Atualização do salto
  #--------------------------------------------------------------------------
  def update_jump
    @jump_count -= 1
    @real_x = (@real_x * @jump_count + @x) / (@jump_count + 1.0)
    @real_y = (@real_y * @jump_count + @y) / (@jump_count + 1.0)
    update_bush_depth
    if @jump_count == 0
      @real_x = @x = $game_map.round_x(@x)
      @real_y = @y = $game_map.round_y(@y)
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização do movimento
  #--------------------------------------------------------------------------
  def update_move
    @real_x = [@real_x - distance_per_frame, @x].max if @x < @real_x
    @real_x = [@real_x + distance_per_frame, @x].min if @x > @real_x
    @real_y = [@real_y - distance_per_frame, @y].max if @y < @real_y
    @real_y = [@real_y + distance_per_frame, @y].min if @y > @real_y
    update_bush_depth unless moving?
  end
  #--------------------------------------------------------------------------
  # * Atualização da parada
  #--------------------------------------------------------------------------
  def update_stop
    @stop_count += 1 unless @locked
  end
  #--------------------------------------------------------------------------
  # * Atualização da animação
  #--------------------------------------------------------------------------
  def update_animation
    update_anime_count
    if @anime_count > 18 - real_move_speed * 2
      update_anime_pattern
      @anime_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização do contador de animação
  #--------------------------------------------------------------------------
  def update_anime_count
    if moving? && @walk_anime
      @anime_count += 1.5
    elsif @step_anime || @pattern != @original_pattern
      @anime_count += 1
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização do padrão da animação
  #--------------------------------------------------------------------------
  def update_anime_pattern
    if !@step_anime && @stop_count > 0
      @pattern = @original_pattern
    else
      @pattern = (@pattern + 1) % 4
    end
  end
  #--------------------------------------------------------------------------
  # * Definição de escada
  #--------------------------------------------------------------------------
  def ladder?
    $game_map.ladder?(@x, @y)
  end
  #--------------------------------------------------------------------------
  # * Atualização da altura do gramado
  #--------------------------------------------------------------------------
  def update_bush_depth
    if normal_priority? && !object_character? && bush? && !jumping?
      @bush_depth = 8 unless moving?
    else
      @bush_depth = 0
    end
  end
  #--------------------------------------------------------------------------
  # * Definição de gramado
  #--------------------------------------------------------------------------
  def bush?
    $game_map.bush?(@x, @y)
  end
  #--------------------------------------------------------------------------
  # * Aquisição da ID do terreno
  #--------------------------------------------------------------------------
  def terrain_tag
    $game_map.terrain_tag(@x, @y)
  end
  #--------------------------------------------------------------------------
  # * Aquisição da ID da região
  #--------------------------------------------------------------------------
  def region_id
    $game_map.region_id(@x, @y)
  end
  #--------------------------------------------------------------------------
  # * Aumentar o número de passos
  #--------------------------------------------------------------------------
  def increase_steps
    set_direction(8) if ladder?
    @stop_count = 0
    update_bush_depth
  end
  #--------------------------------------------------------------------------
  # * Mudança de gráfico
  #     character_name  : novo nome do arquivo gráfico
  #     character_index : novo índice do arquivo gráfico
  #--------------------------------------------------------------------------
  def set_graphic(character_name, character_index)
    @tile_id = 0
    @character_name = character_name
    @character_index = character_index
    @original_pattern = 1
  end
=begin
  #--------------------------------------------------------------------------
  # * Definição de ativação de evento por toque a frente
  #--------------------------------------------------------------------------
  def check_event_trigger_touch_front
    x2 = $game_map.round_x_with_direction(@x, @direction)
    y2 = $game_map.round_y_with_direction(@y, @direction)
    check_event_trigger_touch(x2, y2)
  end
  #--------------------------------------------------------------------------
  # * Definição de ativação de evento por toque
  #     x : coordenada X
  #     y : coordenada Y
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    return false
  end
=end
  #--------------------------------------------------------------------------
  # * Movimento em linha reta em
  #     d       : direção （2,4,6,8）
  #     turn_ok : permissão para mudar de direção
  #--------------------------------------------------------------------------
  def move_straight(d, turn_ok = true)
    @move_succeed = passable?(@x, @y, d)
    if @move_succeed
      set_direction(d)
      @x = $game_map.round_x_with_direction(@x, d)
      @y = $game_map.round_y_with_direction(@y, d)
      @real_x = $game_map.x_with_direction(@x, reverse_dir(d))
      @real_y = $game_map.y_with_direction(@y, reverse_dir(d))
      increase_steps
    elsif turn_ok
      set_direction(d)
      #check_event_trigger_touch_front
    end
  end
  #--------------------------------------------------------------------------
  # * Movimento na diagonal
  #     horz : direção horizontal （4 or 6）
  #     vert : direção vertical   (2 or 8）
  #--------------------------------------------------------------------------
  def move_diagonal(horz, vert)
    @move_succeed = diagonal_passable?(x, y, horz, vert)
    if @move_succeed
      @x = $game_map.round_x_with_direction(@x, horz)
      @y = $game_map.round_y_with_direction(@y, vert)
      @real_x = $game_map.x_with_direction(@x, reverse_dir(horz))
      @real_y = $game_map.y_with_direction(@y, reverse_dir(vert))
      increase_steps
    end
    set_direction(horz) if @direction == reverse_dir(horz)
    set_direction(vert) if @direction == reverse_dir(vert)
  end
end
