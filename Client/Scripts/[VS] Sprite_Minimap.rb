#==============================================================================
# ** Sprite_Minimap
#------------------------------------------------------------------------------
#  Esta classe lida com a exibição do mapa em miniatura.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Sprite_Minimap < Sprite2
  
  Event_Data = Struct.new(:name, :width)
  
  def initialize
    super
    self.bitmap = Bitmap.new(172, 132)
    self.x = adjust_x
    self.y = 9
    self.z = 50
    self.bitmap.font.size = 15
    @bitmap = Cache.system('Minimap')
    @dragable = true
    @event_sprites = {}
    @event_data = {}
    @last_tip_name = ''
    create_player_point
    create_tool_tip
    refresh
    update
  end
  
  def line_height
    18
  end
  
  def adjust_x
    Graphics.width - 188
  end
  
  def in_area?(x = 0, y = 0, w = self.bitmap.width, h = self.bitmap.height)
    super(x + 24, y, w - 24, h)
  end
  
  def change_opacity(x = 0, y = 0)
    super()
    @player_sprite.opacity = self.opacity
    @event_sprites.each_value { |sprite| sprite.opacity = self.opacity }
  end
  
  def create_player_point
    @player_sprite = Sprite.new
    @player_sprite.bitmap = Bitmap.new(16, 16)#@bitmap
    @player_sprite.bitmap.blt(0, 0, @bitmap, Rect.new(142, 0, 16, 16))
    @player_sprite.z = self.z + 1
  end
  
  def create_tool_tip
    @tool_tip = Sprite.new
    @tool_tip.bitmap = Bitmap.new(self.bitmap.width, line_height)
    @tool_tip.z = @player_sprite.z + 1
  end
  
  def create_event(event_id, event_name, rect_y)
    event_sprite = Sprite.new
    event_sprite.bitmap = Bitmap.new(16, 16)
    event_sprite.bitmap.blt(0, 0, @bitmap, Rect.new(142, rect_y, 16, 16))
    event_sprite.x = self.x + object_x($game_map.events[event_id])
    event_sprite.y = self.y + object_y($game_map.events[event_id])
    event_sprite.z = self.z
    @event_sprites[event_id] = event_sprite
    @event_data[event_id] = Event_Data.new(event_name, text_width(event_name) + 8)
  end
  
  def dispose
    super
    @player_sprite.bitmap.dispose
    @player_sprite.dispose
    @tool_tip.bitmap.dispose
    @tool_tip.dispose
    dispose_events
  end
  
  def dispose_events
    @event_sprites.each_value do |event|
      event.bitmap.dispose
      event.dispose
    end
    @event_sprites.clear
    @event_data.clear
  end
  
  def object_x(object)
    [[object.x * 134 / $game_map.width + 25, 33].max, 161].min
  end
  
  def object_y(object)
    [[object.y * 106 / $game_map.height - 5, 3].max, 104].min
  end
  
  def refresh
    @tool_tip.visible = false
    draw_background
    draw_icon
    draw_map_name
    dispose_events
    if FileTest.exist?("Graphics/Minimaps/#{$game_map.map_id}.png")
      draw_map
      draw_events
    else
      @player_sprite.visible = false
    end
  end
  
  def draw_background
    self.bitmap.clear
    self.bitmap.blt(30, 0, @bitmap, self.bitmap.rect)
  end
  
  def draw_icon
    bitmap = Cache.system('Iconset')
    icon_index = $game_map.pvp? ? Configs::MAP_PVP_ICON : Configs::MAP_NONPVP_ICON
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    self.bitmap.blt(0, 0, bitmap, rect)
  end
  
  def draw_map_name
    self.bitmap.draw_text(30, 113, 142, 18, $game_map.display_name, 1)
  end
  
  def draw_map
    bitmap = Cache.minimap($game_map.map_id.to_s)
    self.bitmap.blt(33, 3, bitmap, bitmap.rect)
  end
  
  def refresh_tool_tip(event_name, width)
    @last_tip_name = event_name
    @tool_tip.bitmap.clear
    rect = Rect.new(0, 0, width, @tool_tip.bitmap.height)
    @tool_tip.bitmap.fill_rect(rect, Color.new(0, 0, 0, 160))
    @tool_tip.bitmap.draw_text(rect, event_name, 1)
  end
  
  def draw_events
    @player_sprite.visible = true
    $game_map.events.each do |event_id, event|
      next unless event.list
      # Missão
      if event.quest_not_started?
        create_event(event_id, Vocab::Quest, 32)
        next
      # Boss
      elsif event.boss?
        create_event(event_id, Vocab::Boss, 96)
        next
      end
      event.list.each do |item|
        # Loja
        if item.code == 302
          create_event(event_id, Vocab::Shop, 16)
          break
        elsif item.code == 355
          # Banco
          if item.parameters[0].include?('open_bank')
            create_event(event_id, Vocab::Bank, 48)
            break
          # Teletransporte
          elsif item.parameters[0].include?('open_teleport')
            create_event(event_id, Vocab::Teleport, 64)
            break
          # Ponto de referência
          elsif item.parameters[0].include?('check_point')
            create_event(event_id, Vocab::CheckPoint, 80)
            break
          end
        end
      end
    end
  end
  
  def update
    super
    change_opacity(24)
    @player_sprite.x = self.x + object_x($game_player)
    @player_sprite.y = self.y + object_y($game_player)
    #@player_sprite.src_rect.set(142, $game_player.direction * 4 - 16, 16, 16)
    @event_sprites.each do |event_id, event_sprite|
      event_sprite.x = self.x + object_x($game_map.events[event_id])
      event_sprite.y = self.y + object_y($game_map.events[event_id])
      update_tool_tip(event_id)
    end
  end
  
  def update_tool_tip(event_id)
    return if @tool_tip.visible && @last_tip_name != @event_data[event_id].name
    @tool_tip.visible = in_area?(object_x($game_map.events[event_id]) - 24, object_y($game_map.events[event_id]), 40, 16)
    if @tool_tip.visible
      @tool_tip.x = Mouse.x + 18 + @event_data[event_id].width > Graphics.width ? Graphics.width - @event_data[event_id].width :  Mouse.x + 18
      @tool_tip.y = Mouse.y + 18 + @tool_tip.bitmap.height > Graphics.height ? Graphics.height - @tool_tip.bitmap.height : Mouse.y + 18
      refresh_tool_tip(@event_data[event_id].name, @event_data[event_id].width) unless @last_tip_name == @event_data[event_id].name
    end
  end
  
end
