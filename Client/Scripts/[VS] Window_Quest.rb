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
    @data = @tab_page.index == 0 ? $game_actors[1].quests_in_progress : $game_actors[1].quests_finished
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
    draw_text(0, 139, contents_width, line_height, "#{Vocab::Exp}: #{format_number(@quest.reward.exp)}")
    draw_text(0, 162, contents_width, line_height, "#{Vocab.currency_unit}: #{format_number(@quest.reward.gold)}")
    if @quest.reward.item
      draw_text(130, 152, 45, line_height, "#{Vocab::Item}:")
      draw_icon(@quest.reward.item.icon_index, 170, 152)
      draw_text(200, 152, 25, line_height, "x#{@quest.reward.item_amount}")
    end
  end
  
end

#==============================================================================
# ** Window_QuestDialogue
#==============================================================================
class Window_QuestDialogue < Window_Base2
  
  def initialize
    super(adjust_x, adjust_y, 'QuestDialogueWindow')
    self.visible = false
    self.closable = true
    Button.new(self, 92, 244, Vocab::Accept) { accept }
  end
  
  def adjust_x
    Graphics.width / 2 - 125
  end
  
  def adjust_y
    Graphics.height / 2 - 135
  end
  
  def show
    @quest = Quests::DATA[$game_message.texts.first[/QT(.*):/, 1].to_i - 1]
    super
  end
  
  def hide_window
    return unless visible
    $network.send_choice(1)
    $game_message.clear
    super
  end
  
  def refresh
    contents.clear
    contents.font.size = Font.default_size
    change_color(crisis_color)
    draw_text(32, 4, contents_width, line_height, @quest[:name])
    change_color(hp_gauge_color2)
    draw_text(0, 147, contents_width, line_height, Vocab::Rewards, 1)
    change_color(normal_color)
    draw_justified_texts(10, 28, contents_width + 20, line_height, $game_message.all_text.gsub("\n", '').sub(/QT(.*):/, ''))
    contents.font.size = 14
    x = 67
    if @quest[:rew_exp] > 0
      draw_icon(Configs::EXP_ICON, x, 181)
      draw_text(x - 4, 191, 31, line_height, format_number(@quest[:rew_exp]), 2)
      x += 35
    end
    if @quest[:rew_gold] > 0
      draw_icon(Configs::GOLD_ICON, x, 181)
      draw_text(x - 4, 191, 31, line_height, format_number(@quest[:rew_gold]), 2)
      x += 35
    end
    if @quest[:rew_item_id] > 0
      draw_icon($game_party.item_object(@quest[:rew_item_kind], @quest[:rew_item_id]).icon_index, x, 181)
      draw_text(x - 4, 191, 31, line_height, @quest[:rew_item_amount], 2)
    end
  end
  
  def accept
    $network.send_choice(0)
    $game_message.clear
    hide
  end
  
end
