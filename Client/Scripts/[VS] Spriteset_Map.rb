#==============================================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
#  Esta classe lida com os objetos graficos da tela de
# mapa e tilesets.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Spriteset_Map
  
  attr_reader   :viewport1, :player_sprites, :drop_sprites, :projectile_sprites
  
  def create_objects
    @message_duration = 0
    @error_duration = 0
    @player_sprites = {}
    @projectile_sprites = []
    @last_target = nil
    @target_sprite = nil
    @message_sprite = nil
    @error_sprite = nil
    $game_map.players.each do |player_id, player|
      @player_sprites[player_id] = Sprite_Character.new(@viewport1, player)
    end
    @drop_sprites = $game_map.drops.collect { |drop| Sprite_Drop.new(@viewport1, drop) }
  end
  
  def create_viewports
    @viewport1 = Viewport.new
    @viewport2 = Viewport.new
    @viewport3 = Viewport.new
    @viewport2.z = 50
    # Deixa o fade out por cima das janelas e da 
    #Sprite_Desc, mas embaixo do mouse
    @viewport3.z = 160
  end
  
  def in_object_area?(object)
    return false if object.is_a?(Game_Player)
    return false if object.is_a?(Game_Vehicle)
    return false if object.character_name.empty?
    return false if $dragging_window
    return false if $cursor.object
    return false unless Mouse.in_tile?(object)
    return false if $game_player.over_window?
    return true
  end
  
  def in_drop_area?(drop)
    return false unless $cursor.sprite_index == Enums::Cursor::NONE
    return false if $dragging_window
    return false if $cursor.object
    return false unless Mouse.in_tile?(drop)
    return false if $game_player.over_window?
    return true
  end
  
  def dispose_sprites
    dispose_players
    dispose_drops
    dispose_projectiles
    dispose_target
    dispose_admin_message
    dispose_error_sprite
  end
  
  def dispose_players
    @player_sprites.each_value(&:dispose)
    @player_sprites.clear
  end
  
  def dispose_drops
    @drop_sprites.each(&:dispose)
    @drop_sprites.clear
  end
  
  def dispose_projectiles
    @projectile_sprites.each(&:dispose)
    @projectile_sprites.clear
  end

  def dispose_target
    return unless @target_sprite
    @target_sprite.bitmap.dispose
    @target_sprite.dispose
    @target_sprite = nil
    @last_target = nil
  end
  
  def dispose_admin_message
    return unless @message_sprite
    @message_sprite.bitmap.dispose
    @message_sprite.dispose
    @message_sprite = nil
    @message_duration = 0
  end
  
  def dispose_error_sprite
    return unless @error_sprite
    @error_sprite.bitmap.dispose
    @error_sprite.dispose
    @error_sprite = nil
    @error_duration = 0
  end
  
  def update_characters
    $cursor.sprite_index = Enums::Cursor::NONE
    refresh_characters unless @map_id == $game_map.map_id
    @character_sprites.each do |sprite|
      if $game_map.in_screen?(sprite.character)
        change_cursor(sprite.character) if in_object_area?(sprite.character)
        sprite.visible = true
        sprite.update
      else
        sprite.visible = false
      end
    end
  end
  
  def change_cursor(character)
    $cursor.sprite_index = character.actor? ? Enums::Cursor::ENEMY : Enums::Cursor::EVENT
  end
  
  def update_objects
    update_players
    update_drops
    update_projectiles
    update_target
    update_admin_message
    update_error_message
  end
  
  def update_players
    @player_sprites.each_value do |player|
      if $game_map.in_screen?(player.character)
        $cursor.sprite_index = Enums::Cursor::PLAYER if in_object_area?(player.character)
        player.visible = true
        player.update
      else
        player.visible = false
      end
    end
  end
  
  def update_drops
    @drop_sprites.each do |drop|
      if $game_map.in_screen?(drop.character)
        $cursor.sprite_index = Enums::Cursor::DROP if in_drop_area?(drop.character)
        drop.visible = true
        drop.update
      else
        drop.visible = false
      end
    end
  end
  
  def update_projectiles
    # downto evita erros ao remover elementos enquanto a
    #matriz está sendo iterada
    (@projectile_sprites.size - 1).downto(0) do |i|
      if @projectile_sprites[i].destroy?
        $game_map.projectiles.delete_at(i)
        @projectile_sprites[i].bitmap.dispose
        @projectile_sprites[i].dispose
        @projectile_sprites.delete_at(i)
      # Solução de erro temporária
      elsif !@projectile_sprites[i].bitmap.disposed?
        @projectile_sprites[i].update
      end
    end
  end
  
  def update_target
    if $game_player.has_target? && $game_player.target.actor?
      create_target unless @target_sprite && @last_target == $game_player.target
      @target_sprite.x = $game_player.target.screen_x
      @target_sprite.y = $game_player.target.screen_y
    else
      dispose_target
    end
  end
  
  def create_target
    dispose_target
    @last_target = $game_player.target
    @target_sprite = Sprite.new(@viewport1)
    @target_sprite.bitmap = Cache.system('Target')
    @target_sprite.ox = @target_sprite.bitmap.width / 2
    bitmap = Cache.character($game_player.target.character_name)
    sign = $game_player.target.character_name[/^[\!\$]./]
    ch = sign && sign.include?('$') ? bitmap.height / 4 : bitmap.height / 8
    @target_sprite.oy = ch + 40
    @target_sprite.z = $game_player.target.screen_z + 100
  end
  
  def update_admin_message
    if $admin_msg
      create_admin_message
      $admin_msg = nil
    end
    if @message_duration > 0
      @message_duration -= 1
    else
      dispose_admin_message
    end
  end
  
  def update_error_message
    if $error_msg
      refresh_error_message
      $error_msg = nil
    end
    if @error_duration > 0
      @error_duration -= 1
    else
      dispose_error_sprite
    end
  end
  
  def create_admin_message
    dispose_admin_message
    @message_sprite = Sprite.new
    @message_sprite.bitmap = Bitmap.new(550, 50)
    @message_sprite.bitmap.font.color.set(Color::Yellow)
    @message_sprite.bitmap.font.size = 22
    @message_sprite.bitmap.font.bold = true
    #
    $windows[:panel].word_wrap($admin_msg, @message_sprite.bitmap.width - 122).each_with_index do |text, i|
      @message_sprite.bitmap.draw_text(0, 24 * i, @message_sprite.bitmap.width + 32, 24, text, 1)
    end
    @message_sprite.x = (Graphics.width - @message_sprite.bitmap.width) / 2
    @message_sprite.y = 110
    # Deixa a mensagem em cima de todas as janelas,
    #inclusive da Window_Message
    @message_sprite.z = 205
    @message_duration = 400
  end
  
  def refresh_error_message
    @error_sprite ? @error_sprite.bitmap.clear : create_error_message
    @error_sprite.bitmap.draw_text(@error_sprite.bitmap.rect, $error_msg, 1)
    @error_duration = 200
  end
  
  def create_error_message
    @error_sprite = Sprite.new
    @error_sprite.bitmap = Bitmap.new(640, 20)
    @error_sprite.bitmap.font.color.set(Color::Red)
    @error_sprite.bitmap.font.size = 18
    @error_sprite.bitmap.font.bold = true
    @error_sprite.x = (Graphics.width - @error_sprite.bitmap.width) / 2
    @error_sprite.y = 160
    @error_sprite.z = 205
  end
  
end
