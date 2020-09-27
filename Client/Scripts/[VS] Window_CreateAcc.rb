#==============================================================================
# ** Window_CreateAcc
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de criação de conta.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_CreateAcc < Window_Base
  
  def initialize
    # Quando a resolução é alterada, a coordenada x é
    #reajustada no adjust_windows_position da Scene_Map
    super(adjust_x, 212, 212, 251)
    self.visible = false
    self.title = Vocab::NewAcc
    @user_box = Text_Box.new(self, 19, 38, 174, Configs::MAX_CHARACTERS) { enable_newacc_button }
    @pass_box = Text_Box.new(self, 19, 84, 174, Configs::MAX_CHARACTERS, true) { enable_newacc_button }
    @repeat_box = Text_Box.new(self, 19, 130, 174, Configs::MAX_CHARACTERS, true) { enable_newacc_button }
    @email_box = Text_Box.new(self, 19, 176, 174, 40) { enable_newacc_button }
    @newacc_button = Button.new(self, 22, 211, Vocab::Register) { create_account }
    @cancel_button = Button.new(self, 111, 211, Vocab::Cancel, 79) { login }
    @newacc_button.enable = false
  end

  def adjust_x
    Graphics.width / 2 - 105
  end
  
  def invalid_user?
    @user_box.text =~ /[\/\\"*<>|]/
  end
  
  def invalid_email?
    @email_box.text !~ /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  end
  
  def refresh
    # Evita que o texto seja redesenhado sobre ele mesmo
    #toda vez que a janela ficar visível
    contents.clear
    draw_text(7, 6, 75, line_height, "#{Vocab::Username}:")
    draw_text(7, 52, 75, line_height, "#{Vocab::Password}:")
    draw_text(7, 98, 135, line_height, Vocab::RepeatPass)
    draw_text(7, 144, 65, line_height, Vocab::Email)
  end
  
  def create_account
    return unless @newacc_button.enable
    if @pass_box.text != @repeat_box.text
      $windows[:alert].show(Vocab::PasswordsNotMatch)
    elsif invalid_user?
      $windows[:alert].show(Vocab::InvalidUser)
    elsif invalid_email?
      $windows[:alert].show(Vocab::InvalidEmail)
    elsif !$network.server_online?
      $windows[:alert].show(Vocab::ServerOffline)
    else
      $network.send_create_account(@user_box.text, @pass_box.text, @email_box.text)
    end
  end
  
  def login
    $windows[:login].show
    hide
  end
  
  def enable_newacc_button
    @newacc_button.enable = (@user_box.text.strip.size >= Configs::MIN_CHARACTERS &&
      @pass_box.text.strip.size >= Configs::MIN_CHARACTERS &&
      @repeat_box.text.strip.size >= Configs::MIN_CHARACTERS &&
      @email_box.text.strip.size >= Configs::MIN_CHARACTERS)
  end
  
  def update
    super
    close_windows
    ok if Input.trigger?(:C)
    update_box
  end
  
  def close_windows
    return unless Input.trigger?(:B)
    if $windows[:alert].visible || $windows[:config].visible
      $windows[:alert].hide
      $windows[:config].hide
    else
      login
    end
  end
  
  def ok
    $windows[:alert].visible ? $windows[:alert].hide : create_account
  end
  
  def update_box
    return unless Input.trigger?(:TAB)
    if @user_box.active
      @user_box.active = false
      @pass_box.active = true
      @repeat_box.active = false
      @email_box.active = false
    elsif @pass_box.active
      @user_box.active = false
      @pass_box.active = false
      @repeat_box.active = true
      @email_box.active = false
    elsif @repeat_box.active
      @user_box.active = false
      @pass_box.active = false
      @repeat_box.active = false
      @email_box.active = true
    elsif @email_box.active
      @user_box.active = true
      @pass_box.active = false
      @repeat_box.active = false
      @email_box.active = false
    end
  end
  
end
