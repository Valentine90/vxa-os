#==============================================================================
# ** Scene_Character
#------------------------------------------------------------------------------
#  Esta classe lida com cena de seleção e criação de personagens.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Scene_Character < Scene_Base
  
  attr_reader   :config_icon, :loading_bar
  
  def start
    super
    # Reseta o gráfico do cursor se retornou da cena do mapa
    $cursor.sprite_index = Enums::Cursor::NONE
    SceneManager.clear
    Graphics.freeze
    create_background
    create_all_windows
    @loading_count = 0
  end
  
  def terminate
    super
    dispose_background
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
    bitmap = Cache.title1('Title2')
    @sprite1.bitmap.stretch_blt(@sprite1.bitmap.rect, bitmap, bitmap.rect)
    center_sprite(@sprite1)
  end
  
  def change_background(title)
    bitmap = Cache.title1(title)
    @sprite1.bitmap.clear
    @sprite1.bitmap.stretch_blt(@sprite1.bitmap.rect, bitmap, bitmap.rect)
  end
  
  def dispose_background
    @sprite1.bitmap.dispose
    @sprite1.dispose
    @sprite2.bitmap.dispose
    @sprite2.dispose
  end
  
  def center_sprite(sprite)
    sprite.ox = sprite.bitmap.width / 2
    sprite.oy = sprite.bitmap.height / 2
    sprite.x = Graphics.width / 2
    sprite.y = Graphics.height / 2
  end
  
  def create_all_windows
    $windows = {}
    $windows[:vip_time] = Window_VIPTime.new
    $windows[:create_char] = Window_CreateChar.new
    # A Window_Password é instanciada logo para que
    #a sua caixa de texto fique ativa ao clicar no botão
    #Apagar da janela de seleção de personagens, que é
    #instanciada em seguida
    $windows[:password] = Window_Password.new
    $windows[:use_char] = Window_UseChar.new
    $windows[:alert] = Window_Alert.new
    $windows[:config] = Window_Config.new
    @config_icon = Icon.new(nil, 0, 0, Configs::CONFIG_ICON, Vocab::Configs) { $windows[:config].trigger }
    @loading_bar = Progress_Bar.new(nil, 0, 0, Graphics.width - 100, 100)
    @loading_bar.visible = false
    adjust_windows_position
  end
  
  def adjust_windows_position
    $windows[:vip_time].x = $windows[:vip_time].adjust_x
    $windows[:vip_time].y = $windows[:vip_time].adjust_y
    $windows[:create_char].x = $windows[:create_char].adjust_x
    $windows[:create_char].y = $windows[:create_char].adjust_y
    $windows[:use_char].x = $windows[:use_char].adjust_x
    $windows[:use_char].y = $windows[:use_char].adjust_y
    $windows[:alert].x = $windows[:alert].adjust_x
    $windows[:password].x = $windows[:password].adjust_x
    $windows[:config].x = $windows[:config].adjust_x
    @config_icon.x = Graphics.width - 48
    @config_icon.y = Graphics.height - 58
    # Primeiro recria a barra de carregamento, depois
    #define as coordenadas x e y
    @loading_bar.width = Graphics.width - 100
    @loading_bar.x = (Graphics.width - @loading_bar.width) / 2
    @loading_bar.y = Graphics.height - 100
    refresh_sprite1
  end
  
  def update_all_windows
    super
    @config_icon.update
    @loading_bar.update
    update_loading
  end
  
  def update_loading
    return unless @loading_bar.visible
    return if @loading_bar.index == 100
    @loading_count += 1
    if @loading_count >= Configs::LOADING_TIME / 2.5
      @loading_bar.index += 1
      @loading_bar.text = "#{@loading_bar.index}%"
      @loading_count = 0
    end
    $network.send_use_actor($actor_id) if @loading_bar.index == 100
  end
  
  def dispose_all_windows
    super
    @config_icon.dispose
    @loading_bar.dispose
  end
  
end
