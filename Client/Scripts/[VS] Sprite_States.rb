#==============================================================================
# ** Sprite_States
#------------------------------------------------------------------------------
#  Esta classe lida com a exibição dos estados, buffs e
# debuffs do jogador.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Sprite_States < Sprite2
  
  MAX_STATES = 9
  
  def initialize
    super
    self.bitmap = Bitmap.new(30 * MAX_STATES, 24 + line_height)
    self.x = 11
    self.y = 121
    self.z = 50
    # Cria a dica antes de torná-la invisível no
    #método visible
    create_tool_tip
    self.visible = false
    @last_tip_name = ''
  end
  
  def create_tool_tip
    @tool_tip = Sprite.new
    @tool_tip.bitmap = Bitmap.new(self.bitmap.width, line_height)
    @tool_tip.z = self.z
  end
  
  def line_height
    18
  end
  
  def dispose
    super
    @tool_tip.bitmap.dispose
    @tool_tip.dispose
  end
  
  def visible=(visible)
    super
    $windows[:party].y = visible ? 163 : 121
    $windows[:party].refresh_icon_y
    @tool_tip.visible = false
  end
  
  def refresh
    self.bitmap.clear
    bitmap = Cache.system('Iconset')
    ($game_actors[1].state_icons + $game_actors[1].buff_icons).take(MAX_STATES).each_with_index do |icon_index, i|
      rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
      self.bitmap.blt(30 * i, 0, bitmap, rect)
      #self.bitmap.draw_text(30 * i, 24, 27, line_height, "#{state.time}s", 1) if state.time > 0
    end
  end
  
  def refresh_tool_tip(state_name)
    @last_tip_name = state_name
    @tool_tip.bitmap.clear
    rect = Rect.new(0, 0, text_width(state_name) + 8, @tool_tip.bitmap.height)
    @tool_tip.bitmap.fill_rect(rect, Color.new(0, 0, 0, 160))
    @tool_tip.bitmap.draw_text(rect, state_name, 1)
  end
  
  def update
    super
    return if $dragging_window || $cursor.object
    $game_actors[1].states.each_with_index do |state, i|
      @tool_tip.visible = in_area?(30 * i, 0, 24, 24)
      if @tool_tip.visible
        @tool_tip.x = Mouse.x + 18 + @tool_tip.bitmap.width > Graphics.width ? Graphics.width - @tool_tip.bitmap.width :  Mouse.x + 18
        @tool_tip.y = Mouse.y + 18 + @tool_tip.bitmap.height > Graphics.height ? Graphics.height - @tool_tip.bitmap.height : Mouse.y + 18
        refresh_tool_tip(state.name) unless @last_tip_name == state.name
        break
      end
    end
  end
  
end
