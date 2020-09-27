#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
#  Esta classe lida com o evento.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Game_Event < Game_Character
  
  attr_reader   :event
  attr_reader   :interpreter
  attr_accessor :erased
  
  def setup_enemy_settings
    @actor = enemy
    @boss = @actor.enemy.boss if @actor
  end
  
  def enemy
    if @list[0].code == 108 && @list[0].parameters[0].start_with?('Enemy')
      enemy_id = @list[0].parameters[0].split('=')[1].to_i
      return Game_Enemy.new(0, enemy_id)
    end
    return nil
  end
  
  def refresh_quest_icon
    @quest_icon = false
    @list.each do |item|
      next unless item.code == 355
      next unless item.parameters[0].start_with?('start_quest')
      id = item.parameters[0][/\d(.*)/].to_i
      unless $game_actors[1].quests.has_key?(id - 1)
        @quest_icon = true
        break
      end
    end
  end
  
  def quest_not_started?
    @quest_icon
  end
  
  def fixed_movement?
    @move_type == 0
  end
  
  def collide_with_characters?(x, y)
    super || collide_with_players?(x, y)
  end
  
end
