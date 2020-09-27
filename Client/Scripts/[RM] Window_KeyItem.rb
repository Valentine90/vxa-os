#==============================================================================
# ** Window_KeyItem
#------------------------------------------------------------------------------
#  Esta janela é utilizada para o comando de eventos [Armazenar Número]
#==============================================================================

class Window_KeyItem < Window_ItemList
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #     message_window : janela de mensagem
  #--------------------------------------------------------------------------
  def initialize(message_window)
    @message_window = message_window
    super(0, 0, Graphics.width, fitting_height(4))
    self.openness = 0
    deactivate
    set_handler(:ok,     method(:on_ok))
    set_handler(:cancel, method(:on_cancel))
  end
  #--------------------------------------------------------------------------
  # * Inicialização do processo
  #--------------------------------------------------------------------------
  def start
    self.category = :key_item
    update_placement
    refresh
    select(0)
    open
    activate
  end
  #--------------------------------------------------------------------------
  # * Atualização da posição da janela
  #--------------------------------------------------------------------------
  def update_placement
    if @message_window.y >= Graphics.height / 2
      self.y = 0
    else
      self.y = Graphics.height - height
    end
  end
  #--------------------------------------------------------------------------
  # * Execução da confirmação
  #--------------------------------------------------------------------------
  def on_ok
    result = item ? item.id : 0
    $game_variables[$game_message.item_choice_variable_id] = result
    close
  end
  #--------------------------------------------------------------------------
  # * Execução do clancelamento
  #--------------------------------------------------------------------------
  def on_cancel
    $game_variables[$game_message.item_choice_variable_id] = 0
    close
  end
end
