#==============================================================================
# ** Window_Config
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de configurações.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Config < Window_Base
  
  def initialize
    # Quando a resolução é alterada, a coordenada x é
    #reajustada no adjust_windows_position da Scene_Map
    super(adjust_x, 155, 215, 261)
    self.visible = false
    self.closable = true
    # Evita que a barra de título fique embaixo das
    #janelas da cena do login
    self.z = 109
    self.title = Vocab::Configs
    Button.new(self, 78, 229, Vocab.save) { save }
    @music_slider = Input_Slider.new(self, 16, 31, 183) { change_music_volume }
    @sound_slider = Input_Slider.new(self, 16, 72, 183) { change_sound_volume }
    @music_slider.index = Audio.music_volume
    @sound_slider.index = Audio.sound_volume
    resolutions = Configs::RESOLUTIONS.map { |resolution| resolution.values.join('x') }
    @fullscreen_button = Radio_Button.new(self, [[16, 117, Vocab::Activated], [105, 117, Vocab::Disabled]], Audio.fullscreen) { toggle_fullscreen }
    @vsync_button = Radio_Button.new(self, [[17, 158, Vocab::Vsync], [104, 158, Vocab::NoLimit]], Audio.vsync) { vsync }
    @resolution_box = Combo_Box.new(self, 16, 202, 183, resolutions) { change_resolution }
    @resolution_box.index = Audio.resolution_id
  end
  
  def adjust_x
    Graphics.width / 2 - 107
  end
  
  def refresh
    # Evita que o texto seja redesenhado sobre ele mesmo
    #toda vez que a janela ficar visível
    contents.clear
    draw_text(0, 0, contents_width, line_height, "#{Vocab::Music} #{@music_slider.index}%", 1)
    draw_text(0, 41, contents_width, line_height, "#{Vocab::Sound} #{@sound_slider.index}%", 1)
    draw_text(0, 83, contents_width, line_height, Vocab::FullScreen, 1)
    draw_text(0, 126, contents_width, line_height, Vocab::FPS, 1)
    draw_text(0, 169, contents_width, line_height, Vocab::Resolution, 1)
  end
  
  def change_music_volume
    Audio.music_volume = @music_slider.index
    refresh
  end
  
  def change_sound_volume
    Audio.sound_volume = @sound_slider.index
    refresh
  end
  
  def change_resolution
    Audio.resolution_id = @resolution_box.index
    Graphics.resize_screen(Configs::RESOLUTIONS[Audio.resolution_id][:width], Configs::RESOLUTIONS[Audio.resolution_id][:height])
    SceneManager.scene.adjust_windows_position
  end
  
  def toggle_fullscreen
    Audio.fullscreen = @fullscreen_button.index
  end
  
  def vsync
    Audio.vsync = @vsync_button.index
  end
  
  def save
    Audio.save
    hide
  end
  
end
