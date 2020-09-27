#==============================================================================
# ** Game_Vehicle
#------------------------------------------------------------------------------
#  Esta classe gerencia veículos. Se não houver veículos no mapa atual, a
# coordenada é definida como (-1,-1).
# Esta classe é usada internamente pela classe Game_Map. 
#==============================================================================

class Game_Vehicle < Game_Character
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :altitude                 # Altura de vôo （para aeronave）
  attr_reader   :driving                  # Flag de execução
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #     type : Tipo de veículo （:boat, :ship, :airship）
  #--------------------------------------------------------------------------
  def initialize(type)
    super()
    @type = type
    @altitude = 0
    @driving = false
    @direction = 4
    @walk_anime = false
    @step_anime = false
    @walking_bgm = nil
    init_move_speed
    load_system_settings
  end
  #--------------------------------------------------------------------------
  # * Inicialização da velocidade
  #--------------------------------------------------------------------------
  def init_move_speed
    @move_speed = 4 if @type == :boat
    @move_speed = 5 if @type == :ship
    @move_speed = 6 if @type == :airship
  end
  #--------------------------------------------------------------------------
  # * Aquisição da configuração do sistema
  #--------------------------------------------------------------------------
  def system_vehicle
    return $data_system.boat    if @type == :boat
    return $data_system.ship    if @type == :ship
    return $data_system.airship if @type == :airship
    return nil
  end
  #--------------------------------------------------------------------------
  # * Carregamento das configuração do sistema
  #--------------------------------------------------------------------------
  def load_system_settings
    @map_id           = system_vehicle.start_map_id
    @x                = system_vehicle.start_x
    @y                = system_vehicle.start_y
    @character_name   = system_vehicle.character_name
    @character_index  = system_vehicle.character_index
  end
  #--------------------------------------------------------------------------
  # * Renovação
  #--------------------------------------------------------------------------
  def refresh
    if @driving
      @map_id = $game_map.map_id
      sync_with_player
    elsif @map_id == $game_map.map_id
      moveto(@x, @y)
    end
    if @type == :airship
      @priority_type = @driving ? 2 : 0
    else
      @priority_type = 1
    end
    @walk_anime = @step_anime = @driving
  end
  #--------------------------------------------------------------------------
  # * Definir posição
  #     map_id : ID do mapa
  #     x      : coordenada X
  #     y      : coordenada Y
  #--------------------------------------------------------------------------
  def set_location(map_id, x, y)
    @map_id = map_id
    @x = x
    @y = y
    refresh
  end
  #--------------------------------------------------------------------------
  # * Definição de correspondência de coordenadas
  #     x : coordenada X
  #     y : coordenada Y
  #--------------------------------------------------------------------------
  def pos?(x, y)
    @map_id == $game_map.map_id && super(x, y)
  end
  #--------------------------------------------------------------------------
  # * Definição de transparência
  #--------------------------------------------------------------------------
  def transparent
    @map_id != $game_map.map_id || super
  end
  #--------------------------------------------------------------------------
  # * Entrando no veículo
  #--------------------------------------------------------------------------
  def get_on
    @driving = true
    @walk_anime = true
    @step_anime = true
    @walking_bgm = RPG::BGM.last
    system_vehicle.bgm.play
  end
  #--------------------------------------------------------------------------
  # * Saindo no veículo
  #--------------------------------------------------------------------------
  def get_off
    @driving = false
    @walk_anime = false
    @step_anime = false
    @direction = 4
    @walking_bgm.play
  end
  #--------------------------------------------------------------------------
  # * Sincronização com o jogador
  #--------------------------------------------------------------------------
  def sync_with_player
    @x = $game_player.x
    @y = $game_player.y
    @real_x = $game_player.real_x
    @real_y = $game_player.real_y
    @direction = $game_player.direction
    update_bush_depth
  end
  #--------------------------------------------------------------------------
  # * Aquisição da velocidade
  #--------------------------------------------------------------------------
  def speed
    @move_speed
  end
  #--------------------------------------------------------------------------
  # * Definição de coordenada Y na tela
  #--------------------------------------------------------------------------
  def screen_y
    super - altitude
  end
  #--------------------------------------------------------------------------
  # * Definição de mobilidade
  #--------------------------------------------------------------------------
  def movable?
    !moving? && !(@type == :airship && @altitude < max_altitude)
  end
  #--------------------------------------------------------------------------
  # * Atualização da tela
  #--------------------------------------------------------------------------
  def update
    super
    update_airship_altitude if @type == :airship
  end
  #--------------------------------------------------------------------------
  # * Atualização da altutide da aeronave
  #--------------------------------------------------------------------------
  def update_airship_altitude
    if @driving
      @altitude += 1 if @altitude < max_altitude && takeoff_ok?
    elsif @altitude > 0
      @altitude -= 1
      @priority_type = 0 if @altitude == 0
    end
    @step_anime = (@altitude == max_altitude)
    @priority_type = 2 if @altitude > 0
  end
  #--------------------------------------------------------------------------
  # * Aquisição da altitude máxima da aeronave 
  #--------------------------------------------------------------------------
  def max_altitude
    return 32
  end
  #--------------------------------------------------------------------------
  # * Decidir permissão para partida
  #--------------------------------------------------------------------------
  def takeoff_ok?
    $game_player.followers.gather?
  end
  #--------------------------------------------------------------------------
  # * Definição de permissão de desembarque
  #     x : coordenada X
  #     y : coordenada Y
  #     d : direção （2,4,6,8）
  #--------------------------------------------------------------------------
  def land_ok?(x, y, d)
    if @type == :airship
      return false unless $game_map.airship_land_ok?(x, y)
      return false unless $game_map.events_xy(x, y).empty?
    else
      x2 = $game_map.round_x_with_direction(x, d)
      y2 = $game_map.round_y_with_direction(y, d)
      return false unless $game_map.valid?(x2, y2)
      return false unless $game_map.passable?(x2, y2, reverse_dir(d))
      return false if collide_with_characters?(x2, y2)
    end
    return true
  end
end
