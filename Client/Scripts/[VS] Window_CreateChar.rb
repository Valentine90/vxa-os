#==============================================================================
# ** Window_CreateChar
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de criação de personagem.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_CreateChar < Window_Base
  
  def initialize
    # Quando a resolução é alterada, as coordenadas x e y
    #são reajustadas no adjust_windows_position da Scene_Map
    super(adjust_x, adjust_y, 401, 288)
    self.visible = false
    self.closable = true
    self.title = Vocab::NewChar
    create_buttons
  end
  
  def adjust_x
    Graphics.width / 2 - 200
  end
  
  def adjust_y
    Graphics.height / 2 - 154
  end
  
  def max_classes
    $network.vip? ? Configs::MAX_VIP_CLASSES : Configs::MAX_DEFAULT_CLASSES
  end
  
  def class_names
    (1..max_classes).collect { |class_id| $data_classes[class_id].name }
  end
  
  def create_buttons
    @name_box = Text_Box.new(self, 79, 20, 115, Configs::MAX_CHARACTERS) { enable_create_button }
    @class_box = Combo_Box.new(self, 265, 20, 120, class_names) { change_class } if max_classes > 1
    @next_sex = Image_Button.new(self, 176, 48, 'Right') { change_sex(Enums::Sex::FEMALE) }
    @prev_sex = Image_Button.new(self, 79, 48, 'Left') { change_sex(Enums::Sex::MALE) }
    @next_char = Image_Button.new(self, 176, 75, 'Right') { next_character }
    @prev_char = Image_Button.new(self, 79, 75, 'Left') { prev_character }
    @rem_hp = Button.new(self, 19, 147, '-', 26) { remove_param(0) }
    @rem_mp = Button.new(self, 19, 171, '-', 26) { remove_param(1) }
    @rem_atk = Button.new(self, 19, 195, '-', 26) { remove_param(2) }
    @remo_agi = Button.new(self, 19, 219, '-', 26) { remove_param(3) }
    @add_hp = Button.new(self, 166, 147, '+', 26) { add_param(0) }
    @add_mp = Button.new(self, 166, 171, '+', 26) { add_param(1) }
    @add_atk = Button.new(self, 166, 195, '+', 26) { add_param(2) }
    @add_agi = Button.new(self, 166, 219, '+', 26) { add_param(3) }
    @rem_def = Button.new(self, 211, 147, '-', 26) { remove_param(4) }
    @remo_mat = Button.new(self, 211, 171, '-', 26) { remove_param(5) }
    @rem_mdf = Button.new(self, 211, 195, '-', 26) { remove_param(6) }
    @rem_luk = Button.new(self, 211, 219, '-', 26) { remove_param(7) }
    @add_def = Button.new(self, 356, 147, '+', 26) { add_param(4) }
    @add_mat = Button.new(self, 356, 171, '+', 26) { add_param(5) }
    @add_mdf = Button.new(self, 356, 195, '+', 26) { add_param(6) }
    @add_luk = Button.new(self, 356, 219, '+', 26) { add_param(7) }
    @create_button = Button.new(self, 168, 254, Vocab::Create, 64) { create_actor }
    @points_bar = Progress_Bar.new(self, 18, 121, 365, Configs::START_POINTS) if Configs::START_POINTS > 0
  end
  
  def show(actor_id)
    @actor_id = actor_id
    @sex = Enums::Sex::MALE
    @points = Configs::START_POINTS
    @class_id = 1
    @sprite_index = 0
    refresh_character
    @params = Array.new(8, 0)
    @name_box.clear
    @create_button.enable = false
    @class_box.index = 0 if max_classes > 1
    super()
    # Ativa a caixa de texto após a janela ficar visível
    @name_box.active = true
    enable_buttons
  end
  
  def hide
    super
    SceneManager.scene.change_background('Title2')
    $windows[:alert].hide
    $windows[:use_char].show
  end
  
  def invalid_name?
    @name_box.text =~ /[^A-Za-z0-9 ]/
  end
  
  def illegal_name?
    Configs::FORBIDDEN_NAMES.any? { |word| @name_box.text =~ /#{word}/i }
  end
  
  def refresh
    contents.clear
    draw_shadow(108, 73)
    draw_character(@character_name, @character_index, 124, 103)
    change_color(normal_color)
    draw_text(4, 8, 45, line_height, "#{Vocab::Name}:")
    draw_text(196, 8, 60, line_height, Vocab::Class)
    draw_text(260, 8, 150, line_height, $data_classes[@class_id].name) if max_classes == 1
    draw_text(4, 35, 45, line_height, Vocab::Sex)
    draw_text(97, 35, 55, line_height, @sex == Enums::Sex::MALE ? Vocab::Male : Vocab::Female, 1)
    draw_text(4, 62, 70, line_height, Vocab::Graphic)
    draw_text(119, 137, 25, line_height, @params[0] * 10 + $data_classes[@class_id].params[0, 1], 2)
    draw_text(119, 161, 25, line_height, @params[1] * 10 + $data_classes[@class_id].params[1, 1], 2)
    draw_justified_texts(196, 31, 225, line_height, $data_actors[@class_id].description.delete("\n"))
    (2...8).each do |param_id|
      draw_text(param_id / 4 * 189 + 119, param_id % 4 * 24 + 137, 25, line_height, $data_classes[@class_id].params[param_id, 1] + @params[param_id], 2)
    end
    change_color(system_color)
    (0...8).each do |param_id|
      # Largura suficiente para os termos não abreviados
      draw_text(param_id / 4 * 193 + 47, param_id % 4 * 24 + 137, 100, line_height, "#{Vocab::param(param_id)}:")
    end
    if @points_bar
      @points_bar.index = @points
      @points_bar.text = "#{@points}/#{Configs::START_POINTS}"
    end
    @next_char.visible = @prev_char.visible = $data_classes[@class_id].graphics[@sex].size > 1
  end
  
  def refresh_character
    @character_name = $data_classes[@class_id].graphics[@sex][@sprite_index][0]
    @character_index = $data_classes[@class_id].graphics[@sex][@sprite_index][1]
  end
  
  def create_actor
    return unless @create_button.enable
    if illegal_name? && $network.standard_group?
      $windows[:alert].show(Vocab::InvalidName)
    elsif invalid_name?
      $windows[:alert].show(Vocab::ForbiddenCharacter)
    else
      $network.send_create_actor(@actor_id, @name_box.text, @sprite_index, @class_id, @sex, @params)
    end
  end
  
  def change_sex(sex)
    @sex = sex
    @sprite_index = 0
    refresh_character
    refresh
  end
  
  def change_class
    @class_id = @class_box.index + 1
    @sprite_index = 0
    refresh_character
    refresh
  end
  
  def next_character
    @sprite_index = @sprite_index < $data_classes[@class_id].graphics[@sex].size - 1 ? @sprite_index + 1 : 0
    refresh_character
    refresh
  end
  
  def prev_character
    @sprite_index = @sprite_index > 0 ? @sprite_index - 1 : @sprite_index = $data_classes[@class_id].graphics[@sex].size - 1
    refresh_character
    refresh
  end
  
  def add_param(param_id)
    @points -= 1
    @params[param_id] += 1
    refresh
    enable_buttons
  end
  
  def remove_param(param_id)
    @points += 1
    @params[param_id] -= 1
    refresh
    enable_buttons
  end
  
  def enable_buttons
    @rem_hp.enable = @params[0] > 0
    @rem_mp.enable = @params[1] > 0
    @rem_atk.enable = @params[2] > 0
    @remo_agi.enable = @params[3] > 0
    @rem_def.enable = @params[4] > 0
    @remo_mat.enable = @params[5] > 0
    @rem_mdf.enable = @params[6] > 0
    @rem_luk.enable = @params[7] > 0
    enable = @points > 0
    @add_hp.enable = enable
    @add_mp.enable = enable
    @add_atk.enable = enable
    @add_agi.enable = enable
    @add_def.enable = enable
    @add_mat.enable = enable
    @add_mdf.enable = enable
    @add_luk.enable = enable
  end
  
  def enable_create_button
    @create_button.enable = @name_box.text.strip.size >= Configs::MIN_CHARACTERS
  end
  
  def update
    super
    close_windows
    ok if Input.trigger?(:C)
  end
  
  def close_windows
    return unless Input.trigger?(:B)
    if $windows[:alert].visible || $windows[:config].visible
      $windows[:alert].hide
      $windows[:config].hide
    else
      hide
    end
  end
  
  def ok
    $windows[:alert].visible ? $windows[:alert].hide : create_actor
  end
  
end
