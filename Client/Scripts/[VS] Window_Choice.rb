#==============================================================================
# ** Window_Choice
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de escolhas.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Choice < Window_Base
  
  def initialize
    # Quando a resolução é alterada, a coordenada x é
    #reajustada no adjust_windows_position da Scene_Map
    super(adjust_x, 245, 230, 95)
    self.visible = false
    self.z = 103
    Button.new(self, 14, 63, Vocab::Yes) { yes }
    Button.new(self, 179, 63, Vocab::No) { no }
  end
  
  def adjust_x
    Graphics.width / 2 - 115
  end
  
  def finish_trade?
    @type == Enums::Choice::FINISH_TRADE
  end
  
  def show(text, type, actor_id = 0, name = '')
    @text = text
    @type = type
    @actor_id = actor_id
    @name = name
    super()
  end
  
  def refresh
    contents.clear
    word_wrap(@text).each_with_index do |text, i|
      draw_text(0, line_height * i, contents_width, line_height, text, 1)
    end
  end
  
  def yes
    case @type
    when Enums::Choice::REMOVE_FRIEND
      $network.send_remove_friend(@actor_id)
    when Enums::Choice::REQUEST, Enums::Choice::FINISH_TRADE
      $network.send_accept_request
    when Enums::Choice::LEAVE_PARTY
      $network.send_leave_party
    when Enums::Choice::LEAVE_GUILD
      $network.send_leave_guild
      $windows[:guild].hide
    when Enums::Choice::REMOVE_GUILD_MEMBER
      $network.send_remove_guild_member(@name)
    when Enums::Choice::CHANGE_GUILD_LEADER
      $network.send_change_guild_leader(@name)
    end
    hide
  end
  
  def no
    $network.send_decline_request if @type == Enums::Choice::REQUEST || @type == Enums::Choice::FINISH_TRADE
    hide
  end
  
  def update
    super
    update_trigger
  end
  
  def update_trigger
    return if $typing
    yes if Input.trigger?(:LETTER_S)
    no if Input.trigger?(:LETTER_N)
  end
  
end
