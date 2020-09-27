#==============================================================================
# ** SceneManager
#------------------------------------------------------------------------------
#  Este módulo gerencia as transições de cena. Por exemplo, da tela de itens
# para tela do do menu principal. Você pode chama-la para lidar com tal
# estrutura hierárquica e de volta.
#==============================================================================

module SceneManager
  #--------------------------------------------------------------------------
  # * Variáve de instância
  #--------------------------------------------------------------------------
  @scene = nil                            # Cena atual
  @stack = []                             # lista para transição
  @background_bitmap = nil                # bitmap de fundo
  #--------------------------------------------------------------------------
  # * Execução
  #--------------------------------------------------------------------------
  def self.run
    DataManager.init
    Audio.setup_midi if use_midi?
    @scene = first_scene_class.new
    @scene.main while @scene
  end
  #--------------------------------------------------------------------------
  # * VXA-OS
  #--------------------------------------------------------------------------
  def self.first_scene_class
    Scene_Login
  end
  #--------------------------------------------------------------------------
  # * Definição de uso de MIDI
  #--------------------------------------------------------------------------
  def self.use_midi?
    $data_system.opt_use_midi
  end
  #--------------------------------------------------------------------------
  # * Cena atual
  #--------------------------------------------------------------------------
  def self.scene
    @scene
  end
  #--------------------------------------------------------------------------
  # * Defição de classe da cena atual
  #     scene_class : cena atual
  #--------------------------------------------------------------------------
  def self.scene_is?(scene_class)
    @scene.instance_of?(scene_class)
  end
  #--------------------------------------------------------------------------
  # * Transição direta
  #     scene_class : nova cena
  #--------------------------------------------------------------------------
  def self.goto(scene_class)
    @scene = scene_class.new
  end
  #--------------------------------------------------------------------------
  # * Chamada
  #     scene_class : nova cena
  #--------------------------------------------------------------------------
  def self.call(scene_class)
    @stack.push(@scene)
    @scene = scene_class.new
  end
  #--------------------------------------------------------------------------
  # * Retorno de cena
  #--------------------------------------------------------------------------
  def self.return
    @scene = @stack.pop
  end
  #--------------------------------------------------------------------------
  # * Limpeza da lista de cenas
  #--------------------------------------------------------------------------
  def self.clear
    @stack.clear
  end
  #--------------------------------------------------------------------------
  # * Saida do jogo
  #--------------------------------------------------------------------------
  def self.exit
    @scene = nil
  end
  #--------------------------------------------------------------------------
  # * Snapshot para usar como fundo
  #--------------------------------------------------------------------------
  def self.snapshot_for_background
    @background_bitmap.dispose if @background_bitmap
    @background_bitmap = Graphics.snap_to_bitmap
    @background_bitmap.blur
  end
  #--------------------------------------------------------------------------
  # * Aquisição do bitmap de fundo
  #--------------------------------------------------------------------------
  def self.background_bitmap
    @background_bitmap
  end
end
