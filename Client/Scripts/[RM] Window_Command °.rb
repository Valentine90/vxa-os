#==============================================================================
# ** Window_Command
#------------------------------------------------------------------------------
#  Esta janela lida com seleção geral de comandos.
#==============================================================================

class Window_Command < Window_Selectable
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #     x      : coordenada X
  #     y      : coordenada Y
  #--------------------------------------------------------------------------
  def initialize(x, y)
    clear_command_list
    make_command_list
    super(x, y, window_width, window_height)
    refresh
    select(0)
    activate
  end
  #--------------------------------------------------------------------------
  # * Aquisição da largura da janela
  #--------------------------------------------------------------------------
  def window_width
    return 160
  end
  #--------------------------------------------------------------------------
  # * Aquisição da altura da janela
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(visible_line_number)
  end
  #--------------------------------------------------------------------------
  # * Aquisição do número de linhas exibidas
  #--------------------------------------------------------------------------
  def visible_line_number
    item_max
  end
  #--------------------------------------------------------------------------
  # * Aquisição do número máximo de itens
  #--------------------------------------------------------------------------
  def item_max
    @list.size
  end
  #--------------------------------------------------------------------------
  # * Limpeza da lista de comandos
  #--------------------------------------------------------------------------
  def clear_command_list
    @list = []
  end
  #--------------------------------------------------------------------------
  # * Criação da lista de comandos
  #--------------------------------------------------------------------------
  def make_command_list
  end
  #--------------------------------------------------------------------------
  # * Adição de um comando
  #     name    : nome do comando
  #     symbol  : símbolo correspondente
  #     enabled : flag de estado ativo
  #     ext     : quaisquer dados extras
  #--------------------------------------------------------------------------
  def add_command(name, symbol, enabled = true, ext = nil)
    @list.push({name: name, symbol: symbol, enabled: enabled, ext: ext})
  end
  #--------------------------------------------------------------------------
  # * Aquisição do nome do comando
  #     index : índice do comando
  #--------------------------------------------------------------------------
  def command_name(index)
    @list[index][:name]
  end
  #--------------------------------------------------------------------------
  # * Definição de habilitação do comando
  #     index : índice do comando
  #--------------------------------------------------------------------------
  def command_enabled?(index)
    @list[index][:enabled]
  end
  #--------------------------------------------------------------------------
  # * Aquisição dos dados do item selecionado
  #--------------------------------------------------------------------------
  def current_data
    index >= 0 ? @list[index] : nil
  end
  #--------------------------------------------------------------------------
  # * Definição de habilitação do item selecionado
  #--------------------------------------------------------------------------
  def current_item_enabled?
    current_data ? current_data[:enabled] : false
  end
  #--------------------------------------------------------------------------
  # * Aquisição do símbolo do item selecionado
  #--------------------------------------------------------------------------
  def current_symbol
    current_data ? current_data[:symbol] : nil
  end
  #--------------------------------------------------------------------------
  # * Aquisição dos dados extra do item selecionado
  #--------------------------------------------------------------------------
  def current_ext
    current_data ? current_data[:ext] : nil
  end
  #--------------------------------------------------------------------------
  # * Movimento do cursor para o comando com um símbolo especificado
  #--------------------------------------------------------------------------
  def select_symbol(symbol)
    @list.each_index {|i| select(i) if @list[i][:symbol] == symbol }
  end
  #--------------------------------------------------------------------------
  # * Movimento do cursor para o comando com um dado extra especificado
  #--------------------------------------------------------------------------
  def select_ext(ext)
    @list.each_index {|i| select(i) if @list[i][:ext] == ext }
  end
  #--------------------------------------------------------------------------
  # * Desenho do item
  #     index : índice do item
  #--------------------------------------------------------------------------
  def draw_item(index)
    change_color(normal_color, command_enabled?(index))
    draw_text(item_rect_for_text(index), command_name(index), alignment)
  end
  #--------------------------------------------------------------------------
  # * Aquisição do alinhamento do texto
  #--------------------------------------------------------------------------
  def alignment
    return 0
  end
  #--------------------------------------------------------------------------
  # * Definição de confirmação
  #--------------------------------------------------------------------------
  def ok_enabled?
    return true
  end
  #--------------------------------------------------------------------------
  # * Chamada de controlador de confirmação
  #--------------------------------------------------------------------------
  def call_ok_handler
    if handle?(current_symbol)
      call_handler(current_symbol)
    elsif handle?(:ok)
      super
    else
      activate
    end
  end
  #--------------------------------------------------------------------------
  # * Renovação
  #--------------------------------------------------------------------------
  def refresh
    clear_command_list
    make_command_list
    # VXA-OS
    #create_contents
    super
  end
end
