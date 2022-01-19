#==============================================================================
# ** Window_UseChar
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de seleção de personagens.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_UseChar < Window_Base
  
  CURSOR_WIDTH  = 98
  CURSOR_HEIGHT = 98
  
  def initialize
    # Quando a resolução é alterada, as coordenadas x e y
    #são reajustadas no adjust_windows_position da Scene_Map
    super(adjust_x, adjust_y, 360, 190)
    self.closable = true
    self.title = Vocab::UseChar
    @create_button = Button.new(self, 240, 150, Vocab::Create, 97) { create_actor }
    @play_button = Button.new(self, 240, 150, Vocab::Play, 97) { use_actor }
    @delete_button = Button.new(self, 20, 150, Vocab::Delete, 97) { remove_actor }
    refresh
  end
  
  def adjust_x
    Graphics.width / 2 - 180
  end
  
  def adjust_y
    Graphics.height / 2 - 95
  end
  
  def hide_window
    DataManager.back_login
  end
  
  def refresh
    contents.clear
    bitmap = Cache.system('UseChar')
    contents.blt(7, 9, bitmap, Rect.new(0, 0, 318, 115))
    Configs::MAX_ACTORS.times do |actor_id|
      if $network.actors.has_key?(actor_id)
        draw_text(110 * actor_id + 8, 6, 98, line_height, $network.actors[actor_id].name, 1)
        draw_face($network.actors[actor_id].face_name, $network.actors[actor_id].face_index, 110 * actor_id + 8, 27) unless $network.actors[actor_id].face_name.empty?
        draw_actor_graphic($network.actors[actor_id], 110 * actor_id + 25, 120)
      else
        draw_text(110 * actor_id + 8, 6, 98, line_height, Vocab::Empty, 1)
      end
    end
    contents.blt(110 * $actor_id + 7, 26, bitmap, Rect.new(318, 0, CURSOR_WIDTH, CURSOR_HEIGHT))
    refresh_buttons
  end
  
  def refresh_buttons
    if $network.actors.has_key?($actor_id)
      @create_button.visible = false
      @play_button.visible = true
      @delete_button.visible = true
    else
      @create_button.visible = true
      @play_button.visible = false
      @delete_button.visible = false
    end
  end
  
  def remove_actor
    $windows[:password].show($actor_id)
  end
  
  def create_actor
    SceneManager.scene.change_background('Title3')
    $windows[:create_char].show($actor_id)
    $windows[:password].hide
    hide
  end
  
  def use_actor
    if Configs::LOADING_TIME == 0
      $network.send_use_actor($actor_id)
    else
      SceneManager.scene.change_background(Configs::LOADING_TITLES[rand(Configs::LOADING_TITLES.size)])
      SceneManager.scene.config_icon.visible = false
      SceneManager.scene.loading_bar.visible = true
      $windows[:vip_time].hide
      $windows[:password].hide
      $windows[:config].hide
      hide
    end
  end
  
  def update
    super
    close_windows
    next_actor if Input.trigger?(:RIGHT)
    prev_actor if Input.trigger?(:LEFT)
    remove_actor if Input.trigger?(:DELETE) && $network.actors.has_key?($actor_id)
    ok if Input.trigger?(:C)
    update_cursor
  end
  
  def close_windows
    return unless Input.trigger?(:B)
    #if $windows[:alert].visible || $windows[:config].visible || $windows[:password].visible
      $windows[:config].hide
      $windows[:password].hide
      $windows[:alert].hide
    #else
      #hide_window
    #end
  end
  
  def next_actor
    return if $actor_id == Configs::MAX_ACTORS - 1
    $actor_id += 1
    refresh
  end
  
  def prev_actor
    return if $actor_id == 0
    $actor_id -= 1
    refresh
  end
  
  def ok
    if !$network.actors.has_key?($actor_id)
      create_actor
    elsif $windows[:password].visible
      $windows[:password].delete
    elsif $windows[:alert].visible
      $windows[:alert].hide
    else
      use_actor
    end
  end
  
  def update_cursor
    return unless Mouse.click?(:L)
    Configs::MAX_ACTORS.times do |actor_id|
      if in_area?(110 * actor_id + 20, 39, CURSOR_WIDTH, CURSOR_HEIGHT)
        $actor_id = actor_id
        refresh
        break
      end
    end
  end
  
end
