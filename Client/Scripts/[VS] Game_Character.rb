#==============================================================================
# ** Game_Character
#------------------------------------------------------------------------------
#  Esta é a superclasse do Game_Player, Game_Event e
# Game_NetPlayer.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Game_Character < Game_CharacterBase
  
  attr_reader   :actor
  attr_writer   :group
  attr_accessor :message
  
  def init_public_members
    super
    @group = Enums::Group::STANDARD
    @move_route_forcing = false
    @boss = false
    @message = ''
    @ani_time = Configs::ATTACK_ANIMATION_TIME
  end
  
  def actor?
    actor
  end
  
  def attack_animation?
    @ani_time < Configs::ATTACK_ANIMATION_TIME && @last_character_index != @character_index
  end
  
  def standard?
    @group == Enums::Group::STANDARD
  end
  
  def admin?
    @group == Enums::Group::ADMIN
  end
  
  def monitor?
    @group == Enums::Group::MONITOR
  end
  
  def boss?
    @boss
  end
  
  def collide_with_characters?(x, y)
    collide_with_events?(x, y) || collide_with_vehicles?(x, y)
  end
  
  def collide_with_players?(x, y)
    $game_map.players.values.find { |player| player.pos_nt?(x, y) }
  end
  
  def move(x, y, d)
    # Evita que o jogador tente se movimentar ao receber
    #as mesmas coordenadas que as atuais
    return if pos?(x, y) && @direction == d
    unselect_target
    sx = @x - x
    sy = @y - y
    set_direction(d)
    if sx.abs > 2 || sy.abs > 2
      moveto(x, y)
      return
    end
    @x = x
    @y = y
    @real_x = $game_map.x_with_direction(@x, reverse_dir(d)) unless @real_x == @x
    @real_y = $game_map.y_with_direction(@y, reverse_dir(d)) unless @real_y == @y
  end
  
  def unselect_target
    return if !$game_player.has_target? || self != $game_player && self != $game_player.target || $game_map.in_screen?($game_player.target) 
    $error_msg = Vocab::TargetNotInRange
    $game_player.clear_target
  end
  
  def change_damage(hp_damage, mp_damage, critical = false, animation_id = 0, not_show_missed = false)
    if !not_show_missed || hp_damage > 0 || mp_damage > 0
      actor.result.hp_damage = hp_damage
      actor.result.mp_damage = mp_damage
    end
    actor.result.critical = critical
    @animation_id = animation_id
  end
  
  def animate_attack(ani_index)
    # Se não é pra executar uma animação ou o cliente ficou
    #minimizado e ainda não executou a primeira animação
    return if ani_index == 8 || @ani_time < Configs::ATTACK_ANIMATION_TIME
    @last_character_index = @character_index
    @last_pattern = @pattern
    @last_step_anime = @step_anime
    @character_index = ani_index
    @pattern = 0
    @step_anime = true
    @ani_time = 0
  end
  
  def select_player_target
    return unless Mouse.click?(:L)
    return if self.is_a?(Game_Player)
    return if self.is_a?(Game_Vehicle)
    return if @character_name.empty?
    return unless Mouse.in_tile?(self)
    return unless actor?
    return if $game_player.over_window?
    if $game_player.target == self
      $game_player.clear_target
    else
      target_type = self.is_a?(Game_NetPlayer) ? Enums::Target::PLAYER : Enums::Target::ENEMY
      $network.send_target(@id, target_type)
    end
  end
  
  def update_animate_attack
    return if @ani_time == Configs::ATTACK_ANIMATION_TIME
    @ani_time += 1
    @pattern = (@ani_time / 10).to_i
    if @ani_time == Configs::ATTACK_ANIMATION_TIME
      @character_index = @last_character_index
      @pattern = @last_pattern
      @step_anime = @last_step_anime
    end
  end
  
end
