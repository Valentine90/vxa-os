#==============================================================================
# ** Game_Quest
#------------------------------------------------------------------------------
#  Esta classe lida com a missão.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Game_Quest

  attr_reader   :switch_id
  attr_reader   :variable_id
  attr_reader   :variable_amount
  attr_reader   :item_id
  attr_reader   :item_kind
  attr_reader   :item_amount
  attr_reader   :enemy_id
  attr_reader   :max_kills
  attr_reader   :reward
  attr_accessor :state
  attr_accessor :kills

  def initialize(id, state, kills)
    @state = state
    @kills = kills
    @switch_id = Quests::DATA[id][:switch_id]
    @variable_id = Quests::DATA[id][:variable_id]
    @variable_amount = Quests::DATA[id][:variable_amount]
    @item_id = Quests::DATA[id][:item_id]
    @item_kind = Quests::DATA[id][:item_kind]
    @item_amount = Quests::DATA[id][:item_amount]
    @enemy_id = Quests::DATA[id][:enemy_id]
    @max_kills = Quests::DATA[id][:enemy_amount]
    @reward = Reward.new
    @reward.item_id = Quests::DATA[id][:rew_item_id]
    @reward.item_kind = Quests::DATA[id][:rew_item_kind]
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
