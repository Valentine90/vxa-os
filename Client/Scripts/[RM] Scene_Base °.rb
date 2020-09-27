#==============================================================================
# ** Scene_Base
#------------------------------------------------------------------------------
#  Esta é a superclasse de todas as cenas do jogo.
#==============================================================================

class Scene_Base
  #--------------------------------------------------------------------------
  # * Processamento principal
  #--------------------------------------------------------------------------
  def main
    start
    post_start
    update until scene_changing?
    pre_terminate
    terminate
  end
  #--------------------------------------------------------------------------
  # * Inicialização do processo
  #--------------------------------------------------------------------------
  def start
    create_main_viewport
  end
  #--------------------------------------------------------------------------
  # * Processamento pós-inicio
  #--------------------------------------------------------------------------
  def post_start
    perform_transition
    Input.update
  end
  #--------------------------------------------------------------------------
  # * Definição de mudança de cenas
  #--------------------------------------------------------------------------
  def scene_changing?
    SceneManager.scene != self
  end
  #--------------------------------------------------------------------------
  # * Atualização da tela
  #--------------------------------------------------------------------------
  def update
    update_basic
    # VXA-OS
    $network.update if $network.connected?
  end
  #--------------------------------------------------------------------------
  # * Atualização da tela (básico)
  #--------------------------------------------------------------------------
  def update_basic
    Graphics.update
    # VXA-OS
    Mouse.update
    $cursor.update
    Input.update
    update_all_windows
  end
  #--------------------------------------------------------------------------
  # * Processamento pré finalização
  #--------------------------------------------------------------------------
  def pre_terminate
  end
  #--------------------------------------------------------------------------
  # * Finalização do processo
  #--------------------------------------------------------------------------
  def terminate
    Graphics.freeze
    dispose_all_windows
    dispose_main_viewport
  end
  #--------------------------------------------------------------------------
  # * Execução da transição
  #--------------------------------------------------------------------------
  def perform_transition
    Graphics.transition(transition_speed)
  end
  #--------------------------------------------------------------------------
  # * Aquisição da velocidade de transição
  #--------------------------------------------------------------------------
  def transition_speed
    return 10
  end
  #--------------------------------------------------------------------------
  # * Criação do viewport
  #--------------------------------------------------------------------------
  def create_main_viewport
    @viewport = Viewport.new
    @viewport.z = 200
  end
  #--------------------------------------------------------------------------
  # * Disposição do viewport
  #--------------------------------------------------------------------------
  def dispose_main_viewport
    @viewport.dispose
  end
  #--------------------------------------------------------------------------
  # * Atualização de todas as janelas
  #--------------------------------------------------------------------------
  def update_all_windows
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      ivar.update if ivar.is_a?(Window)
    end
  end
  #--------------------------------------------------------------------------
  # * Disposição de todas as janelas
  #--------------------------------------------------------------------------
  def dispose_all_windows
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      ivar.dispose if ivar.is_a?(Window)
    end
  end
  #--------------------------------------------------------------------------
  # * Chamada de retorno de cena
  #--------------------------------------------------------------------------
  def return_scene
    SceneManager.return
  end
  #--------------------------------------------------------------------------
  # * Efeito de fade out em massa
  #     time : duração (em milesegundo)
  #--------------------------------------------------------------------------
  def fadeout_all(time = 1000)
    RPG::BGM.fade(time)
    RPG::BGS.fade(time)
    RPG::ME.fade(time)
    Graphics.fadeout(time * Graphics.frame_rate / 1000)
    RPG::BGM.stop
    RPG::BGS.stop
    RPG::ME.stop
  end
=begin
  #--------------------------------------------------------------------------
  # * Definição de game over
  #--------------------------------------------------------------------------
  def check_gameover
    SceneManager.goto(Scene_Gameover) if $game_party.all_dead?
  end
=end
end
