#==============================================================================
# ** Scene_Login
#------------------------------------------------------------------------------
#  Esta classe lida com cena de entrada e criação de conta.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Scene_Login < Scene_Base
  
  def start
    super
    # Reseta o gráfico do cursor, a rede e o ID do herói
    #se retornou da cena do mapa
    $cursor.sprite_index = Enums::Cursor::NONE
    $network = Network.new
    $actor_id = 0
    SceneManager.clear
    Graphics.freeze
    create_background
    create_foreground
    create_all_windows
    play_title_music
    show_alert_message
  end
  
  def terminate
    super
    dispose_background
    dispose_foreground
  end
  
  def show_alert_message
    return unless $alert_msg
    $windows[:alert].show($alert_msg)
    $alert_msg = nil
  end
  
  def create_background
    @sprite1 = Sprite.new
    @sprite2 = Sprite.new
    @sprite2.bitmap = Cache.title2($data_system.title2_name)
    center_sprite(@sprite2)
  end
  
  def refresh_sprite1
    @sprite1.bitmap.dispose if @sprite1.bitmap
    @sprite1.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    bitmap = Cache.title1($data_system.title1_name)
    @sprite1.bitmap.stretch_blt(@sprite1.bitmap.rect, bitmap, bitmap.rect)
    center_sprite(@sprite1)
  end
  
  def create_foreground
    @foreground_sprite = Sprite.new
    @foreground_sprite.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @foreground_sprite.z = 100
  end
  
  def dispose_background
    @sprite1.bitmap.dispose
    @sprite1.dispose
    @sprite2.bitmap.dispose
    @sprite2.dispose
  end
  
  def dispose_foreground
    @foreground_sprite.bitmap.dispose
    @foreground_sprite.dispose
  end
  
  def center_sprite(sprite)
    sprite.ox = sprite.bitmap.width / 2
    sprite.oy = sprite.bitmap.height / 2
    sprite.x = Graphics.width / 2
    sprite.y = Graphics.height / 2
  end
  
  def create_all_windows
    $windows = {}
    $windows[:login] = Window_Login.new
    $windows[:create_acc] = Window_CreateAcc.new
    $windows[:alert] = Window_Alert.new
    $windows[:config] = Window_Config.new
    @config_icon = Icon.new(nil, 0, 0, Configs::CONFIG_ICON, Vocab::Configs) { $windows[:config].trigger }
    adjust_windows_position
  end
  
  def adjust_windows_position
    $windows[:login].x = $windows[:login].adjust_x
    $windows[:create_acc].x = $windows[:create_acc].adjust_x
    $windows[:alert].x = $windows[:alert].adjust_x
    $windows[:config].x = $windows[:config].adjust_x
    @config_icon.x = Graphics.width - 48
    @config_icon.y = Graphics.height - 58
    refresh_sprite1
  end
  
  def play_title_music
    $data_system.title_bgm.play
    RPG::BGS.stop
    RPG::ME.stop
  end
  
  def update_all_windows
    super
    @config_icon.update
  end
  
  def dispose_all_windows
    super
    @config_icon.dispose
  end
  
end
