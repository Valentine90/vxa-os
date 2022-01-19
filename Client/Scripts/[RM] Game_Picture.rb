#==============================================================================
# ** Game_Picture
#------------------------------------------------------------------------------
#  Esta classe gerencia as informações das imagens.
# Esta classe é usada internamente pela classe Game_Pictures.
#==============================================================================

class Game_Picture
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :number                   # número da imagem
  attr_reader   :name                     # Nome do arquivo
  attr_reader   :origin                   # Origem do arquivo
  attr_reader   :x                        # Coordenada X
  attr_reader   :y                        # Coordenada Y
  attr_reader   :zoom_x                   # Taxa de Expansão na direção X
  attr_reader   :zoom_y                   # Taxa de Expansão na direção Y
  attr_reader   :opacity                  # Opacidade
  attr_reader   :blend_type               # Tipo de siteticidade
  attr_reader   :tone                     # Tonalidade
  attr_reader   :angle                    # Ângulo
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #     number : número da imagem (ID)
  #--------------------------------------------------------------------------
  def initialize(number)
    @number = number
    init_basic
    init_target
    init_tone
    init_rotate
  end
  #--------------------------------------------------------------------------
  # * Inicialização das variáveis ??básicas
  #--------------------------------------------------------------------------
  def init_basic
    @name = ""
    @origin = @x = @y = 0
    @zoom_x = @zoom_y = 100.0
    @opacity = 255.0
    @blend_type = 1
  end
  #--------------------------------------------------------------------------
  # * Inicialização dos valores alvo
  #--------------------------------------------------------------------------
  def init_target
    @target_x = @x
    @target_y = @y
    @target_zoom_x = @zoom_x
    @target_zoom_y = @zoom_y
    @target_opacity = @opacity
    @duration = 0
  end
  #--------------------------------------------------------------------------
  # * Inicialização da tonalidade
  #--------------------------------------------------------------------------
  def init_tone
    @tone = Tone.new
    @tone_target = Tone.new
    @tone_duration = 0
  end
  #--------------------------------------------------------------------------
  # * Inicialização da rotação
  #--------------------------------------------------------------------------
  def init_rotate
    @angle = 0
    @rotate_speed = 0
  end
  #--------------------------------------------------------------------------
  # * Exibição da imagem
  #     name         : nome do arquivo
  #     origin       : origem do arquivo
  #     x            : coordenada X
  #     y            : coordenada Y
  #     zoom_x       : coordenada X para zoom
  #     zoom_y       : coordenada Y para zoom
  #     opacity      : opacidade
  #     blend_type   : tipo de sinteticidade
  #--------------------------------------------------------------------------
  def show(name, origin, x, y, zoom_x, zoom_y, opacity, blend_type)
    @name = name
    @origin = origin
    @x = x.to_f
    @y = y.to_f
    @zoom_x = zoom_x.to_f
    @zoom_y = zoom_y.to_f
    @opacity = opacity.to_f
    @blend_type = blend_type
    init_target
    init_tone
    init_rotate
  end
  #--------------------------------------------------------------------------
  # * Movimento da imagem
  #     origin       : origem
  #     x            : coordenada X
  #     y            : coordenada Y
  #     zoom_x       : coordenada X para zoom
  #     zoom_y       : coordenada Y para zoom
  #     opacity      : opacidade
  #     blend_type   : tipo de sinteticidade
  #     duration     : tempo de duração
  #--------------------------------------------------------------------------
  def move(origin, x, y, zoom_x, zoom_y, opacity, blend_type, duration)
    @origin = origin
    @target_x = x.to_f
    @target_y = y.to_f
    @target_zoom_x = zoom_x.to_f
    @target_zoom_y = zoom_y.to_f
    @target_opacity = opacity.to_f
    @blend_type = blend_type
    @duration = duration
  end
  #--------------------------------------------------------------------------
  # * Rotação da imagem
  #     speed : velocidade da rotação
  #--------------------------------------------------------------------------
  def rotate(speed)
    @rotate_speed = speed
  end
  #--------------------------------------------------------------------------
  # Mudança de tonalidade
  #     tone     : tonalidade
  #     duration : tempo de duração
  #--------------------------------------------------------------------------
  def start_tone_change(tone, duration)
    @tone_target = tone.clone
    @tone_duration = duration
    @tone = @tone_target.clone if @tone_duration == 0
  end
  #--------------------------------------------------------------------------
  # * Limpeza da imagem
  #--------------------------------------------------------------------------
  def erase
    @name = ""
    @origin = 0
  end
  #--------------------------------------------------------------------------
  # * Atualização da tela
  #--------------------------------------------------------------------------
  def update
    update_move
    update_tone_change
    update_rotate
  end
  #--------------------------------------------------------------------------
  # * Atualização do movimento
  #--------------------------------------------------------------------------
  def update_move
    return if @duration == 0
    d = @duration
    @x = (@x * (d - 1) + @target_x) / d
    @y = (@y * (d - 1) + @target_y) / d
    @zoom_x  = (@zoom_x  * (d - 1) + @target_zoom_x)  / d
    @zoom_y  = (@zoom_y  * (d - 1) + @target_zoom_y)  / d
    @opacity = (@opacity * (d - 1) + @target_opacity) / d
    @duration -= 1
  end
  #--------------------------------------------------------------------------
  # * Atualização da tonalidade
  #--------------------------------------------------------------------------
  def update_tone_change
    return if @tone_duration == 0
    d = @tone_duration
    @tone.red   = (@tone.red   * (d - 1) + @tone_target.red)   / d
    @tone.green = (@tone.green * (d - 1) + @tone_target.green) / d
    @tone.blue  = (@tone.blue  * (d - 1) + @tone_target.blue)  / d
    @tone.gray  = (@tone.gray  * (d - 1) + @tone_target.gray)  / d
    @tone_duration -= 1
  end
  #--------------------------------------------------------------------------
  # * Atualização da rotação
  #--------------------------------------------------------------------------
  def update_rotate
    return if @rotate_speed == 0
    @angle += @rotate_speed / 2.0
    @angle += 360 while @angle < 0
    @angle %= 360
  end
end
