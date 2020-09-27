#==============================================================================
# ** Window_Skill
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de habilidades.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Skill < Window_ItemSelectable
  
  def initialize
    super(460, 170, 212, 198)
    self.visible = false
    self.closable = true
    self.title = Vocab::skill
    @tab_page = Tab_Control.new(self, [Vocab::Attack, Vocab::Support], true) { refresh }
  end
  
  def enable?(item)
    $game_actors[1].usable?(item)
  end
  
  def make_item_list
    if @tab_page.index == 0
      @data = $game_actors[1].skills.collect { |skill| skill if skill.for_opponent? && $game_actors[1].added_skill_types.include?(skill.stype_id) }.compact
    else
      @data = $game_actors[1].skills.collect { |skill| skill if (skill.for_friend? || skill.scope == 0) && $game_actors[1].added_skill_types.include?(skill.stype_id) }.compact
    end
  end
  
  def refresh
    super
    @tab_page.draw_border
  end
  
  def update
    super
    if Mouse.dbl_clk?(:L) && $game_player.item_attack_time <= Time.now && index >= 0
      $game_player.item_attack_time = Time.now + Configs::COOLDOWN_SKILL_TIME
      $network.send_use_skill(item.id) if $game_player.usable?(item)
    end
  end
  
  def update_drag
    return unless Mouse.press?(:L)
    return if $cursor.object
    return if $dragging_window
    return unless index >= 0
    $cursor.change_item(item, Enums::Mouse::SKILL)
  end
  
end
