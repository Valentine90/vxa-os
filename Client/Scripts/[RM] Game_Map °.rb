#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  Esta classe gerencia o mapa. Inclui funções de rolagem e definição de 
# passagens. A instância desta classe é referenciada por $game_map.
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :screen                   # Estado da tela do mapa
  attr_reader   :interpreter              # Interpretador dos eventos
  attr_reader   :events                   # Lista de ventos
  attr_reader   :display_x                # Coordenada X de exibição
  attr_reader   :display_y                # Coordenada Y de exibição
  attr_reader   :parallax_name            # Arquivo de panorama
  attr_reader   :vehicles                 # Lista de veículos
  attr_reader   :battleback1_name         # Aarquivo de fundo de batalha (piso)
  attr_reader   :battleback2_name         # Aarquivo de fundo de batalha (parede)
  attr_accessor :name_display             # Flag de exibição do nome do mapa
  attr_accessor :need_refresh             # Flag de pedido de atualização
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #--------------------------------------------------------------------------
  def initialize
    @screen = Game_Screen.new
    @interpreter = Game_Interpreter.new
    @map_id = 0
    @events = {}
    @display_x = 0
    @display_y = 0
    create_vehicles
    @name_display = true
  end
  #--------------------------------------------------------------------------
  # * Configuração
  #     map_id : ID do mapa
  #--------------------------------------------------------------------------
  def setup(map_id)
    @map_id = map_id
    @map = load_data(sprintf("Data/Map%03d.rvdata2", @map_id))
    # VXA-OS
    if screen_tile_x > @map.width || screen_tile_y > @map.height
      msgbox("O mapa #{@map.display_name} é muito pequeno para a resolução atual. O tamanho mínimo do mapa deve ser: #{screen_tile_x}x#{screen_tile_y}.")
      exit
    end
    @tileset_id = @map.tileset_id
    @display_x = 0
    @display_y = 0
    referesh_vehicles
    setup_events
    setup_scroll
    setup_parallax
    setup_battleback
    @need_refresh = false
    # VXA-OS
    @pvp = pvp?
    @players = {}
    @drops = []
    @projectiles = []
  end
  #--------------------------------------------------------------------------
  # * Criação dos veículos
  #--------------------------------------------------------------------------
  def create_vehicles
    @vehicles = []
    @vehicles[0] = Game_Vehicle.new(:boat)
    @vehicles[1] = Game_Vehicle.new(:ship)
    @vehicles[2] = Game_Vehicle.new(:airship)
  end
  #--------------------------------------------------------------------------
  # * Atualização dos veículos
  #--------------------------------------------------------------------------
  def referesh_vehicles
    @vehicles.each {|vehicle| vehicle.refresh }
  end
  #--------------------------------------------------------------------------
  # * Aquisição do veículo
  #     type : tipo do veículo
  #--------------------------------------------------------------------------
  def vehicle(type)
    return @vehicles[0] if type == :boat
    return @vehicles[1] if type == :ship
    return @vehicles[2] if type == :airship
    return nil
  end
  #--------------------------------------------------------------------------
  # * Aquisição das informações do barco
  #--------------------------------------------------------------------------
  def boat
    @vehicles[0]
  end
  #--------------------------------------------------------------------------
  # * Aquisição das informações do navio
  #--------------------------------------------------------------------------
  def ship
    @vehicles[1]
  end
  #--------------------------------------------------------------------------
  # * Aquisição das informações da aeronave
  #--------------------------------------------------------------------------
  def airship
    @vehicles[2]
  end
  #--------------------------------------------------------------------------
  # * Configuração dos eventos
  #--------------------------------------------------------------------------
  def setup_events
    @events = {}
    @map.events.each do |i, event|
      @events[i] = Game_Event.new(@map_id, event)
    end
=begin
    @common_events = parallel_common_events.collect do |common_event|
      Game_CommonEvent.new(common_event.id)
    end
=end
    refresh_tile_events
  end
=begin
  #--------------------------------------------------------------------------
  # * Lista de eventos comuns em processo paralelo
  #--------------------------------------------------------------------------
  def parallel_common_events
    $data_common_events.select {|event| event && event.parallel? }
  end
=end
  #--------------------------------------------------------------------------
  # * Configuração do scroll
  #--------------------------------------------------------------------------
  def setup_scroll
    @scroll_direction = 2
    @scroll_rest = 0
    @scroll_speed = 4
  end
  #--------------------------------------------------------------------------
  # * Configuração do panorama
  #--------------------------------------------------------------------------
  def setup_parallax
    @parallax_name = @map.parallax_name
    @parallax_loop_x = @map.parallax_loop_x
    @parallax_loop_y = @map.parallax_loop_y
    @parallax_sx = @map.parallax_sx
    @parallax_sy = @map.parallax_sy
    @parallax_x = 0
    @parallax_y = 0
  end
  #--------------------------------------------------------------------------
  # * Configuração do fundo de batalha
  #--------------------------------------------------------------------------
  def setup_battleback
    if @map.specify_battleback
      @battleback1_name = @map.battleback1_name
      @battleback2_name = @map.battleback2_name
    else
      @battleback1_name = nil
      @battleback2_name = nil
    end
  end
  #--------------------------------------------------------------------------
  # * Definir a posição de exibição
  #     x : coordenada X de exibição
  #     y : coordenada Y de exibição
  #--------------------------------------------------------------------------
  def set_display_pos(x, y)
    x = [0, [x, width - screen_tile_x].min].max unless loop_horizontal?
    y = [0, [y, height - screen_tile_y].min].max unless loop_vertical?
    @display_x = (x + width) % width
    @display_y = (y + height) % height
    @parallax_x = x
    @parallax_y = y
  end
  #--------------------------------------------------------------------------
  # * Cálculo da coordenada X do panorama
  #     bitmap : bitmap do panorama
  #--------------------------------------------------------------------------
  def parallax_ox(bitmap)
    if @parallax_loop_x
      @parallax_x * 16
    else
      w1 = [bitmap.width - Graphics.width, 0].max
      w2 = [width * 32 - Graphics.width, 1].max
      @parallax_x * 16 * w1 / w2
    end
  end
  #--------------------------------------------------------------------------
  # * Cálculo da coordenada Y do panorama
  #     bitmap : bitmap do panorama
  #--------------------------------------------------------------------------
  def parallax_oy(bitmap)
    if @parallax_loop_y
      @parallax_y * 16
    else
      h1 = [bitmap.height - Graphics.height, 0].max
      h2 = [height * 32 - Graphics.height, 1].max
      @parallax_y * 16 * h1 / h2
    end
  end
  #--------------------------------------------------------------------------
  # * Aquisição da ID do mapa
  #--------------------------------------------------------------------------
  def map_id
    @map_id
  end
  #--------------------------------------------------------------------------
  # * Aquisição do tileset do mapa
  #--------------------------------------------------------------------------
  def tileset
    $data_tilesets[@tileset_id]
  end
  #--------------------------------------------------------------------------
  # * Nome de exibição
  #--------------------------------------------------------------------------
  def display_name
    @map.display_name
  end
  #--------------------------------------------------------------------------
  # * Largura do mapa
  #--------------------------------------------------------------------------
  def width
    @map.width
  end
  #--------------------------------------------------------------------------
  # * Altura do mapa
  #--------------------------------------------------------------------------
  def height
    @map.height
  end
  #--------------------------------------------------------------------------
  # * Definição de loop horizontal
  #--------------------------------------------------------------------------
  def loop_horizontal?
    @map.scroll_type == 2 || @map.scroll_type == 3
  end
  #--------------------------------------------------------------------------
  # * Definição de loop vertical
  #--------------------------------------------------------------------------
  def loop_vertical?
    @map.scroll_type == 1 || @map.scroll_type == 3
  end
  #--------------------------------------------------------------------------
  # * Definição de desabilitação de corrida
  #--------------------------------------------------------------------------
  def disable_dash?
    @map.disable_dashing
  end
  #--------------------------------------------------------------------------
  # * Lista de encontros do mapa
  #--------------------------------------------------------------------------
  def encounter_list
    @map.encounter_list
  end
  #--------------------------------------------------------------------------
  # * Aquisição do contador de passos
  #--------------------------------------------------------------------------
  def encounter_step
    @map.encounter_step
  end
  #--------------------------------------------------------------------------
  # * Aquisição dos dados do mapa
  #--------------------------------------------------------------------------
  def data
    @map.data
  end
  #--------------------------------------------------------------------------
  # * Definição de tipo de tileset
  #--------------------------------------------------------------------------
  def overworld?
    tileset.mode == 0
  end
  #--------------------------------------------------------------------------
  # * Aquisição do números de tiles horizontais na tela
  #--------------------------------------------------------------------------
  def screen_tile_x
    Graphics.width / 32
  end
  #--------------------------------------------------------------------------
  # * Aquisição do números de tiles verticais na tela
  #--------------------------------------------------------------------------
  def screen_tile_y
    Graphics.height / 32
  end
  #--------------------------------------------------------------------------
  # * Cálculo de ajuste da coordenada X padrão
  #     x : coordenada X
  #--------------------------------------------------------------------------
  def adjust_x(x)
    if loop_horizontal? && x < @display_x - (width - screen_tile_x) / 2
      x - @display_x + @map.width
    else
      x - @display_x
    end
  end
  #--------------------------------------------------------------------------
  # * Cálculo de ajuste da coordenada Y padrão
  #     y : coordenada Y
  #--------------------------------------------------------------------------
  def adjust_y(y)
    if loop_vertical? && y < @display_y - (height - screen_tile_y) / 2
      y - @display_y + @map.height
    else
      y - @display_y
    end
  end
  #--------------------------------------------------------------------------
  # * Cálculo da coordenada X após o loop
  #     x : coordenada X
  #--------------------------------------------------------------------------
  def round_x(x)
    loop_horizontal? ? (x + width) % width : x
  end
  #--------------------------------------------------------------------------
  # * Cálculo da coordenada Y após o loop
  #     y : coordenada Y
  #--------------------------------------------------------------------------
  def round_y(y)
    loop_vertical? ? (y + height) % height : y
  end
  #--------------------------------------------------------------------------
  # * Cálculo da coordenada X para direção
  #     x : coordenada X
  #     d : direção (2,4,6,8)
  #--------------------------------------------------------------------------
  def x_with_direction(x, d)
    x + (d == 6 ? 1 : d == 4 ? -1 : 0)
  end
  #--------------------------------------------------------------------------
  # * Cálculo da coordenada Y para direção
  #     y : coordenada Y
  #     d : direção (2,4,6,8)
  #--------------------------------------------------------------------------
  def y_with_direction(y, d)
    y + (d == 2 ? 1 : d == 8 ? -1 : 0)
  end
  #--------------------------------------------------------------------------
  # * Cálculo da coordenada X para direção após o loop
  #     x : coordenada X
  #     d : direção (2,4,6,8)
  #--------------------------------------------------------------------------
  def round_x_with_direction(x, d)
    round_x(x + (d == 6 ? 1 : d == 4 ? -1 : 0))
  end
  #--------------------------------------------------------------------------
  # * Cálculo da coordenada Y para direção após o loop
  #     y : coordenada Y
  #     d : direção (2,4,6,8)
  #--------------------------------------------------------------------------
  def round_y_with_direction(y, d)
    round_y(y + (d == 2 ? 1 : d == 8 ? -1 : 0))
  end
  #--------------------------------------------------------------------------
  # * Reprodução automática de BGM / BGS
  #--------------------------------------------------------------------------
  def autoplay
    @map.bgm.play if @map.autoplay_bgm
    @map.bgs.play if @map.autoplay_bgs
  end
  #--------------------------------------------------------------------------
  # * Renovação
  #--------------------------------------------------------------------------
  def refresh
    @events.each_value {|event| event.refresh }
    #@common_events.each {|event| event.refresh }
    refresh_tile_events
    @need_refresh = false
  end
  #--------------------------------------------------------------------------
  # * Atualização dos eventos de tileset
  #--------------------------------------------------------------------------
  def refresh_tile_events
    @tile_events = @events.values.select {|event| event.tile? }
  end
  #--------------------------------------------------------------------------
  # * Lista dos eventos localizados na posição definida
  #     x : coordenada X
  #     y : coordenada Y
  #--------------------------------------------------------------------------
  def events_xy(x, y)
    @events.values.select {|event| event.pos?(x, y) }
  end
  #--------------------------------------------------------------------------
  # * Lista dos eventos localizados na posição definida (sem atravessar)
  #     x : coordenada X
  #     y : coordenada Y
  #--------------------------------------------------------------------------
  def events_xy_nt(x, y)
    @events.values.select {|event| event.pos_nt?(x, y) }
  end
  #--------------------------------------------------------------------------
  # * Lista dos eventos de tileset localizados na posição definida
  #     x : coordenada X
  #     y : coordenada Y
  #--------------------------------------------------------------------------
  def tile_events_xy(x, y)
    @tile_events.select {|event| event.pos_nt?(x, y) }
  end
  #--------------------------------------------------------------------------
  # * Lista ID dos eventos localizados na posição definida
  #     x : coordenada X
  #     y : coordenada Y
  #--------------------------------------------------------------------------
  def event_id_xy(x, y)
    list = events_xy(x, y)
    list.empty? ? 0 : list[0].id
  end
  #--------------------------------------------------------------------------
  # * Rolagem para baixo
  #     distance : distância
  #--------------------------------------------------------------------------
  def scroll_down(distance)
    if loop_vertical?
      @display_y += distance
      @display_y %= @map.height
      @parallax_y += distance if @parallax_loop_y
    else
      last_y = @display_y
      @display_y = [@display_y + distance, height - screen_tile_y].min
      @parallax_y += @display_y - last_y
    end
  end
  #--------------------------------------------------------------------------
  # * Rolagem para esquerda
  #     distance : distância
  #--------------------------------------------------------------------------
  def scroll_left(distance)
    if loop_horizontal?
      @display_x += @map.width - distance
      @display_x %= @map.width 
      @parallax_x -= distance if @parallax_loop_x
    else
      last_x = @display_x
      @display_x = [@display_x - distance, 0].max
      @parallax_x += @display_x - last_x
    end
  end
  #--------------------------------------------------------------------------
  # * Rolagem para direita
  #     distance : distância
  #--------------------------------------------------------------------------
  def scroll_right(distance)
    if loop_horizontal?
      @display_x += distance
      @display_x %= @map.width
      @parallax_x += distance if @parallax_loop_x
    else
      last_x = @display_x
      @display_x = [@display_x + distance, (width - screen_tile_x)].min
      @parallax_x += @display_x - last_x
    end
  end
  #--------------------------------------------------------------------------
  # * Rolagem para cima
  #     distance : distância
  #--------------------------------------------------------------------------
  def scroll_up(distance)
    if loop_vertical?
      @display_y += @map.height - distance
      @display_y %= @map.height
      @parallax_y -= distance if @parallax_loop_y
    else
      last_y = @display_y
      @display_y = [@display_y - distance, 0].max
      @parallax_y += @display_y - last_y
    end
  end
  #--------------------------------------------------------------------------
  # * Definição de coordenada válida
  #     x : coordenada X
  #     y : coordenada Y
  #--------------------------------------------------------------------------
  def valid?(x, y)
    x >= 0 && x < width && y >= 0 && y < height
  end
  #--------------------------------------------------------------------------
  # * Definição de passabilidade
  #     x   : coordenada X
  #     y   : coordenada Y
  #     bit : chechar bloqueio de passagem
  #--------------------------------------------------------------------------
  def check_passage(x, y, bit)
    all_tiles(x, y).each do |tile_id|
      flag = tileset.flags[tile_id]
      next if flag & 0x10 != 0            # [*] : Não altera passagem
      return true  if flag & bit == 0     # [○] : Permite passagem
      return false if flag & bit == bit   # [×] : Bloqueia passagem
    end
    return false                          # Bloquear passagem
  end
  #--------------------------------------------------------------------------
  # * Aquisição da ID do tile na coordenada especificada
  #     x   : coordenada X
  #     y   : coordenada Y
  #     z   : tipo de terrno
  #--------------------------------------------------------------------------
  def tile_id(x, y, z)
    @map.data[x, y, z] || 0
  end
  #--------------------------------------------------------------------------
  # * Lista de tiles na coordenada especificada
  #     x   : coordenada X
  #     y   : coordenada Y
  #--------------------------------------------------------------------------
  def layered_tiles(x, y)
    [2, 1, 0].collect {|z| tile_id(x, y, z) }
  end
  #--------------------------------------------------------------------------
  # * Lista de tiles (incluindo eventos) na coordenada especificada
  #     x   : coordenada X
  #     y   : coordenada Y
  #--------------------------------------------------------------------------
  def all_tiles(x, y)
    tile_events_xy(x, y).collect {|ev| ev.tile_id } + layered_tiles(x, y)
  end
  #--------------------------------------------------------------------------
  # * Aquisição do tipo do autotile na coordenada especificada
  #     x   : coordenada X
  #     y   : coordenada Y
  #     z   : tipo de terrno
  #--------------------------------------------------------------------------
  def autotile_type(x, y, z)
    tile_id(x, y, z) >= 2048 ? (tile_id(x, y, z) - 2048) / 48 : -1
  end
  #--------------------------------------------------------------------------
  # * Definição de passabilidade
  #     x   : coordenada X
  #     y   : coordenada Y
  #     d : direção （2,4,6,8）
  #--------------------------------------------------------------------------
  def passable?(x, y, d)
    check_passage(x, y, (1 << (d / 2 - 1)) & 0x0f)
  end
  #--------------------------------------------------------------------------
  # * Definição de passabilidade do barco
  #     x : coordenada X
  #     y : coordenada Y
  #--------------------------------------------------------------------------
  def boat_passable?(x, y)
    check_passage(x, y, 0x0200)
  end
  #--------------------------------------------------------------------------
  # * Definição de passabilidade do navio
  #     x : coordenada X
  #     y : coordenada Y
  #--------------------------------------------------------------------------
  def ship_passable?(x, y)
    check_passage(x, y, 0x0400)
  end
  #--------------------------------------------------------------------------
  # * Definição de passabilidade da aeronave
  #     x : coordenada X
  #     y : coordenada Y
  #--------------------------------------------------------------------------
  def airship_land_ok?(x, y)
    check_passage(x, y, 0x0800) && check_passage(x, y, 0x0f)
  end
  #--------------------------------------------------------------------------
  # * Flag de camada de tiles na coordenada especificada
  #     x   : coordenada X
  #     y   : coordenada Y
  #     bit : chechar bloqueio de passagem
  #--------------------------------------------------------------------------
  def layered_tiles_flag?(x, y, bit)
    layered_tiles(x, y).any? {|tile_id| tileset.flags[tile_id] & bit != 0 }
  end
  #--------------------------------------------------------------------------
  # * Definição de escada
  #     x   : coordenada X
  #     y   : coordenada Y
  #--------------------------------------------------------------------------
  def ladder?(x, y)
    valid?(x, y) && layered_tiles_flag?(x, y, 0x20)
  end
  #--------------------------------------------------------------------------
  # * Definição de gramado
  #     x   : coordenada X
  #     y   : coordenada Y
  #--------------------------------------------------------------------------
  def bush?(x, y)
    valid?(x, y) && layered_tiles_flag?(x, y, 0x40)
  end
  #--------------------------------------------------------------------------
  # * Definição de balcão
  #     x   : coordenada X
  #     y   : coordenada Y
  #--------------------------------------------------------------------------
  def counter?(x, y)
    valid?(x, y) && layered_tiles_flag?(x, y, 0x80)
  end
  #--------------------------------------------------------------------------
  # * Definição de terreno de dano
  #     x   : coordenada X
  #     y   : coordenada Y
  #--------------------------------------------------------------------------
  def damage_floor?(x, y)
    valid?(x, y) && layered_tiles_flag?(x, y, 0x100)
  end
  #--------------------------------------------------------------------------
  # * Definição de ID do terreno
  #     x   : coordenada X
  #     y   : coordenada Y
  #--------------------------------------------------------------------------
  def terrain_tag(x, y)
    return 0 unless valid?(x, y)
    layered_tiles(x, y).each do |tile_id|
      tag = tileset.flags[tile_id] >> 12
      return tag if tag > 0
    end
    return 0
  end
  #--------------------------------------------------------------------------
  # * Definição de ID da região
  #     x   : coordenada X
  #     y   : coordenada Y
  #--------------------------------------------------------------------------
  def region_id(x, y)
    valid?(x, y) ? @map.data[x, y, 3] >> 8 : 0
  end
  #--------------------------------------------------------------------------
  # * Início da rolagem
  #     direction : direção da rolagem
  #     distance  : distância da rolagem
  #     speed     : velocidade da rolagem
  #--------------------------------------------------------------------------
  def start_scroll(direction, distance, speed)
    @scroll_direction = direction
    @scroll_rest = distance
    @scroll_speed = speed
  end
  #--------------------------------------------------------------------------
  # * Definição de rolagem
  #--------------------------------------------------------------------------
  def scrolling?
    @scroll_rest > 0
  end
  #--------------------------------------------------------------------------
  # * Atualização da tela
  #     main : flag de atualização do interpreter
  #--------------------------------------------------------------------------
  def update(main = false)
    refresh if @need_refresh
    update_interpreter if main
    update_scroll
    update_events
    update_vehicles
    update_parallax
    @screen.update
  end
  #--------------------------------------------------------------------------
  # * Atualização da rolagem
  #--------------------------------------------------------------------------
  def update_scroll
    return unless scrolling?
    last_x = @display_x
    last_y = @display_y
    do_scroll(@scroll_direction, scroll_distance)
    if @display_x == last_x && @display_y == last_y
      @scroll_rest = 0
    else
      @scroll_rest -= scroll_distance
    end
  end
  #--------------------------------------------------------------------------
  # * Definição de distância da rolagem
  #--------------------------------------------------------------------------
  def scroll_distance
    2 ** @scroll_speed / 256.0
  end
  #--------------------------------------------------------------------------
  # * Execução da rolagem
  #     direction : direção da rolagem
  #     distance  : distância da rolagem
  #--------------------------------------------------------------------------
  def do_scroll(direction, distance)
    case direction
    when 2;  scroll_down (distance)
    when 4;  scroll_left (distance)
    when 6;  scroll_right(distance)
    when 8;  scroll_up   (distance)
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização do eventos
  #--------------------------------------------------------------------------
  def update_events
    @events.each_value {|event| event.update }
    #@common_events.each {|event| event.update }
  end
  #--------------------------------------------------------------------------
  # * Atualização dos veículos
  #--------------------------------------------------------------------------
  def update_vehicles
    @vehicles.each {|vehicle| vehicle.update }
  end
  #--------------------------------------------------------------------------
  # * Atualização do panorama
  #--------------------------------------------------------------------------
  def update_parallax
    @parallax_x += @parallax_sx / 64.0 if @parallax_loop_x
    @parallax_y += @parallax_sy / 64.0 if @parallax_loop_y
  end
  #--------------------------------------------------------------------------
  # * Mudança de tileset
  #     tileset_id : ID do tileset
  #--------------------------------------------------------------------------
  def change_tileset(tileset_id)
    @tileset_id = tileset_id
    refresh
  end
  #--------------------------------------------------------------------------
  # * Mudança de fundo de batalha
  #     battleback1_name : nome do arquivo gráfico (chão)
  #     battleback2_name : nome do arquivo gráfico (parede)
  #--------------------------------------------------------------------------
  def change_battleback(battleback1_name, battleback2_name)
    @battleback1_name = battleback1_name
    @battleback2_name = battleback2_name
  end
  #--------------------------------------------------------------------------
  # * Mudança de panorama
  #     name   : nome do arquivo gráfico
  #     loop_x : flag de repetição horizontal
  #     loop_y : flag de repetição vertical
  #     sx     : movimento do horizontal do panorama
  #     sy     : movimento do vartical do panorama
  #--------------------------------------------------------------------------
  def change_parallax(name, loop_x, loop_y, sx, sy)
    @parallax_name = name
    @parallax_x = 0 if @parallax_loop_x && !loop_x
    @parallax_y = 0 if @parallax_loop_y && !loop_y
    @parallax_loop_x = loop_x
    @parallax_loop_y = loop_y
    @parallax_sx = sx
    @parallax_sy = sy
  end
  #--------------------------------------------------------------------------
  # * Atualiazação do interpretador
  #--------------------------------------------------------------------------
  def update_interpreter
    loop do
      @interpreter.update
      return if @interpreter.running?
      if @interpreter.event_id > 0
        unlock_event(@interpreter.event_id)
        @interpreter.clear
      end
      return unless setup_starting_event
    end
  end
  #--------------------------------------------------------------------------
  # * Desbloqueio de eventos
  #     event_id : id do evento
  #--------------------------------------------------------------------------
  def unlock_event(event_id)
    @events[event_id].unlock if @events[event_id]
  end
  #--------------------------------------------------------------------------
  # * Configuração de evento em inicio
  #--------------------------------------------------------------------------
  def setup_starting_event
    refresh if @need_refresh
    #return true if @interpreter.setup_reserved_common_event
    #return true if setup_starting_map_event
    #return true if setup_autorun_common_event
    return false
  end
=begin
  #--------------------------------------------------------------------------
  # * Definição de presença de eventos em execução
  #--------------------------------------------------------------------------
  def any_event_starting?
    @events.values.any? {|event| event.starting }
  end
  #--------------------------------------------------------------------------
  # * Configuração de eventos iniciais do mapa
  #--------------------------------------------------------------------------
  def setup_starting_map_event
    event = @events.values.find {|event| event.starting }
    event.clear_starting_flag if event
    @interpreter.setup(event.list, event.id) if event
    event
  end
  #--------------------------------------------------------------------------
  # * Configuração de eventos com início automatico
  #--------------------------------------------------------------------------
  def setup_autorun_common_event
    event = $data_common_events.find do |event|
      event && event.autorun? && $game_switches[event.switch_id]
    end
    @interpreter.setup(event.list) if event
    event
  end
=end
end
