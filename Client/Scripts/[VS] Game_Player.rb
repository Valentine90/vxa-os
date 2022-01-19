#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  Esta classe lida com o jogador. Ela contém dados, como
# direção, coordenadas x e y.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Game_Player < Game_Character
  
  attr_reader   :blocked
  attr_accessor :target
  attr_accessor :item_attack_time
  
  def init_basic
    @target = nil
    #@got_drop = false
    @weapon_attack_time = Time.now
    @item_attack_time = Time.now
    @blocked = []
  end
  
  def clear_target
    return unless @target
    $network.send_target(-1, Enums::Target::NONE)
  end
  
  def range_weapon?
    Configs::RANGE_WEAPONS.has_key?(actor.weapons[0].id)
  end
  
  def has_target?
    @target
  end
  
  def collide_with_characters?(x, y)
    super || collide_with_players?(x, y) && $game_map.pvp
  end
  
  def in_front?(target)
    x = $game_map.round_x_with_direction(@x, @direction)
    y = $game_map.round_y_with_direction(@y, @direction)
    target.pos?(x, y)
  end
  
  def protection_level?(target)
    actor.level < Configs::MIN_LEVEL_PVP || target.actor.level < Configs::MIN_LEVEL_PVP
  end
  
  def in_range?(target, range)
    distance_x_from(target.x).abs <= range && distance_y_from(target.y).abs <= range
  end
  
  def usable?(item)
    mp_enough?(item) && sufficient_level?(item) && has_item?(item) && actor.usable?(item) && (item.for_friend? || valid_target?(item.range, item.aoe))
  end
  
  def mp_enough?(item)
    if item.is_a?(RPG::Skill) && item.mp_cost > actor.mp
      $error_msg = Vocab::InsufficientMP
      return false
    end
    return true
  end
  
  def sufficient_level?(item)
    if actor.level < item.level
      $error_msg = Vocab::InsufficientLevel
      return false
    end
    return true
  end
  
  def has_item?(item)
    if item.is_a?(RPG::Item) && !$game_party.has_item?(item)
      $error_msg = "#{Vocab::NotHave} #{item.name}."
      return false
    end
    return true
  end
  
  def can_attack?
    @weapon_attack_time = Time.now + Configs::ATTACK_TIME
    return can_attack_range? if actor.weapons[0] && range_weapon?
    return can_attack_normal?
  end
  
  def can_attack_normal?
    x = $game_map.round_x_with_direction(@x, @direction)
    y = $game_map.round_y_with_direction(@y, @direction)
    player = collide_with_players?(x, y)
    # Se o evento está em frente ou abaixo do jogador
    #ou atrás de um balcão
    if collide_with_events?(x, y) || event_trigger_here?([0]) || $game_map.counter?(x, y)
      return true
    elsif !actor.movable?
      return false
    elsif !player
      return false
    elsif player.admin?
      $error_msg = Vocab::AttackAdmin
      return false
    elsif !$game_map.pvp
      $error_msg = Vocab::NonPvP
      return false
    elsif protection_level?(player)
      $error_msg = Vocab::ProtectionLevel
      return false
    end
    return true
  end
  
  def event_trigger_here?(triggers)
    $game_map.events_xy(@x, @y).any? { |event| event.trigger_in?(triggers) && !event.normal_priority? }
  end
  
  def can_attack_range?
    x = $game_map.round_x_with_direction(@x, @direction)
    y = $game_map.round_y_with_direction(@y, @direction)
    if collide_with_events?(x, y)
      return true
    elsif !actor.movable?
      return false
    elsif Configs::RANGE_WEAPONS[actor.weapons[0].id][:item_id] > 0 && !$game_party.has_item?($data_items[Configs::RANGE_WEAPONS[actor.weapons[0].id][:item_id]])
      $error_msg = Vocab::NotAmmo
      return false
    elsif Configs::RANGE_WEAPONS[actor.weapons[0].id][:mp_cost] && actor.mp < Configs::RANGE_WEAPONS[actor.weapons[0].id][:mp_cost]
      $error_msg = Vocab::InsufficientMP
      return false
    elsif !valid_target?(Configs::RANGE_WEAPONS[actor.weapons[0].id][:range])
      return false
    end
    return true
  end
  
  def valid_target?(range, aoe = 0)
    if aoe > 0
      return true
    elsif !@target
      $error_msg = Vocab::NotTarget
      return false
    elsif !in_range?(@target, range)
      $error_msg = Vocab::TargetNotInRange
      return false
    elsif blocked_passage?(@target)
      $error_msg = Vocab::NotSeeTarget
      return false
    elsif @target.admin?
      $error_msg = Vocab::AttackAdmin
      return false
    elsif @target.is_a?(Game_NetPlayer) && !$game_map.pvp
      $error_msg = Vocab::NonPvP
      return false
    elsif @target.is_a?(Game_NetPlayer) && protection_level?(@target)
      $error_msg = Vocab::ProtectionLevel
      return false
    end
    return true
  end
  
  def blocked_passage?(target)
    # Retorna falso se o jogador e o alvo estiverem nas
    #mesmas coordenadas x e y, pois, nesta versão do Ruby,
    #o atan2 retorna um erro
    return false if pos?(target.x, target.y)
    radians = Math.atan2(target.x - @x, target.y - @y)
    speed_x = Math.sin(radians)
    speed_y = Math.cos(radians)
    range_x = (target.x - @x).abs
    range_y = (target.y - @y).abs
    # Obtém a direção do projétil em vez de usar a do
    #jogador que pode estar de costas para o alvo
    direction = projectile_direction(target)
    result = false
    x = @x
    y = @y
    while true
      # Soma valores decimais
      x += speed_x
      y += speed_y
      x2 = x.to_i
      y2 = y.to_i
      if distance_x_from(x2).abs > range_x || distance_y_from(y2).abs > range_y
        break
      elsif !$game_map.valid?(x2, y2) || !map_passable?(x2, y2, direction)
        result = true
        break
      end
    end
    result
  end
  
  def dir8_passable?(x, y, d)
    if d < 7
      horz = d + 3
      vert = 2
    else
      horz = d - 3
      vert = 8
    end
    return diagonal_passable?(x, y, horz, vert) if d.odd?
    return passable?(x, y, d)
  end
  
  def perform_transfer
    return unless transfer?
    set_direction(@new_direction)
    unless @new_map_id == $game_map.map_id
      $game_map.setup(@new_map_id)
      $game_map.autoplay
      SceneManager.scene.clear_map
    end
    moveto(@new_x, @new_y)
    clear_transfer_info
    $windows[:hud].change_opacity
  end
  
  def projectile_direction(target)
    sx = distance_x_from(target.x)
    sy = distance_y_from(target.y)
    if sx.abs > sy.abs
      direction = sx > 0 ? 4 : 6
    elsif sy != 0
      direction = sy > 0 ? 8 : 2
    end
    direction
  end
  
  def real_move_speed
    @move_speed
  end
  
  def die
    # Limpa estados e buffs
    actor.die
    $windows[:states].visible = false
    $game_message.visible = false
  end
  
  def move_by_input
    return if !movable? || $game_map.interpreter.running? || $windows[:quest_dialogue].visible
    # Se a conexão ficou lenta e ainda não recebeu do
    #servidor o movimento anterior
    send_movement(Input.dir4) if Input.dir4 > 0 && !$typing && !$wait_player_move
  end
  
  def send_movement(d)
    return if !dir8_passable?(@x, @y, d) && @direction == d
    $network.send_player_movement(d)
    $wait_player_move = true
    unselect_target
    case d
    when 1
      move_diagonal(4, 2)
    when 3
      move_diagonal(6, 2)
    when 7
      move_diagonal(4, 8)
    when 9
      move_diagonal(6, 8)
    else
      move_straight(d)
    end
  end
  
  def update_attack
    return if @weapon_attack_time > Time.now
    # Só começa a contar o tempo do ataque se
    #não tiver ocupado com mensagem
    $network.send_player_attack if Input.press?(Configs::ATTACK_KEY) && !$game_map.interpreter.running? && can_attack? && !$typing
  end
  
  def update_nonmoving(last_moving)
  end
  
  def update_trigger
    clear_target if Input.trigger?(:B)
    remove_drop if Input.repeat?(Configs::GET_DROP_KEY)#Mouse.click?(:L)
    select_nearest_enemy if Input.trigger?(Configs::SELECT_ENEMY_KEY)
  end
  
  def remove_drop
    return if $typing
    #@got_drop = false
    $game_map.drops.each_with_index do |drop, i|
      #next unless Mouse.in_tile?(drop)
      #next unless in_range?(drop, 1)
      next unless pos?(drop.x, drop.y)
      $network.send_remove_drop(i)
      #@got_drop = true
      break
    end
  end
  
  def use_hotbar
    return if @item_attack_time > Time.now || $typing 
    actor.hotbar.each_with_index do |item, i|
      next unless Input.press?(Configs::HOTKEYS[i])
      @item_attack_time = Time.now + Configs::COOLDOWN_SKILL_TIME
      $network.send_use_hotbar(i) if item && usable?(item)
      break
    end
  end
  
  def over_window?
    $windows.each_value do |window|
      if window.is_a?(Window_Chat) && window.opacity > 0 && window.in_area?(0, 0, window.width, window.height + 22)
        return true
      elsif window.is_a?(Window) && window.visible && window.in_area? && !window.is_a?(Window_Chat)
        return true
      elsif window.is_a?(Sprite2) && window.visible && window.in_area?
        return true
      end
    end
    return false
  end
  
  def select_nearest_enemy
    # Se a tecla de atalho é uma letra e a caixa de
    #texto estiver ativa
    return if $typing
    event_in_sight_id = 0
    event_not_in_sight_id = 0
    in_sight_sx = 10
    in_sight_sy = 10
    not_in_sight_sx = 10
    not_in_sight_sy = 10
    $game_map.events.each_value do |event|
      # Se é um inimigo que morreu ou está fora do alcance
      next unless event.actor? && in_range?(event, 10)
      real_distance_x = distance_x_from(event.x).abs
      real_distance_y = distance_y_from(event.y).abs
      if !blocked_passage?(event) && real_distance_x + real_distance_y < in_sight_sx + in_sight_sy
        event_in_sight_id = event.id
        in_sight_sx = real_distance_x
        in_sight_sy = real_distance_y
      elsif real_distance_x + real_distance_y < not_in_sight_sx + not_in_sight_sy
        event_not_in_sight_id = event.id
        not_in_sight_sx = real_distance_x
        not_in_sight_sy = real_distance_y
      end
    end
    if event_in_sight_id > 0
      $network.send_target(event_in_sight_id, Enums::Target::ENEMY)
    elsif event_not_in_sight_id > 0
      $network.send_target(event_not_in_sight_id, Enums::Target::ENEMY)
    end
  end
  
end
