#==============================================================================
# ** Game_Screen
#------------------------------------------------------------------------------
#  Esta classe gerencia a manutenção das informações da tela, como mudança
# de tonalidade, efeito de flash, etc. 
# Esta classe é usada internamente pelas classes Game_Map e Game_Troop.
#==============================================================================

class Game_Screen
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :brightness               # Brilho
  attr_reader   :tone                     # Tom da tela
  attr_reader   :flash_color              # Cor do flash
  attr_reader   :pictures                 # Imagens
  attr_reader   :shake                    # Termor
  attr_reader   :weather_type             # Tipo de clima
  attr_reader   :weather_power            # Força do clima (Float)
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #--------------------------------------------------------------------------
  def initialize
    @pictures = Game_Pictures.new
    clear
  end
  #--------------------------------------------------------------------------
  # * Limpeza da
  #--------------------------------------------------------------------------
  def clear
    clear_fade
    clear_tone
    clear_flash
    clear_shake
    clear_weather
    clear_pictures
  end
  #--------------------------------------------------------------------------
  # * Limpeza da brilho
  #--------------------------------------------------------------------------
  def clear_fade
    @brightness = 255
    @fadeout_duration = 0
    @fadein_duration = 0
  end
  #--------------------------------------------------------------------------
  # * Limpeza da tonalidade
  #--------------------------------------------------------------------------
  def clear_tone
    @tone = Tone.new
    @tone_target = Tone.new
    @tone_duration = 0
  end
  #--------------------------------------------------------------------------
  # * Limpeza da flash
  #--------------------------------------------------------------------------
  def clear_flash
    @flash_color = Color.new
    @flash_duration = 0
  end
  #--------------------------------------------------------------------------
  # * Limpeza da tremor
  #--------------------------------------------------------------------------
  def clear_shake
    @shake_power = 0
    @shake_speed = 0
    @shake_duration = 0
    @shake_direction = 1
    @shake = 0
  end
  #--------------------------------------------------------------------------
  # * Limpeza da clima
  #--------------------------------------------------------------------------
  def clear_weather
    @weather_type = :none
    @weather_power = 0
    @weather_power_target = 0
    @weather_duration = 0
  end
  #--------------------------------------------------------------------------
  # * Limpeza da imagens
  #--------------------------------------------------------------------------
  def clear_pictures
    @pictures.each {|picture| picture.erase }
  end
  #--------------------------------------------------------------------------
  # * Inicialização do fade-out
  #     duration : tempo de duração
  #--------------------------------------------------------------------------
  def start_fadeout(duration)
    @fadeout_duration = duration
    @fadein_duration = 0
  end
  #--------------------------------------------------------------------------
  # * Inicialização do fade-in
  #     duration : tempo de duração
  #--------------------------------------------------------------------------
  def start_fadein(duration)
    @fadein_duration = duration
    @fadeout_duration = 0
  end
  #--------------------------------------------------------------------------
  # * Inicialização da mudanças de tonalidade
  #     tone     : tonalidade da tela
  #     duration : tempo de duração
  #--------------------------------------------------------------------------
  def start_tone_change(tone, duration)
    @tone_target = tone.clone
    @tone_duration = duration
    @tone = @tone_target.clone if @tone_duration == 0
  end
  #--------------------------------------------------------------------------
  # * Inicialização do flash
  #     color    : cor
  #     duration : tempo de duração
  #--------------------------------------------------------------------------
  def start_flash(color, duration)
    @flash_color = color.clone
    @flash_duration = duration
  end
  #--------------------------------------------------------------------------
  # * Inicialização do tremor
  #     power    : potência do tremor
  #     speed    : velocidade
  #     duration : tempo de duração
  #--------------------------------------------------------------------------
  def start_shake(power, speed, duration)
    @shake_power = power
    @shake_speed = speed
    @shake_duration = duration
  end
  #--------------------------------------------------------------------------
  # Inicialização do efeito climático
  #     type     : tipo de efeito (:none, :rain, :storm, :snow)
  #     power    : grau do efeito
  #     duration : tempo de duração
  #--------------------------------------------------------------------------
  def change_weather(type, power, duration)
    @weather_type = type if type != :none || duration == 0
    @weather_power_target = type == :none ? 0.0 : power.to_f
    @weather_duration = duration
    @weather_power = @weather_power_target if duration == 0
  end
  #--------------------------------------------------------------------------
  # * Atualização da Tela
  #--------------------------------------------------------------------------
  def update
    update_fadeout
    update_fadein
    update_tone
    update_flash
    update_shake
    update_weather
    update_pictures
  end
  #--------------------------------------------------------------------------
  # * Atualização do fade-out
  #--------------------------------------------------------------------------
  def update_fadeout
    if @fadeout_duration > 0
      d = @fadeout_duration
      @brightness = (@brightness * (d - 1)) / d
      @fadeout_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização do fade-in
  #--------------------------------------------------------------------------
  def update_fadein
    if @fadein_duration > 0
      d = @fadein_duration
      @brightness = (@brightness * (d - 1) + 255) / d
      @fadein_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização da tonalidade
  #--------------------------------------------------------------------------
  def update_tone
    if @tone_duration > 0
      d = @tone_duration
      @tone.red = (@tone.red * (d - 1) + @tone_target.red) / d
      @tone.green = (@tone.green * (d - 1) + @tone_target.green) / d
      @tone.blue = (@tone.blue * (d - 1) + @tone_target.blue) / d
      @tone.gray = (@tone.gray * (d - 1) + @tone_target.gray) / d
      @tone_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização do flash
  #--------------------------------------------------------------------------
  def update_flash
    if @flash_duration > 0
      d = @flash_duration
      @flash_color.alpha = @flash_color.alpha * (d - 1) / d
      @flash_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização do tremor
  #--------------------------------------------------------------------------
  def update_shake
    if @shake_duration > 0 || @shake != 0
      delta = (@shake_power * @shake_speed * @shake_direction) / 10.0
      if @shake_duration <= 1 && @shake * (@shake + delta) < 0
        @shake = 0
      else
        @shake += delta
      end
      @shake_direction = -1 if @shake > @shake_power * 2
      @shake_direction = 1 if @shake < - @shake_power * 2
      @shake_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização do clima
  #--------------------------------------------------------------------------
  def update_weather
    if @weather_duration > 0
      d = @weather_duration
      @weather_power = (@weather_power * (d - 1) + @weather_power_target) / d
      @weather_duration -= 1
      if @weather_duration == 0 && @weather_power_target == 0
        @weather_type = :none
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização das imagens
  #--------------------------------------------------------------------------
  def update_pictures
    @pictures.each {|picture| picture.update }
  end
  #--------------------------------------------------------------------------
  # * Inicialização do flash (dano do terreno)
  #--------------------------------------------------------------------------
  def start_flash_for_damage
    start_flash(Color.new(255,0,0,128), 8)
  end
end
