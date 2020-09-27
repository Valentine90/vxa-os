#==============================================================================
# ** Game_Character
#------------------------------------------------------------------------------
#  Esta classe gerencia os personagens. Esta classe é usada como superclasse das
# classes Game_Player, Game_Follower,GameVehicle e Game_Event
#==============================================================================

class Game_Character < Game_CharacterBase
  #--------------------------------------------------------------------------
  # * Constantes
  #--------------------------------------------------------------------------
  ROUTE_END               = 0             # Final da rota de movimento
  ROUTE_MOVE_DOWN         = 1             # Mover para baixo
  ROUTE_MOVE_LEFT         = 2             # Mover para esqueda
  ROUTE_MOVE_RIGHT        = 3             # Mover para direita
  ROUTE_MOVE_UP           = 4             # Mover para cima
  ROUTE_MOVE_LOWER_L      = 5             # Mover para inferior esquerda
  ROUTE_MOVE_LOWER_R      = 6             # Mover para inferior direita
  ROUTE_MOVE_UPPER_L      = 7             # Mover para superior esquerda
  ROUTE_MOVE_UPPER_R      = 8             # Mover para superior direita
  ROUTE_MOVE_RANDOM       = 9             # Mover aleatóriamente
  ROUTE_MOVE_TOWARD       = 10            # Mover para perto
  ROUTE_MOVE_AWAY         = 11            # Mover para longe
  ROUTE_MOVE_FORWARD      = 12            # Mover para frente
  ROUTE_MOVE_BACKWARD     = 13            # Mover para trás
  ROUTE_JUMP              = 14            # Pular
  ROUTE_WAIT              = 15            # Esperar
  ROUTE_TURN_DOWN         = 16            # Olhar para baixo
  ROUTE_TURN_LEFT         = 17            # Olhar para esquerda
  ROUTE_TURN_RIGHT        = 18            # Olhar para direita
  ROUTE_TURN_UP           = 19            # Olhar para cima
  ROUTE_TURN_90D_R        = 20            # Rotação de 90° para a direita
  ROUTE_TURN_90D_L        = 21            # Rotação de 90° para a esquerda
  ROUTE_TURN_180D         = 22            # Rotação de 180°
  ROUTE_TURN_90D_R_L      = 23            # Rotação de 90° aleatória
  ROUTE_TURN_RANDOM       = 24            # Olhar aleatóriamente
  ROUTE_TURN_TOWARD       = 25            # Olhar para perto
  ROUTE_TURN_AWAY         = 26            # Olhar pata longe
  ROUTE_SWITCH_ON         = 27            # Switch ON
  ROUTE_SWITCH_OFF        = 28            # Switch OFF
  ROUTE_CHANGE_SPEED      = 29            # Mudança de velocidade
  ROUTE_CHANGE_FREQ       = 30            # Mudança de frequência
  ROUTE_WALK_ANIME_ON     = 31            # Animação em movimento ON
  ROUTE_WALK_ANIME_OFF    = 32            # Animação em movimento OFF
  ROUTE_STEP_ANIME_ON     = 33            # Animação parado ON
  ROUTE_STEP_ANIME_OFF    = 34            # Animação parado OFF
  ROUTE_DIR_FIX_ON        = 35            # Direção fixa ON
  ROUTE_DIR_FIX_OFF       = 36            # Direção fixa OFF
  ROUTE_THROUGH_ON        = 37            # Atravessar ON
  ROUTE_THROUGH_OFF       = 38            # Atravessar OFF
  ROUTE_TRANSPARENT_ON    = 39            # Transparência ON
  ROUTE_TRANSPARENT_OFF   = 40            # Transparência OFF
  ROUTE_CHANGE_GRAPHIC    = 41            # Mudança de gráfico
  ROUTE_CHANGE_OPACITY    = 42            # Mudança de opacidade
  ROUTE_CHANGE_BLENDING   = 43            # Mudança de sinteticidade
  ROUTE_PLAY_SE           = 44            # Tocar SE
  ROUTE_SCRIPT            = 45            # Script
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :move_route_forcing       # Rota de movimento forçada
  #--------------------------------------------------------------------------
  # * Inicialização de variáveis públicas
  #--------------------------------------------------------------------------
  def init_public_members
    super
    @move_route_forcing = false
  end
  #--------------------------------------------------------------------------
  # * Inicialização de variáveis privadas
  #--------------------------------------------------------------------------
  def init_private_members
    super
    @move_route = nil                     # Rota de movimento
    @move_route_index = 0                 # Índice da rota de movimento
    @original_move_route = nil            # Rota original de movimento
    @original_move_route_index = 0        # Índice original da rota de movimento
    @wait_count = 0                       # Contador de espera
  end
  #--------------------------------------------------------------------------
  # * Armazenar rota de movimento
  #--------------------------------------------------------------------------
  def memorize_move_route
    @original_move_route        = @move_route
    @original_move_route_index  = @move_route_index
  end
  #--------------------------------------------------------------------------
  # * Restaurar rota de movimento
  #--------------------------------------------------------------------------
  def restore_move_route
    @move_route           = @original_move_route
    @move_route_index     = @original_move_route_index
    @original_move_route  = nil
  end
  #--------------------------------------------------------------------------
  # * Rota de movimento forçada
  #    move_route : rota de movimento
  #--------------------------------------------------------------------------
  def force_move_route(move_route)
    memorize_move_route unless @original_move_route
    @move_route = move_route
    @move_route_index = 0
    @move_route_forcing = true
    @prelock_direction = 0
    @wait_count = 0
  end
  #--------------------------------------------------------------------------
  # * Atualização da parada
  #--------------------------------------------------------------------------
  def update_stop
    super
    update_routine_move if @move_route_forcing
  end
  #--------------------------------------------------------------------------
  # * Atualização do movimento ao longo da rota
  #--------------------------------------------------------------------------
  def update_routine_move
    if @wait_count > 0
      @wait_count -= 1
    else
      @move_succeed = true
      command = @move_route.list[@move_route_index]
      if command
        process_move_command(command)
        advance_move_route_index
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Processamento do comando de movimento
  #     command : comando
  #--------------------------------------------------------------------------
  def process_move_command(command)
    params = command.parameters
    case command.code
    when ROUTE_END;               process_route_end
    when ROUTE_MOVE_DOWN;         move_straight(2)
    when ROUTE_MOVE_LEFT;         move_straight(4)
    when ROUTE_MOVE_RIGHT;        move_straight(6)
    when ROUTE_MOVE_UP;           move_straight(8)
    when ROUTE_MOVE_LOWER_L;      move_diagonal(4, 2)
    when ROUTE_MOVE_LOWER_R;      move_diagonal(6, 2)
    when ROUTE_MOVE_UPPER_L;      move_diagonal(4, 8)
    when ROUTE_MOVE_UPPER_R;      move_diagonal(6, 8)
    when ROUTE_MOVE_RANDOM;       move_random
    when ROUTE_MOVE_TOWARD;       move_toward_player
    when ROUTE_MOVE_AWAY;         move_away_from_player
    when ROUTE_MOVE_FORWARD;      move_forward
    when ROUTE_MOVE_BACKWARD;     move_backward
    when ROUTE_JUMP;              jump(params[0], params[1])
    when ROUTE_WAIT;              @wait_count = params[0] - 1
    when ROUTE_TURN_DOWN;         set_direction(2)
    when ROUTE_TURN_LEFT;         set_direction(4)
    when ROUTE_TURN_RIGHT;        set_direction(6)
    when ROUTE_TURN_UP;           set_direction(8)
    when ROUTE_TURN_90D_R;        turn_right_90
    when ROUTE_TURN_90D_L;        turn_left_90
    when ROUTE_TURN_180D;         turn_180
    when ROUTE_TURN_90D_R_L;      turn_right_or_left_90
    when ROUTE_TURN_RANDOM;       turn_random
    when ROUTE_TURN_TOWARD;       turn_toward_player
    when ROUTE_TURN_AWAY;         turn_away_from_player
    when ROUTE_SWITCH_ON;         $game_switches[params[0]] = true
    when ROUTE_SWITCH_OFF;        $game_switches[params[0]] = false
    when ROUTE_CHANGE_SPEED;      @move_speed = params[0]
    when ROUTE_CHANGE_FREQ;       @move_frequency = params[0]
    when ROUTE_WALK_ANIME_ON;     @walk_anime = true
    when ROUTE_WALK_ANIME_OFF;    @walk_anime = false
    when ROUTE_STEP_ANIME_ON;     @step_anime = true
    when ROUTE_STEP_ANIME_OFF;    @step_anime = false
    when ROUTE_DIR_FIX_ON;        @direction_fix = true
    when ROUTE_DIR_FIX_OFF;       @direction_fix = false
    when ROUTE_THROUGH_ON;        @through = true
    when ROUTE_THROUGH_OFF;       @through = false
    when ROUTE_TRANSPARENT_ON;    @transparent = true
    when ROUTE_TRANSPARENT_OFF;   @transparent = false
    when ROUTE_CHANGE_GRAPHIC;    set_graphic(params[0], params[1])
    when ROUTE_CHANGE_OPACITY;    @opacity = params[0]
    when ROUTE_CHANGE_BLENDING;   @blend_type = params[0]
    when ROUTE_PLAY_SE;           params[0].play
    when ROUTE_SCRIPT;            eval(params[0])
    end
  end
  #--------------------------------------------------------------------------
  # * Cálculo da distância X
  #     x : coordenada X
  #--------------------------------------------------------------------------
  def distance_x_from(x)
    result = @x - x
    if $game_map.loop_horizontal? && result.abs > $game_map.width / 2
      if result < 0
        result += $game_map.width
      else
        result -= $game_map.width
      end
    end
    result
  end
  #--------------------------------------------------------------------------
  # * Cálculo da distância Y
  #     y : coordenada Y
  #--------------------------------------------------------------------------
  def distance_y_from(y)
    result = @y - y
    if $game_map.loop_vertical? && result.abs > $game_map.height / 2
      if result < 0
        result += $game_map.height
      else
        result -= $game_map.height
      end
    end
    result
  end
  #--------------------------------------------------------------------------
  # * Movimento aleatorio
  #--------------------------------------------------------------------------
  def move_random
    move_straight(2 + rand(4) * 2, false)
  end
  #--------------------------------------------------------------------------
  # * Movimento em direção de um personagem
  #     character : personagem alvo
  #--------------------------------------------------------------------------
  def move_toward_character(character)
    sx = distance_x_from(character.x)
    sy = distance_y_from(character.y)
    if sx.abs > sy.abs
      move_straight(sx > 0 ? 4 : 6)
      move_straight(sy > 0 ? 8 : 2) if !@move_succeed && sy != 0
    elsif sy != 0
      move_straight(sy > 0 ? 8 : 2)
      move_straight(sx > 0 ? 4 : 6) if !@move_succeed && sx != 0
    end
  end
  #--------------------------------------------------------------------------
  # * Movimento para longe de um personagem
  #     character : personagem alvo
  #--------------------------------------------------------------------------
  def move_away_from_character(character)
    sx = distance_x_from(character.x)
    sy = distance_y_from(character.y)
    if sx.abs > sy.abs
      move_straight(sx > 0 ? 6 : 4)
      move_straight(sy > 0 ? 2 : 8) if !@move_succeed && sy != 0
    elsif sy != 0
      move_straight(sy > 0 ? 2 : 8)
      move_straight(sx > 0 ? 6 : 4) if !@move_succeed && sx != 0
    end
  end
  #--------------------------------------------------------------------------
  # * Olhar em direção de um personagem
  #     character : personagem alvo
  #--------------------------------------------------------------------------
  def turn_toward_character(character)
    sx = distance_x_from(character.x)
    sy = distance_y_from(character.y)
    if sx.abs > sy.abs
      set_direction(sx > 0 ? 4 : 6)
    elsif sy != 0
      set_direction(sy > 0 ? 8 : 2)
    end
  end
  #--------------------------------------------------------------------------
  # * Olhar para longe de um personagem
  #     character : personagem alvo
  #--------------------------------------------------------------------------
  def turn_away_from_character(character)
    sx = distance_x_from(character.x)
    sy = distance_y_from(character.y)
    if sx.abs > sy.abs
      set_direction(sx > 0 ? 6 : 4)
    elsif sy != 0
      set_direction(sy > 0 ? 2 : 8)
    end
  end
  #--------------------------------------------------------------------------
  # * Olhar em direção do jogador
  #--------------------------------------------------------------------------
  def turn_toward_player
    turn_toward_character($game_player)
  end
  #--------------------------------------------------------------------------
  # * Olhar para longe do jogador
  #--------------------------------------------------------------------------
  def turn_away_from_player
    turn_away_from_character($game_player)
  end
  #--------------------------------------------------------------------------
  # * Movimento em direção do jogador
  #--------------------------------------------------------------------------
  def move_toward_player
    move_toward_character($game_player)
  end
  #--------------------------------------------------------------------------
  # * Movimento para longe do jogador
  #--------------------------------------------------------------------------
  def move_away_from_player
    move_away_from_character($game_player)
  end
  #--------------------------------------------------------------------------
  # * Movimento para frente
  #--------------------------------------------------------------------------
  def move_forward
    move_straight(@direction)
  end
  #--------------------------------------------------------------------------
  # * Movimento para trás
  #--------------------------------------------------------------------------
  def move_backward
    last_direction_fix = @direction_fix
    @direction_fix = true
    move_straight(reverse_dir(@direction), false)
    @direction_fix = last_direction_fix
  end
  #--------------------------------------------------------------------------
  # * Salto
  #     x_plus : valor adicional da coordenada X
  #     y_plus : valor adicional da coordenada Y
  #--------------------------------------------------------------------------
  def jump(x_plus, y_plus)
    if x_plus.abs > y_plus.abs
      set_direction(x_plus < 0 ? 4 : 6) if x_plus != 0
    else
      set_direction(y_plus < 0 ? 8 : 2) if y_plus != 0
    end
    @x += x_plus
    @y += y_plus
    distance = Math.sqrt(x_plus * x_plus + y_plus * y_plus).round
    @jump_peak = 10 + distance - @move_speed
    @jump_count = @jump_peak * 2
    @stop_count = 0
    straighten
  end
  #--------------------------------------------------------------------------
  # * Processar final da rota
  #--------------------------------------------------------------------------
  def process_route_end
    if @move_route.repeat
      @move_route_index = -1
    elsif @move_route_forcing
      @move_route_forcing = false
      restore_move_route
    end
  end
  #--------------------------------------------------------------------------
  # * Avançar o índice de execução da rota de movimento
  #--------------------------------------------------------------------------
  def advance_move_route_index
    @move_route_index += 1 if @move_succeed || @move_route.skippable
  end
  #--------------------------------------------------------------------------
  # * Girar 90° para direita
  #--------------------------------------------------------------------------
  def turn_right_90
    case @direction
    when 2;  set_direction(4)
    when 4;  set_direction(8)
    when 6;  set_direction(2)
    when 8;  set_direction(6)
    end
  end
  #--------------------------------------------------------------------------
  # * Girar 90° para esqueda
  #--------------------------------------------------------------------------
  def turn_left_90
    case @direction
    when 2;  set_direction(6)
    when 4;  set_direction(2)
    when 6;  set_direction(8)
    when 8;  set_direction(4)
    end
  end
  #--------------------------------------------------------------------------
  # * Girar 180°
  #--------------------------------------------------------------------------
  def turn_180
    set_direction(reverse_dir(@direction))
  end
  #--------------------------------------------------------------------------
  # * Girar 90° aleatório
  #--------------------------------------------------------------------------
  def turn_right_or_left_90
    case rand(2)
    when 0;  turn_right_90
    when 1;  turn_left_90
    end
  end
  #--------------------------------------------------------------------------
  # * Olhar aleatóriamente
  #--------------------------------------------------------------------------
  def turn_random
    set_direction(2 + rand(4) * 2)
  end
  #--------------------------------------------------------------------------
  # * Substituindo a posição do personagem
  #     character : personagem alvo
  #--------------------------------------------------------------------------
  def swap(character)
    new_x = character.x
    new_y = character.y
    character.moveto(x, y)
    moveto(new_x, new_y)
  end
end
