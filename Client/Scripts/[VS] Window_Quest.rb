#==============================================================================
# ** Window_Quest
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de missões.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Quest < Window_Selectable
  
  def initialize
    super(173, 170, 235, 212)
    self.visible = false
    self.closable = true
    self.title = Vocab::Quests
    @tab_page = Tab_Control.new(self, [Vocab::InProgress, Vocab::Completed], true) { refresh }
  end
  
  def line_height
    20
  end
  
  def make_list
    @data = @tab_page.index == 0 ? $game_actors[1].quests_in_progress.values : $game_actors[1].quests_finished.values
  end
  
  def draw_item(index)
    rect = item_rect_for_text(index)
    icon_index = @data[index].finished? ? Configs::QUEST_FINISHED_ICON : Configs::QUEST_IN_PROGRESS_ICON
    rect2 = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    bitmap = Cache.system('Iconset')
    contents.blt(3, rect.y, bitmap, rect2)
    rect.x += 27
    draw_text(rect, @data[index].name)
  end
  
  def refresh
    super
    @tab_page.draw_border
  end
  
  def update
    super
    if Mouse.click?(:L) && index >= 0
      $windows[:quest_info].show(@data[index])
      Sound.play_ok
    end
  end
  
end

#==============================================================================
# ** Window_QuestInfo
#==============================================================================
class Window_QuestInfo < Window_Base
  
  attr_reader   :quest
  
  def initialize
    super(415, 151, 245, 231)
    self.visible = false
    self.closable = true
    self.title = Vocab::Information
  end
  
  def line_height
    20
  end
  
  def show(quest)
    @quest = quest
    super()
  end
  
  def refresh
    contents.clear
    change_color(system_color)
    draw_text(0, -2, contents_width, line_height, @quest.name, 1)
    change_color(crisis_color)
    draw_text(0, 115, contents_width, line_height, Vocab::Rewards, 1)
    change_color(normal_color)
    word_wrap(@quest.description).each_with_index do |text, i|
      draw_text(0, line_height * i + 21, contents_width, line_height, text, 1)
    end
    draw_text(0, 139, contents_width, line_height, "#{Vocab::Exp}: #{convert_gold(@quest.reward.exp)}")
    draw_text(0, 162, contents_width, line_height, "#{Vocab.currency_unit}: #{convert_gold(@quest.reward.gold)}")
    if @quest.reward.item
      draw_text(130, 152, 45, line_height, "#{Vocab::Item}:")
      draw_icon(@quest.reward.item.icon_index, 170, 152)
      draw_text(200, 152, 25, line_height, "x#{@quest.reward.item_amount}")
    end
  end
  
end
