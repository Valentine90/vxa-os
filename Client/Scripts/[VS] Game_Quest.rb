#==============================================================================
# ** Game_Quest
#------------------------------------------------------------------------------
#  Esta classe lida com a missão.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Game_Quest
  
  attr_reader   :name
  attr_reader   :description
  attr_reader   :reward
  attr_writer   :state
  
  def initialize(id, state = Enums::Quest::IN_PROGRESS)
    @state = state
    @name = Quests::DATA[id][:name]
    @description = Quests::DATA[id][:desc]
    @reward = Reward.new
    @reward.item = $game_party.item_object(Quests::DATA[id][:rew_item_kind], Quests::DATA[id][:rew_item_id])
    @reward.item_amount = Quests::DATA[id][:rew_item_amount]
    @reward.exp = Quests::DATA[id][:rew_exp]
    @reward.gold = Quests::DATA[id][:rew_gold]
    @repeat = Quests::DATA[id][:repeat]
  end
  
  def in_progress?
    @state == Enums::Quest::IN_PROGRESS
  end

  def finished?
    @state == Enums::Quest::FINISHED
  end

  def repeat?
    @repeat
  end
  
end
