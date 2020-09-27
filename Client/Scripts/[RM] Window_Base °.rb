#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  Esta é a superclasse para todas as janelas no jogo.
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #     x      : coordenada X
  #     y      : coordenada Y
  #     width  : largura
  #     height : altura
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    self.windowskin = Cache.system("Window")
    update_padding
    update_tone
    create_contents
    # VXA-OS
    init_features
    @opening = @closing = false
  end
  #--------------------------------------------------------------------------
  # * Disposição
  #--------------------------------------------------------------------------
  def dispose
    contents.dispose unless disposed?
    # VXA-OS
    dispose_features
    super
  end
  #--------------------------------------------------------------------------
  # * Aquisição da altura da linha
  #--------------------------------------------------------------------------
  def line_height
    return 24
  end
  #--------------------------------------------------------------------------
  # * Espaçamento lateral padrão
  #--------------------------------------------------------------------------
  def standard_padding
    return 12
  end
  #--------------------------------------------------------------------------
  # * Atualização do espaçamento
  #--------------------------------------------------------------------------
  def update_padding
    self.padding = standard_padding
  end
  #--------------------------------------------------------------------------
  # * Cálculo da largura do conteúdo da janela
  #--------------------------------------------------------------------------
  def contents_width
    width - standard_padding * 2
  end
  #--------------------------------------------------------------------------
  # * Cálculo da altura do conteúdo da janela
  #--------------------------------------------------------------------------
  def contents_height
    height - standard_padding * 2
  end
  #--------------------------------------------------------------------------
  # * Cálculo da altura da janela de acordo com número de linhas
  #     line_number : número de linhas
  #--------------------------------------------------------------------------
  def fitting_height(line_number)
    line_number * line_height + standard_padding * 2
  end
  #--------------------------------------------------------------------------
  # * Atualização da tonalidade
  #--------------------------------------------------------------------------
  def update_tone
    self.tone.set($game_system.window_tone)
  end
  #--------------------------------------------------------------------------
  # * Criação do conteúdo das janelas
  #--------------------------------------------------------------------------
  def create_contents
    contents.dispose
    if contents_width > 0 && contents_height > 0
      self.contents = Bitmap.new(contents_width, contents_height)
    else
      self.contents = Bitmap.new(1, 1)
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização da tela
  #--------------------------------------------------------------------------
  def update
    super
    update_tone
    update_open if @opening
    update_close if @closing
    # VXA-OS
    update_features
  end
  #--------------------------------------------------------------------------
  # * Atualização de abertura
  #--------------------------------------------------------------------------
  def update_open
    self.openness += 48
    @opening = false if open?
  end
  #--------------------------------------------------------------------------
  # * Atualização de fechamento
  #--------------------------------------------------------------------------
  def update_close
    self.openness -= 48
    @closing = false if close?
  end
  #--------------------------------------------------------------------------
  # * Abertura da janela
  #--------------------------------------------------------------------------
  def open
    @opening = true unless open?
    @closing = false
    self
  end
  #--------------------------------------------------------------------------
  # * Fechamento da janela
  #--------------------------------------------------------------------------
  def close
    @closing = true unless close?
    @opening = false
    self
  end
  #--------------------------------------------------------------------------
  # * Exibição da janela
  #--------------------------------------------------------------------------
  def show
    self.visible = true
    self
  end
  #--------------------------------------------------------------------------
  # * Ocultação da janela
  #--------------------------------------------------------------------------
  def hide
    self.visible = false
    self
  end
  #--------------------------------------------------------------------------
  # * Ativação da janela
  #--------------------------------------------------------------------------
  def activate
    self.active = true
    self
  end
  #--------------------------------------------------------------------------
  # * Desativação da janela
  #--------------------------------------------------------------------------
  def deactivate
    self.active = false
    self
  end
  #--------------------------------------------------------------------------
  # * Aquisição da cor do texto
  #     n : número da cor do texto （0..31）
  #--------------------------------------------------------------------------
  def text_color(n)
    windowskin.get_pixel(64 + (n % 8) * 8, 96 + (n / 8) * 8)
  end
  #--------------------------------------------------------------------------
  # * Aquisição de cor do texto
  #--------------------------------------------------------------------------
  def normal_color;      text_color(0);   end;    # Normal
  def system_color;      text_color(16);  end;    # Sistema
  def crisis_color;      text_color(17);  end;    # Perigo
  def knockout_color;    text_color(18);  end;    # Incapacitação
  def gauge_back_color;  text_color(19);  end;    # Fundo do Medidor
  def hp_gauge_color1;   text_color(20);  end;    # Medidor de HP 1
  def hp_gauge_color2;   text_color(21);  end;    # Medidor de HP 2
  def mp_gauge_color2;   text_color(23);  end;    # Medidor de P 1
  def mp_gauge_color1;   text_color(22);  end;    # Medidor de MP 1
  def mp_cost_color;     text_color(23);  end;    # Consumo de MP
  def power_up_color;    text_color(24);  end;    # Fortalecimento
  def power_down_color;  text_color(25);  end;    # Enfraquecimento
  def tp_gauge_color1;   text_color(28);  end;    # Medidor de TP 1
  def tp_gauge_color2;   text_color(29);  end;    # Medidor de TP 2
  def tp_cost_color;     text_color(29);  end;    # Consumo de TP
  #--------------------------------------------------------------------------
  # * Aquisição da cor do espaçamento
  #--------------------------------------------------------------------------
  def pending_color
    windowskin.get_pixel(80, 80)
  end
  #--------------------------------------------------------------------------
  # * Aquisção do valor de transparência
  #--------------------------------------------------------------------------
  def translucent_alpha
    return 160
  end
  #--------------------------------------------------------------------------
  # * Alteração da cor do texto
  #     enabled : habilitar flag, translucido quando false
  #--------------------------------------------------------------------------
  def change_color(color, enabled = true)
    contents.font.color.set(color)
    contents.font.color.alpha = translucent_alpha unless enabled
  end
  #--------------------------------------------------------------------------
  # * Desenho do texto
  #     args : Bitmap.draw_text
  #--------------------------------------------------------------------------
  def draw_text(*args)
    contents.draw_text(*args)
  end
  #--------------------------------------------------------------------------
  # * Aquisição do tamanho do texto
  #     str : string de texto
  #--------------------------------------------------------------------------
  def text_size(str)
    contents.text_size(str)
  end
  #--------------------------------------------------------------------------
  # * Desenho do texto com caracteres de controle
  #     x    : coordenada X
  #     y    : coordenada Y
  #     text : string de texto
  #--------------------------------------------------------------------------
  def draw_text_ex(x, y, text)
    reset_font_settings
    text = convert_escape_characters(text)
    pos = {x: x, y: y, new_x: x, height: calc_line_height(text)}
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end
  #--------------------------------------------------------------------------
  # * Redefinição das configurações de fonte
  #--------------------------------------------------------------------------
  def reset_font_settings
    change_color(normal_color)
    contents.font.size = Font.default_size
    contents.font.bold = false
    contents.font.italic = false
  end
  #--------------------------------------------------------------------------
  # * Pré-conversão dos caracteres de controle
  #    Antes de começar o desenho rea, substituir as strings.
  #    Converte o caractere "\" para como caractere de escape (\e)
  #--------------------------------------------------------------------------
  def convert_escape_characters(text)
    result = text.to_s.clone
    result.gsub!(/\\/)            { "\e" }
    result.gsub!(/\e\e/)          { "\\" }
    result.gsub!(/\eV\[(\d+)\]/i) { $game_variables[$1.to_i] }
    result.gsub!(/\eV\[(\d+)\]/i) { $game_variables[$1.to_i] }
    result.gsub!(/\eN\[(\d+)\]/i) { actor_name($1.to_i) }
    result.gsub!(/\eP\[(\d+)\]/i) { party_member_name($1.to_i) }
    result.gsub!(/\eG/i)          { Vocab::currency_unit }
    result
  end
  #--------------------------------------------------------------------------
  # * Aquisição do nome real de um herói
  #     n : ID do herói
  #--------------------------------------------------------------------------
  def actor_name(n)
    actor = n >= 1 ? $game_actors[n] : nil
    actor ? actor.name : ""
  end
  #--------------------------------------------------------------------------
  # * Aquisição do nome real de um herói no grupo
  #     n : índice do herói
  #--------------------------------------------------------------------------
  def party_member_name(n)
    actor = n >= 1 ? $game_party.members[n - 1] : nil
    actor ? actor.name : ""
  end
  #--------------------------------------------------------------------------
  # * Processamento de caracteres
  #     c    : caractere
  #     text : texto a ser desenhado
  #     pos  : posição de desenho {:x, :y, :new_x, :height}
  #--------------------------------------------------------------------------
  def process_character(c, text, pos)
    case c
    when "\n"   # Quebra de linha
      process_new_line(text, pos)
    when "\f"   # Quebra de página
      process_new_page(text, pos)
    when "\e"   # Caractere de controle
      process_escape_character(obtain_escape_code(text), text, pos)
    else        # Caracteres comuns
      process_normal_character(c, pos)
    end
  end
  #--------------------------------------------------------------------------
  # * Processamento de caracteres comuns
  #     c   : caractere
  #     pos : posição de desenho {:x, :y, :new_x, :height}
  #--------------------------------------------------------------------------
  def process_normal_character(c, pos)
    text_width = text_size(c).width
    draw_text(pos[:x], pos[:y], text_width * 2, pos[:height], c)
    pos[:x] += text_width
  end
  #--------------------------------------------------------------------------
  # * Processamento de caracteres de nova linha
  #     text : texto a ser desenhado
  #     pos  : posição de desenho {:x, :y, :new_x, :height}
  #--------------------------------------------------------------------------
  def process_new_line(text, pos)
    pos[:x] = pos[:new_x]
    pos[:y] += pos[:height]
    pos[:height] = calc_line_height(text)
  end
  #--------------------------------------------------------------------------
  # * Processamento de caracteres de nova página
  #     text : texto a ser desenhado
  #     pos  : posição de desenho {:x, :y, :new_x, :height}
  #--------------------------------------------------------------------------
  def process_new_page(text, pos)
  end
  #--------------------------------------------------------------------------
  # * Aquisição destrutiva de caracters de controle
  #     text : texto a ser desenhado
  #--------------------------------------------------------------------------
  def obtain_escape_code(text)
    text.slice!(/^[\$\.\|\^!><\{\}\\]|^[A-Z]+/i)
  end
  #--------------------------------------------------------------------------
  # * Aquisição dos parâmetros dos caracters de controle
  #     text : texto a ser desenhado
  #--------------------------------------------------------------------------
  def obtain_escape_param(text)
    text.slice!(/^\[\d+\]/)[/\d+/].to_i rescue 0
  end
  #--------------------------------------------------------------------------
  # * Processamento de caracteres de controle
  #     code : parte principal do caractere de controle （「C」 se 「\C[1]」）
  #     text : texto a ser desenhado
  #     pos  : posição de desenho {:x, :y, :new_x, :height}
  #--------------------------------------------------------------------------
  def process_escape_character(code, text, pos)
    case code.upcase
    when 'C'
      change_color(text_color(obtain_escape_param(text)))
    when 'I'
      process_draw_icon(obtain_escape_param(text), pos)
    when '{'
      make_font_bigger
    when '}'
      make_font_smaller
    end
  end
  #--------------------------------------------------------------------------
  # * Processamento de desenho de ícones
  #     icon_index : índice do ícone
  #     pos        : posição de desenho {:x, :y, :new_x, :height}
  #--------------------------------------------------------------------------
  def process_draw_icon(icon_index, pos)
    draw_icon(icon_index, pos[:x], pos[:y])
    pos[:x] += 24
  end
  #--------------------------------------------------------------------------
  # * Aumento de tamanho da fonte
  #--------------------------------------------------------------------------
  def make_font_bigger
    contents.font.size += 8 if contents.font.size <= 64
  end
  #--------------------------------------------------------------------------
  # * Redução de tamanho da fonte
  #--------------------------------------------------------------------------
  def make_font_smaller
    contents.font.size -= 8 if contents.font.size >= 16
  end
  #--------------------------------------------------------------------------
  # * Calculo da altura da linha
  #     text              : texto a ser desenhado
  #     restore_font_size : reverter tamanho da fonte para o cálculo
  #--------------------------------------------------------------------------
  def calc_line_height(text, restore_font_size = true)
    result = [line_height, contents.font.size].max
    last_font_size = contents.font.size
    text.slice(/^.*$/).scan(/\e[\{\}]/).each do |esc|
      make_font_bigger  if esc == "\e{"
      make_font_smaller if esc == "\e}"
      result = [result, contents.font.size].max
    end
    contents.font.size = last_font_size if restore_font_size
    result
  end
  #--------------------------------------------------------------------------
  # * Desenho do medidor
  #     x      : coordenada X
  #     y      : coordenada Y
  #     width  : largura
  #     rate   : percentual （1.0 completo）
  #     color1 : gradiente mais à esquerda
  #     color2 : gradiente mais à direita
  #--------------------------------------------------------------------------
  def draw_gauge(x, y, width, rate, color1, color2)
    fill_w = (width * rate).to_i
    gauge_y = y + line_height - 8
    contents.fill_rect(x, gauge_y, width, 6, gauge_back_color)
    contents.gradient_fill_rect(x, gauge_y, fill_w, 6, color1, color2)
  end
  #--------------------------------------------------------------------------
  # * Desenho de ícones
  #     icon_index : índice do ícone
  #     x          : coordenada X
  #     y          : coordenada Y
  #     enabled    : habilitar flag, translucido quando false
  #--------------------------------------------------------------------------
  def draw_icon(icon_index, x, y, enabled = true)
    bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    contents.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
  end
  #--------------------------------------------------------------------------
  # * Desenho do gráfico de rosto
  #     face_name  : nome do gráfico de face
  #     face_index : índice do gráfico de face
  #     x          : coordenada X
  #     y          : coordenada Y
  #     enabled    : habilitar flag, translucido quando false
  #--------------------------------------------------------------------------
  def draw_face(face_name, face_index, x, y, enabled = true)
    bitmap = Cache.face(face_name)
    rect = Rect.new(face_index % 4 * 96, face_index / 4 * 96, 96, 96)
    contents.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
    bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # * Desenho do gráfico do personagem
  #     character_name  : nome do gráfico do personagem
  #     character_index : índice do gráfico de personagem
  #     x               : coordenada X
  #     y               : coordenada Y
  #--------------------------------------------------------------------------
  def draw_character(character_name, character_index, x, y)
    return unless character_name
    bitmap = Cache.character(character_name)
    sign = character_name[/^[\!\$]./]
    if sign && sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = character_index
    src_rect = Rect.new((n%4*3+1)*cw, (n/4*4)*ch, cw, ch)
    contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
  end
  #--------------------------------------------------------------------------
  # * Aquisição de cor do texto de HP
  #    actor : herói
  #--------------------------------------------------------------------------
  def hp_color(actor)
    return knockout_color if actor.hp == 0
    return crisis_color if actor.hp < actor.mhp / 4
    return normal_color
  end
  #--------------------------------------------------------------------------
  # * Aquisição de cor do texto de MP
  #    actor : herói
  #--------------------------------------------------------------------------
  def mp_color(actor)
    return crisis_color if actor.mp < actor.mmp / 4
    return normal_color
  end
  #--------------------------------------------------------------------------
  # * Aquisição de cor do texto de YP
  #    actor : herói
  #--------------------------------------------------------------------------
  def tp_color(actor)
    return normal_color
  end
  #--------------------------------------------------------------------------
  # * Desenho do gráfico de personagem do herói
  #     actor : herói
  #     x     : coordenada X
  #     y     : coordenada Y
  #--------------------------------------------------------------------------
  def draw_actor_graphic(actor, x, y)
    draw_character(actor.character_name, actor.character_index, x, y)
  end
  #--------------------------------------------------------------------------
  # * Desenho do gráfico de face do herói
  #     actor   : herói
  #     x       : coordenada X
  #     y       : coordenada Y
  #     enabled : habilitar flag, translucido quando false
  #--------------------------------------------------------------------------
  def draw_actor_face(actor, x, y, enabled = true)
    draw_face(actor.face_name, actor.face_index, x, y, enabled)
  end
  #--------------------------------------------------------------------------
  # * Desenho do nome
  #     actor  : herói
  #     x      : coordenada X
  #     y      : coordenada Y
  #     width  : largura
  #--------------------------------------------------------------------------
  def draw_actor_name(actor, x, y, width = 112)
    change_color(hp_color(actor))
    draw_text(x, y, width, line_height, actor.name)
  end
  #--------------------------------------------------------------------------
  # * Desenho da classe
  #     actor  : herói
  #     x      : coordenada X
  #     y      : coordenada Y
  #     width  : largura
  #--------------------------------------------------------------------------
  def draw_actor_class(actor, x, y, width = 112)
    change_color(normal_color)
    draw_text(x, y, width, line_height, actor.class.name)
  end
  #--------------------------------------------------------------------------
  # * Desenho do segundo nome
  #     actor  : herói
  #     x      : coordenada X
  #     y      : coordenada Y
  #     width  : largura
  #--------------------------------------------------------------------------
  def draw_actor_nickname(actor, x, y, width = 180)
    change_color(normal_color)
    draw_text(x, y, width, line_height, actor.nickname)
  end
  #--------------------------------------------------------------------------
  # * Desenho do nível
  #     actor : herói
  #     x     : coordenada X
  #     y     : coordenada Y
  #--------------------------------------------------------------------------
  def draw_actor_level(actor, x, y)
    change_color(system_color)
    draw_text(x, y, 32, line_height, Vocab::level_a)
    change_color(normal_color)
    draw_text(x + 32, y, 24, line_height, actor.level, 2)
  end
  #--------------------------------------------------------------------------
  # * Desenho dos ícones de estado, foralecimento e enfraquecimento
  #     actor  : herói
  #     x      : coordenada X
  #     y      : coordenada Y
  #     width  : largura
  #--------------------------------------------------------------------------
  def draw_actor_icons(actor, x, y, width = 96)
    icons = (actor.state_icons + actor.buff_icons)[0, width / 24]
    icons.each_with_index {|n, i| draw_icon(n, x + 24 * i, y) }
  end
  #--------------------------------------------------------------------------
  # * Desenho de informação na forma valor atual/valor total
  #     x       : coordenada X
  #     y       : coordenada Y
  #     width   : largura
  #     current : valor atual
  #     max     : valor total
  #     color1  : cor do valor atual
  #     color2  : cor do valor totak
  #--------------------------------------------------------------------------
  def draw_current_and_max_values(x, y, width, current, max, color1, color2)
    change_color(color1)
    xr = x + width
    if width < 96
      draw_text(xr - 40, y, 42, line_height, current, 2)
    else
      draw_text(xr - 92, y, 42, line_height, current, 2)
      change_color(color2)
      draw_text(xr - 52, y, 12, line_height, "/", 2)
      draw_text(xr - 42, y, 42, line_height, max, 2)
    end
  end
  #--------------------------------------------------------------------------
  # * Desenho do HP
  #     actor  : herói
  #     x      : coordenada X
  #     y      : coordenada Y
  #     width  : largura
  #--------------------------------------------------------------------------
  def draw_actor_hp(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.hp_rate, hp_gauge_color1, hp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::hp_a)
    draw_current_and_max_values(x, y, width, actor.hp, actor.mhp,
      hp_color(actor), normal_color)
  end
  #--------------------------------------------------------------------------
  # * Desenho do MP
  #     actor  : herói
  #     x      : coordenada X
  #     y      : coordenada Y
  #     width  : largura
  #--------------------------------------------------------------------------
  def draw_actor_mp(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.mp_rate, mp_gauge_color1, mp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::mp_a)
    draw_current_and_max_values(x, y, width, actor.mp, actor.mmp,
      mp_color(actor), normal_color)
  end
  #--------------------------------------------------------------------------
  # * Desenho do TP
  #     actor  : herói
  #     x      : coordenada X
  #     y      : coordenada Y
  #     width  : largura
  #--------------------------------------------------------------------------
  def draw_actor_tp(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.tp_rate, tp_gauge_color1, tp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::tp_a)
    change_color(tp_color(actor))
    draw_text(x + width - 42, y, 42, line_height, actor.tp.to_i, 2)
  end
  #--------------------------------------------------------------------------
  # * Desenho dos atributos básicos
  #     actor : herói
  #     x     : coordenada X
  #     y     : coordenada Y
  #--------------------------------------------------------------------------
  def draw_actor_simple_status(actor, x, y)
    draw_actor_name(actor, x, y)
    draw_actor_level(actor, x, y + line_height * 1)
    draw_actor_icons(actor, x, y + line_height * 2)
    draw_actor_class(actor, x + 120, y)
    draw_actor_hp(actor, x + 120, y + line_height * 1)
    draw_actor_mp(actor, x + 120, y + line_height * 2)
  end
  #--------------------------------------------------------------------------
  # * Desenho dos parâmetros
  #     actor : herói
  #     x     : coordenada X
  #     y     : coordenada Y
  #--------------------------------------------------------------------------
  def draw_actor_param(actor, x, y, param_id)
    change_color(system_color)
    draw_text(x, y, 120, line_height, Vocab::param(param_id))
    change_color(normal_color)
    draw_text(x + 120, y, 36, line_height, actor.param(param_id), 2)
  end
  #--------------------------------------------------------------------------
  # * Desenho do nome de itens
  #     item    : objeto
  #     x       : coordenada X
  #     y       : coordenada Y
  #     enabled : habilitar flag, translucido quando false
  #     width   : largura
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    change_color(normal_color, enabled)
    draw_text(x + 24, y, width, line_height, item.name)
  end
  #--------------------------------------------------------------------------
  # * Desenho do dinheiro
  #     value : valor
  #     unit  : unidade monetária
  #     x     : coordenada X
  #     y     : coordenada Y
  #     width : largura
  #--------------------------------------------------------------------------
  def draw_currency_value(value, unit, x, y, width)
    cx = text_size(unit).width
    change_color(normal_color)
    draw_text(x, y, width - cx - 2, line_height, value, 2)
    change_color(system_color)
    draw_text(x, y, width, line_height, unit, 2)
  end
  #--------------------------------------------------------------------------
  # * Mudança de parâmetro
  #     change : valor demudança
  #--------------------------------------------------------------------------
  def param_change_color(change)
    return power_up_color   if change > 0
    return power_down_color if change < 0
    return normal_color
  end
end
