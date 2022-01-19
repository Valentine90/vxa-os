#==============================================================================
# ** DataManager
#------------------------------------------------------------------------------
#  Este módulo lida com o jogo e objetos do banco de dados
# utilizados no jogo. Quase todas as variáveis globais são
# inicializadas aqui.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module DataManager
  
  def self.init_basic
    $cursor = Sprite_Cursor.new
    $settings_file = Settings_File.new('System/Settings.ini')
    Graphics.resize_screen(Configs::RESOLUTIONS[$settings_file.resolution_id][:width], Configs::RESOLUTIONS[$settings_file.resolution_id][:height])
    # Se a tela cheia está ativada e o executável utiliza DirectX 9
    Graphics.toggle_fullscreen if $settings_file.fullscreen == 0 && Graphics.respond_to?(:toggle_fullscreen)
    Graphics.vsync = ($settings_file.vsync == 0) if Graphics.respond_to?(:vsync)
    Graphics.background_exec = true if Graphics.respond_to?(:background_exec)
    $dragging_window = nil
    $typing = nil
    $alert_msg = nil
    $error_msg = nil
    $admin_msg = nil
  end
  
  def self.back_login
    $network.disconnect
    SceneManager.goto(Scene_Login) unless SceneManager.scene_is?(Scene_Login)
  end
  
  def self.load_class_graphic
    (1...$data_classes.size).each do |class_id|
      $data_classes[class_id].graphics = Note.read_graphics($data_classes[class_id].note)
    end
  end
  
  def self.load_equip_extra
    (1...$data_weapons.size).each do |weapon_id|
      $data_weapons[weapon_id].level = Note.read_number('Level', $data_weapons[weapon_id].note)
      $data_weapons[weapon_id].paperdoll_name, $data_weapons[weapon_id].paperdoll_index = Note.read_paperdoll($data_weapons[weapon_id].note)
      $data_weapons[weapon_id].vip = Note.read_boolean('VIP', $data_weapons[weapon_id].note)
      $data_weapons[weapon_id].soulbound = Note.read_boolean('Soulbound', $data_weapons[weapon_id].note)
    end
    (1...$data_armors.size).each do |armor_id|
      $data_armors[armor_id].level = Note.read_number('Level', $data_armors[armor_id].note)
      $data_armors[armor_id].paperdoll_name, $data_armors[armor_id].paperdoll_index = Note.read_paperdoll($data_armors[armor_id].note)
      $data_armors[armor_id].vip = Note.read_boolean('VIP', $data_armors[armor_id].note)
      $data_armors[armor_id].soulbound = Note.read_boolean('Soulbound', $data_armors[armor_id].note)
      etype_id = Note.read_number('Type', $data_armors[armor_id].note)
      $data_armors[armor_id].etype_id = etype_id if etype_id > 0
      $data_armors[armor_id].sex = $data_armors[armor_id].note.include?('Sex=') ? Note.read_number('Sex', $data_armors[armor_id].note) : 2
    end
  end
  
  def self.load_item_range
    (1...$data_items.size).each do |item_id|
      $data_items[item_id].range = Note.read_number('Range', $data_items[item_id].note)
      $data_items[item_id].aoe = Note.read_number('AOE', $data_items[item_id].note)
      $data_items[item_id].level = Note.read_number('Level', $data_items[item_id].note)
      $data_items[item_id].soulbound = Note.read_boolean('Soulbound', $data_items[item_id].note)
    end
    (1...$data_skills.size).each do |skill_id|
      $data_skills[skill_id].range = Note.read_number('Range', $data_skills[skill_id].note)
      $data_skills[skill_id].aoe = Note.read_number('AOE', $data_skills[skill_id].note)
      $data_skills[skill_id].level = Note.read_number('Level', $data_skills[skill_id].note)
    end
  end
  
  def self.load_enemy_boss
    (1...$data_enemies.size).each do |enemy_id|
      $data_enemies[enemy_id].boss = Note.read_boolean('Boss', $data_enemies[enemy_id].note)
    end
  end
  
end

#==============================================================================
# ** Cache
#==============================================================================
module Cache
  
  def self.minimap(filename)
    load_bitmap('Graphics/Minimaps/', filename)
  end
  
  def self.paperdoll(filename, sex)
    load_bitmap("Graphics/Paperdolls/#{sex === Enums::Sex::MALE ? 'Male' : 'Female'}/", filename)
  end
  
  def self.projectile(filename)
    load_bitmap('Graphics/Projectiles/', filename)
  end
  
  def self.window(filename)
    load_bitmap('Graphics/Windows/', filename)
  end
  
  def self.button(filename)
    load_bitmap('Graphics/Buttons/', filename)
  end
  
end

#==============================================================================
# ** RPG::Class
#==============================================================================
class RPG::Class < RPG::BaseItem
  
  attr_accessor :graphics
  
end

#==============================================================================
# ** RPG::EquipItem
#==============================================================================
class RPG::EquipItem < RPG::BaseItem
  
  attr_accessor :level, :paperdoll_name, :paperdoll_index, :vip, :soulbound
  
  def vip?
    @vip
  end
  
  def soulbound?
    @soulbound
  end
  
end

#==============================================================================
# ** RPG::EquipItem
#==============================================================================
class RPG::Armor < RPG::EquipItem
  
  attr_accessor :sex
  
end

#==============================================================================
# ** RPG::UsableItem
#==============================================================================
class RPG::UsableItem < RPG::BaseItem
  
  attr_accessor :range, :aoe, :level, :soulbound
  
  def soulbound?
    @soulbound
  end
  
end

#==============================================================================
# ** RPG::Enemy
#==============================================================================
class RPG::Enemy < RPG::BaseItem
  
  attr_accessor :boss
  
end
