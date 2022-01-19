#==============================================================================
# ** Sprite_Character
#------------------------------------------------------------------------------
#  Esta classe lida com a exibição do gráfico, paperdolls,
# nome, dano e HP do personagem.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Sprite_Character < Sprite_Base
  
  Damage = Struct.new(:sprite, :duration, :dir)
  
  def init_sprites
    @message_duration = 0
    @damage_sprites = []
    @paperdoll_sprites = []
    @paperdoll_oy = []
    @last_equips = []
    @name_sprite = nil
    @guild_sprite = nil
    @quest_sprite = nil
    @tip_sprite = nil
    @hp_sprite = nil
    @message_sprite = nil
    @last_guild = nil
    @last_hp = nil
    @last_mhp = nil
    @last_sex = nil
  end
  
  def dispose_sprites
    dispose_paperdolls
    dispose_name
    dispose_guild_name
    dispose_quest_icon
    dispose_tip
    dispose_hp_bar
    dispose_damage
    dispose_message
  end
  
  def dispose_paperdolls
    Configs::MAX_EQUIPS.times { |slot_id| dispose_paperdoll(slot_id) }
  end
  
  def dispose_paperdoll(slot_id)
    return unless @paperdoll_sprites[slot_id]
    @paperdoll_sprites[slot_id].bitmap.dispose
    @paperdoll_sprites[slot_id].dispose
    @paperdoll_sprites[slot_id] = nil
    @last_equips[slot_id] = nil
  end
  
  def dispose_name
    return unless @name_sprite
    @name_sprite.bitmap.dispose
    @name_sprite.dispose
    @name_sprite = nil
  end
  
  def dispose_guild_name
    return unless @guild_sprite
    @guild_sprite.bitmap.dispose
    @guild_sprite.dispose
    @guild_sprite = nil
  end
  
  def dispose_quest_icon
    return unless @quest_sprite
    @quest_sprite.bitmap.dispose
    @quest_sprite.dispose
    @quest_sprite = nil
  end
  
  def dispose_tip
    return unless @tip_sprite
    @tip_sprite.bitmap.dispose
    @tip_sprite.dispose
    @tip_sprite = nil
  end
  
  def dispose_hp_bar
    return unless @hp_sprite
    @hp_sprite.bitmap.dispose
    @hp_sprite.dispose
    @hp_sprite = nil
  end
  
  def dispose_damage
    @damage_sprites.each do |damage|
      damage.sprite.bitmap.dispose
      damage.sprite.dispose
    end
    @damage_sprites.clear
  end
  
  def dispose_message
    return unless @message_sprite
    @message_sprite.bitmap.dispose
    @message_sprite.dispose
    @message_sprite = nil
  end
  
  def visible=(visible)
    super
    end_sprites if visible == false
    @quest_sprite.visible = visible if @quest_sprite
    if @name_sprite && @name_sprite.visible != visible
      @name_sprite.visible = visible
      @guild_sprite.visible = visible if @guild_sprite
      @hp_sprite.visible = visible if @hp_sprite
      Configs::MAX_EQUIPS.times { |slot_id| @paperdoll_sprites[slot_id].visible = visible if @paperdoll_sprites[slot_id] } unless @paperdoll_sprites.empty?
    end
  end
  
  def end_sprites
    end_animation
    end_balloon
    dispose_tip
    dispose_damage
    dispose_message
    @balloon_duration = 0
    @message_duration = 0
  end
  
  def update_position
    move_animation(@character.screen_x - x, @character.screen_y - y)
    self.x = @character.screen_x
    self.y = @character.screen_y
    self.z = @character.screen_z
  end
  
  def move_animation(dx, dy)
    return unless @animation && @animation.position != 3
    @ani_ox += dx
    @ani_oy += dy
    @ani_sprites.each do |sprite|
      sprite.x += dx
      sprite.y += dy
    end
  end
  
  def update_sprites
    return if @character.is_a?(Game_Vehicle)
    update_paperdolls unless @character.is_a?(Game_Event)
    if @character.actor? && @character.actor.result.success?
      create_action_results
      @character.actor.result.clear_hit_flags
      @character.actor.result.clear_damage_values
    end
    # Se é um inimigo, jogador ou evento não apagado (erased)
    if @character.actor? || @character.event.name.start_with?('$') && !@character.character_name.empty?
      refresh_name if name_changed?
      @name_sprite.x = x
      # Atualiza de acordo com a altura do character
      #que pode ter sido alterada
      @name_sprite.y = y - height
    else
      dispose_name
    end
    if !@character.is_a?(Game_Event) && !@character.actor.guild_name.empty?
      refresh_guild_name if guild_changed?
      @guild_sprite.x = x
      @guild_sprite.y = y - height
    else
      dispose_guild_name
    end
    if @character.is_a?(Game_Event) && @character.quest_not_started?
      create_quest_icon unless @quest_sprite
      @quest_sprite.x = x
      @quest_sprite.y = y - height
    else
      dispose_quest_icon
    end
    # Se a lista de comandos do evento não está vazia (empty)
    if @character.is_a?(Game_Event) && @character.event.name.start_with?('$') && !@character.character_name.empty? && $game_player.in_front?(@character) && !@character.empty?
      create_tip unless @tip_sprite
      @tip_sprite.x = x
      @tip_sprite.y = y - height
    else
      dispose_tip
    end
    if @character.boss?
      refresh_boss_hp_bar if hp_changed?
      # Possibilita que a barra possa ser arrastada
      @hp_sprite.update
      @hp_sprite.change_opacity
    elsif @character.actor? && @character.actor.hp < @character.actor.mhp
      refresh_hp_bar if hp_changed?
      @hp_sprite.x = x
      @hp_sprite.y = y
    else
      dispose_hp_bar
    end
    unless @character.message.empty?
      create_message(@character.message)
      @character.message.clear
    end
    update_damage
    if @message_duration > 0
      @message_sprite.x = x
      @message_sprite.y = y
      @message_duration -= 1
    else
      dispose_message
    end
  end
  
  def name_changed?
    return true unless @name_sprite
    return true if @character.actor? && @last_name != @character.actor.name
    return true unless @character.actor? || @last_name == @character.event.name
    return false
  end
  
  def guild_changed?
    return true unless @guild_sprite
    return true unless @last_guild == @character.actor.guild_name
    return false
  end
  
  def hp_changed?
    return true unless @hp_sprite
    return true unless @last_hp == @character.actor.hp
    return true unless @last_mhp == @character.actor.mhp
    return false
  end
  
  def update_damage
    # downto evita erros ao remover elementos enquanto a
    #matriz está sendo iterada
    (@damage_sprites.size - 1).downto(0) do |i|
      @damage_sprites[i].duration -= 1
      if @damage_sprites[i].dir == Enums::Dir::UP
        @damage_sprites[i].sprite.x = x
        @damage_sprites[i].sprite.y = y - (height - @damage_sprites[i].duration)
      else
        @damage_sprites[i].sprite.x = @damage_sprites[i].dir == Enums::Dir::RIGHT ? x + (20 - @damage_sprites[i].duration) : x - (20 - @damage_sprites[i].duration)
        if @damage_sprites[i].duration > 10
          @damage_sprites[i].sprite.y = y - (height - @damage_sprites[i].duration * 2)
        elsif @damage_sprites[i].duration <= 10 && @damage_sprites[i].duration > 0
          @damage_sprites[i].sprite.y = y + (height - @damage_sprites[i].duration * 4)
        end
      end
      if @damage_sprites[i].duration == 0
        @damage_sprites[i].sprite.bitmap.dispose
        @damage_sprites[i].sprite.dispose
        @damage_sprites.delete_at(i)
      end
    end
  end
  
  def create_action_results
    if @character.actor.result.level_up?
      create_text('LevelUp')
    elsif @character.actor.result.gain_exp?
      create_exp
    elsif @character.actor.result.critical?
      create_text('Critical')
    elsif @character.actor.result.hp_damage == 0 && @character.actor.result.mp_damage == 0
      create_text('Miss')
    elsif @character.actor.result.hp_damage == 0 && @character.actor.result.mp_damage > 0
      create_damage('DamageMP', @character.actor.result.mp_damage, Enums::Dir::UP)
    elsif @character.actor.result.hp_damage > 0
      create_damage('RecoveryHP', @character.actor.result.hp_damage, Enums::Dir::UP)
    else
      if rand(6) > 3
        dir = Enums::Dir::LEFT
        ox = 20
      else
        dir = Enums::Dir::RIGHT
        ox = -20
      end
      if @character.actor.result.hp_damage != 0
        create_damage('DamageHP', @character.actor.result.hp_damage.abs, dir, ox)
      else
        create_damage('DamageMP', @character.actor.result.mp_damage.abs, dir, ox)
      end
    end
  end
  
  def create_damage(damage_sprite, damage, dir, ox = 0)
    sprite = Sprite.new
    damage = damage.to_s.chars.to_a
    bitmap = Cache.system(damage_sprite)
    width = bitmap.width / 10
    sprite.bitmap = Bitmap.new(damage.size * width, bitmap.height)
    damage.each_with_index do |c, i|
      rect = Rect.new(c.to_i * width, 0, width, bitmap.height)
      sprite.bitmap.blt(i * width, 0, bitmap, rect)
    end
    sprite.ox = sprite.bitmap.width / 2 + ox
    sprite.oy = 35
    # Deixa o dano em cima de todas as camadas do
    #tileset e do nome do jogador
    sprite.z = z + 150
    @damage_sprites << Damage.new(sprite, 25, dir)
  end
  
  def create_exp
    sprite = Sprite.new
    damage = @character.actor.result.exp.to_s.chars.to_a
    bitmap = Cache.system('Exp')
    width = bitmap.width / 13
    sprite.bitmap = Bitmap.new((damage.size + 3) * width, bitmap.height)
    damage.each_with_index do |c, i|
      rect = Rect.new(c.to_i * width, 0, width, bitmap.height)
      sprite.bitmap.blt(i * width, 0, bitmap, rect)
    end
    rect = Rect.new(width * 10, 0, width * 3, bitmap.height)
    sprite.bitmap.blt(sprite.bitmap.width - width * 3, 0, bitmap, rect)
    sprite.ox = sprite.bitmap.width / 2 - 3
    sprite.oy = 35
    sprite.z = z + 150
    @damage_sprites << Damage.new(sprite, 25, 8)
  end
  
  def create_text(text_sprite)
    sprite = Sprite.new
    sprite.bitmap = Cache.system(text_sprite)
    sprite.ox = sprite.bitmap.width / 2
    sprite.oy = 35
    sprite.z = z + 150
    @damage_sprites << Damage.new(sprite, 25, 8)
  end
  
  def order_equips
    case @character.direction
    when 2
      return Configs::PAPERDOLL_DOWN_DIR
    when 4
      return Configs::PAPERDOLL_LEFT_DIR
    when 6
      return Configs::PAPERDOLL_RIGHT_DIR
    when 8
      return Configs::PAPERDOLL_UP_DIR
    end
  end
  
  def update_paperdolls
    order_equips.each_with_index do |slot_id, index|
      if @character.actor.equips[slot_id] && @character.actor.equips[slot_id].paperdoll_name
        refresh_paperdoll(slot_id) unless @last_equips[slot_id] == @character.actor.equips[slot_id] && @last_sex == @character.actor.sex
        pattern = @character.pattern < 3 ? @character.pattern : 1
        paperdoll_index = @character.attack_animation? ? @character.character_index : @character.actor.equips[slot_id].paperdoll_index
        sx = (paperdoll_index % 4 * 3 + pattern) * @cw
        sy = (paperdoll_index / 4 * 4 + (@character.direction - 2) / 2) * @ch
        @paperdoll_sprites[slot_id].src_rect.set(sx, sy, @cw, @ch)
        @paperdoll_sprites[slot_id].x = x
        # Como a ordem z (z-order) de todos os paperdolls
        #é a mesma, a prioridade deles é definida pelo
        #paperdoll que está mais abaixo em razão da soma:
        #base y (y + altura) + índice da ordem do paperdoll.
        #Já o oy original somado pelo índice coloca o
        #paperdoll na posição que ele deveria ter ficado
        #na tela se não fosse a alteração da coordenada y
        @paperdoll_sprites[slot_id].y = y + index
        @paperdoll_sprites[slot_id].oy = @paperdoll_oy[slot_id] + index
      else
        dispose_paperdoll(slot_id)
      end
    end
    @last_sex = @character.actor.sex
  end
  
  def refresh_paperdoll(slot_id)
    @last_equips[slot_id] = @character.actor.equips[slot_id]
    bitmap = Cache.paperdoll(@character.actor.equips[slot_id].paperdoll_name, @character.actor.sex)
    @paperdoll_sprites[slot_id] ? @paperdoll_sprites[slot_id].bitmap.clear : create_paperdoll(slot_id, bitmap)
    @paperdoll_sprites[slot_id].bitmap.blt(0, 0, bitmap, bitmap.rect)
    sign = @character.actor.equips[slot_id].paperdoll_name[/^[\!\$]./]
    if sign && sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    @paperdoll_sprites[slot_id].ox = cw / 2
    @paperdoll_sprites[slot_id].oy = ch
    @paperdoll_oy[slot_id] = ch
  end
  
  def create_paperdoll(slot_id, bitmap)
    @paperdoll_sprites[slot_id] = Sprite.new(viewport)
    @paperdoll_sprites[slot_id].bitmap = Bitmap.new(bitmap.width, bitmap.height)
    # A ordem z de todos os paperdolls é a mesma, e
    #não z + index ou z + (0.1 * index), pra evitar que
    #os paperdolls fiquem por cima dos jogadores e eventos,
    #quando estes estiverem na frente do @character
    @paperdoll_sprites[slot_id].z = z
  end
  
  def refresh_name
    @last_name = @character.actor? ? @character.actor.name : @character.event.name
    @name_sprite ? @name_sprite.bitmap.clear : create_name
    @name_sprite.bitmap.font.color.set(@name_sprite.text_color(name_color))
    @name_sprite.bitmap.draw_text(@name_sprite.bitmap.rect, @last_name.delete('$'), 1)
  end
  
  def create_name
    @name_sprite = Sprite2.new(viewport)
    # Largura necessária para nomes grandes
    @name_sprite.bitmap = Bitmap.new(@name_sprite.text_width(@last_name.delete('$')) + 18, 18)
    @name_sprite.ox = @name_sprite.bitmap.width / 2
    @name_sprite.oy = 19
    @name_sprite.z = z + 100
  end
  
  def name_color
    return Configs::ADMIN_COLOR if @character.admin?
    return Configs::MONITOR_COLOR if @character.monitor?
    return Configs::BOSS_COLOR if @character.boss?
    return Configs::ENEMY_COLOR if @character.is_a?(Game_Event) && @character.actor
    return Configs::DEFAULT_COLOR
  end
  
  def refresh_guild_name
    @last_guild = @character.actor.guild_name
    @guild_sprite ? @guild_sprite.bitmap.clear : create_guild_name
    @guild_sprite.bitmap.draw_text(@guild_sprite.bitmap.rect, "<#{@last_guild}>", 1)
  end
  
  def create_guild_name
    @guild_sprite = Sprite2.new(viewport)
    @guild_sprite.bitmap = Bitmap.new(160, 18)
    @guild_sprite.bitmap.font.color.set(@guild_sprite.text_color(Configs::GUILD_COLOR))
    @guild_sprite.ox = 80
    @guild_sprite.oy = 37
    @guild_sprite.z = z + 100
  end
  
  def create_quest_icon
    @quest_sprite = Sprite.new(viewport)
    @quest_sprite.bitmap = Bitmap.new(24, 24)
    bitmap = Cache.system('Iconset')
    rect = Rect.new(Configs::QUEST_NOT_STARTED_ICON % 16 * 24, Configs::QUEST_NOT_STARTED_ICON / 16 * 24, 24, 24)
    @quest_sprite.bitmap.blt(0, 0, bitmap, rect)
    @quest_sprite.ox = 12
    @quest_sprite.oy = 40
    @quest_sprite.z = z + 100
  end
  
  def create_tip
    @tip_sprite = Sprite2.new(viewport)
    # O sub, em vez de delete, evita que as consoantes
    #trl da palavra Ctrl sejam removidas
    tip = "#{Vocab::Press} #{Configs::ATTACK_KEY.to_s.sub('LETTER_', '').capitalize}"
    @tip_sprite.bitmap = Bitmap.new(@tip_sprite.text_width(tip) + 18, Font.default_size + 2)
    @tip_sprite.bitmap.fill_rect(@tip_sprite.bitmap.rect, Color.new(0, 0, 0, 100))
    @tip_sprite.bitmap.draw_text(@tip_sprite.bitmap.rect, tip, 1)
    @tip_sprite.ox = @tip_sprite.bitmap.width / 2
    @tip_sprite.oy = 38
    @tip_sprite.z = z + 100
  end
  
  def refresh_hp_bar
    @last_hp = @character.actor.hp
    @last_mhp = @character.actor.mhp
    @hp_sprite ? @hp_sprite.bitmap.clear : create_hp_bar
    bitmap = Cache.system('HPBar')
    y = @character.actor.mhp / 3 > @character.actor.hp ? 12 : @character.actor.mhp / 1.5 > @character.actor.hp ? 8 : 4
    @hp_sprite.bitmap.blt(0, 0, bitmap, @hp_sprite.bitmap.rect)
    @hp_sprite.bitmap.blt(0, 0, bitmap, Rect.new(0, y, @hp_sprite.bitmap.width * @character.actor.hp / @character.actor.mhp, @hp_sprite.bitmap.height))
  end
  
  def refresh_boss_hp_bar
    @last_hp = @character.actor.hp
    @last_mhp = @character.actor.mhp
    @hp_sprite ? @hp_sprite.bitmap.clear : create_boss_hp_bar
    bitmap = Cache.system('BossHPBar')
    y = @character.actor.mhp / 3 > @character.actor.hp ? 72 : @character.actor.mhp / 1.5 > @character.actor.hp ? 48 : 24
    @hp_sprite.bitmap.blt(0, 18, bitmap, @hp_sprite.bitmap.rect)
    @hp_sprite.bitmap.blt(0, 18, bitmap, Rect.new(0, y, @hp_sprite.bitmap.width * @character.actor.hp / @character.actor.mhp, @hp_sprite.bitmap.height))
    @hp_sprite.bitmap.font.size = 16
    @hp_sprite.bitmap.font.bold = false
    @hp_sprite.bitmap.font.color.set(@hp_sprite.text_color(Configs::BOSS_COLOR))
    @hp_sprite.bitmap.draw_text(0, 0, 200, 18, @character.actor.name)
    @hp_sprite.bitmap.font.size = 18
    @hp_sprite.bitmap.font.bold = true
    @hp_sprite.bitmap.font.color.set(Color::White)
    @hp_sprite.bitmap.draw_text(4, 20, 25, 20, Vocab::hp_a)
    @hp_sprite.bitmap.draw_text(0, 20, 349, 20, "#{@character.actor.hp}/#{@character.actor.mhp}", 2)
  end
  
  def create_hp_bar
    @hp_sprite = Sprite.new(viewport)
    @hp_sprite.bitmap = Bitmap.new(32, 4)
    @hp_sprite.ox = 16
    @hp_sprite.oy = -4
    @hp_sprite.z = z + 100
  end
  
  def create_boss_hp_bar
    @hp_sprite = Sprite2.new
    @hp_sprite.bitmap = Bitmap.new(351, 42)
    @hp_sprite.x = (Graphics.width - @hp_sprite.bitmap.width) / 2
    @hp_sprite.y = 118
    @hp_sprite.z = 50
    @hp_sprite.dragable = true
  end
  
  def create_message(message)
    dispose_message
    b = Bitmap.new(1, 1)
    # Define a largura a partir da matriz com maior texto
    message_width = message.collect { |s| b.text_size(s).width }.max
    b.dispose
    @message_sprite = Sprite.new(viewport)
    @message_sprite.bitmap = Bitmap.new(message_width + 18, message.size * 18)
    @message_sprite.bitmap.fill_rect(@message_sprite.bitmap.rect, Color.new(0, 0, 0, 160))
    @message_sprite.bitmap.font.bold = true
    message.each_with_index do |text, i|
      @message_sprite.bitmap.draw_text(0, 18 * i, @message_sprite.bitmap.width, 18, text, 1)
      #x = (@message_sprite.bitmap.width - @message_sprite.bitmap.text_size(text).width) / 2
      #$windows[:chat].draw_emojis(@message_sprite.bitmap, x, i, text)
    end
    @message_sprite.ox = @message_sprite.width / 2
    @message_sprite.oy = message.size * 18 + height + 10
    @message_sprite.z = z + 100
    @message_duration = 150
  end
  
end
