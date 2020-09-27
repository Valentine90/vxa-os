#==============================================================================
# ** Scene_Base
#------------------------------------------------------------------------------
#  Esta é a superclasse de todas as cenas do jogo.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Scene_Base
  
  def update_all_windows
    $windows.each_value { |window| window.update if window.visible }
  end
  
  def dispose_all_windows
    $windows.each_value(&:dispose)
  end
  
end
