#==============================================================================
# ** RGSS
#------------------------------------------------------------------------------
#  Este script lida com as classes necessárias para carregar os arquivos rvdata2.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

RPG = Module

#==============================================================================
# ** RPG::BaseItem
#==============================================================================
class RPG::BaseItem

  attr_accessor :id, :name, :description, :icon_index, :features, :note

  def initialize
    @id = 0
    @name = ''
    @icon_index = 0
    @features = []
    @description = ''
    @note = ''
  end

end

#==============================================================================
# ** RPG::BaseItem::Feature
#==============================================================================
class RPG::BaseItem::Feature

  attr_accessor :code, :data_id, :value

  def initialize(code = 0, data_id = 0, value = 0)
    @code = code
    @data_id = data_id
    @value = value
  end

end

#==============================================================================
# ** RPG::Actor
#==============================================================================
class RPG::Actor < RPG::BaseItem

  attr_accessor :nickname, :character_name, :character_index, :face_name, :face_index,
    :initial_level, :max_level, :class_id, :equips

  def initialize
    super
    @nickname = ''
    @character_name = ''
    @character_index = 0
    @face_name = ''
    @face_index = 0
    @initial_level = 1
    @max_level = 99
    @class_id = 1
    @equips = [0] * 5
  end

end

#==============================================================================
# ** RPG::Class
#==============================================================================
class RPG::Class < RPG::BaseItem

  attr_accessor :learnings, :params, :exp_params

  def initialize
    super
    @learnings = []
    @exp_params = [30, 20, 30, 30]
    @features << RPG::BaseItem::Feature.new(23, 0, 1)
    @features << RPG::BaseItem::Feature.new(22, 0, 0.95)
    @features << RPG::BaseItem::Feature.new(22, 1, 0.95)
    @features << RPG::BaseItem::Feature.new(22, 2, 0.04)
    @features << RPG::BaseItem::Feature.new(41, 1)
    @features << RPG::BaseItem::Feature.new(51, 1)
    @features << RPG::BaseItem::Feature.new(52, 1)
    @params = Table.new(8, 100)
  end
  
end

#==============================================================================
# ** RPG::Class::Learning
#==============================================================================
class RPG::Class::Learning

  attr_accessor :level, :skill_id, :note

  def initialize
    @level = 1
    @skill_id = 2
    @note = ''
  end

end

#==============================================================================
# ** RPG::UsableItem
#==============================================================================
class RPG::UsableItem < RPG::BaseItem

  attr_accessor :occasion, :animation_id, :speed, :sucess_rate, :hit_type, :repeats,
    :tp_gain, :effects, :damage, :scope

  def initialize
    super
    @occasion = 0
    @animation_id = 0
    @speed = 0
    @sucess_rate = 100
    @hit_type = 0
    @repeats = 1
    @tp_gain = 0
    @effects = []
    @damage = RPG::UsableItem::Damage.new
  end

end

#==============================================================================
# ** RPG::UsableItem::Damage
#==============================================================================
class RPG::UsableItem::Damage

  attr_accessor :type, :element_id, :variance, :formula, :critical

  def initialize
    @type = 0
    @element_id = 0
    @variance = 20
    @formula = '0'
    @critical = false
  end

end

#==============================================================================
# ** RPG::UsableItem::Effect
#==============================================================================
class RPG::UsableItem::Effect

  attr_accessor :code, :data_id, :value1, :value2

  def initialize(code = 0, data_id = 0, value1 = 0, value2 = 0)
    @code = code
    @data_id = data_id
    @value1 = value1
    @value2 = value2
  end

end

#==============================================================================
# ** RPG::Skill
#==============================================================================
class RPG::Skill < RPG::UsableItem

  attr_accessor :mp_cost, :tp_cost, :stype_id, :required_wtype_id1, :required_wtype_id2,
    :message1, :message2

  def initialize
    super
    @scope = 1
    @mp_cost = 0
    @tp_cost = 0
    @stype_id = 1
    @required_wtype_id1 = 0
    @required_wtype_id2 = 0
    @message1 = ''
    @message2 = ''
  end

end

#==============================================================================
# ** RPG::Item
#==============================================================================
class RPG::Item < RPG::UsableItem

  attr_accessor :price, :itype_id, :consumable

  def initialize
    super
    @scope = 7
    @price = 0
    @itype_id = 1
    @consumable = true
  end

end

#==============================================================================
# ** RPG::EquipItem
#==============================================================================
class RPG::EquipItem < RPG::BaseItem

  attr_accessor :price, :params, :etype_id

  def initialize
    super
    @price = 0
    @params = [0] * 8
  end

end

#==============================================================================
# ** RPG::Weapon
#==============================================================================
class RPG::Weapon < RPG::EquipItem

  attr_accessor :animation_id, :wtype_id

  def initialize
    super
    @etype_id = 0
    @animation_id = 0
    @wtype_id = 0
    @features << RPG::BaseItem::Feature.new(31, 1)
    @features << RPG::BaseItem::Feature.new(22)
  end

end

#==============================================================================
# ** RPG::Armor
#==============================================================================
class RPG::Armor < RPG::EquipItem

  attr_accessor :atype_id

  def initialize
    super
    @etype_id = 1
    @atype_id = 0
    @features << RPG::BaseItem::Feature.new(22, 1)
  end

end

#==============================================================================
# ** RPG::Enemy
#==============================================================================
class RPG::Enemy < RPG::BaseItem

  attr_accessor :battler_name, :battler_hue, :exp, :gold, :actions, :params, :drop_items

  def initialize
    super
    @battler_name = ''
    @battler_hue = 0
    @exp = 0
    @gold = 0
    @params = [100, 0, 10, 10, 10, 10, 10, 10]
    @actions = [RPG::Enemy::Action.new]
    # Preenche a matriz com objetos mutáveis separados
    @drop_items = Array.new(3) { RPG::Enemy::DropItem.new }
    @features << RPG::BaseItem::Feature.new(22, 0, 0.95)
    @features << RPG::BaseItem::Feature.new(22, 1, 0.05)
    @features << RPG::BaseItem::Feature.new(31, 1)
  end

end

#==============================================================================
# ** RPG::Enemy::Action
#==============================================================================
class RPG::Enemy::Action

  attr_accessor :condition_type, :rating, :skill_id, :condition_param1, :condition_param2

  def initialize
    @condition_type = 0
    @rating = 5
    @skill_id = 1
    @condition_param1 = 0
    @condition_param2 = 0
  end

end

#==============================================================================
# ** RPG::Enemy::DropItem
#==============================================================================
class RPG::Enemy::DropItem

  attr_accessor :denominator, :kind, :data_id

  def initialize
    @denominator = 1
    @kind = 0
    @data_id = 1
  end

end

#==============================================================================
# ** RPG::Troop
#==============================================================================
class RPG::Troop

  attr_accessor :id, :name, :members, :pages

  def initialize
    @id = 0
    @name = ''
    @members = []
    @pages = [RPG::Troop::Page.new]
  end

end

#==============================================================================
# ** RPG::Troop::Page
#==============================================================================
class RPG::Troop::Page

  attr_accessor :list, :span, :condition

  def initialize
    @span = 0
    @list = [RPG::EventCommand.new]
    @condition = RPG::Troop::Page::Condition.new
  end

end

#==============================================================================
# ** RPG::Troop::Page::Condition
#==============================================================================
class RPG::Troop::Page::Condition

  attr_accessor :actor_hp, :enemy_hp, :turn_a, :turn_b, :turn_valid, :turn_ending,
    :actor_id, :actor_valid, :enemy_index, :enemy_valid, :switch_id, :switch_valid

  def initialize
    @actor_hp = 50
    @enemy_hp = 50
    @turn_a = 0
    @turn_b = 0
    @turn_valid = false
    @turn_ending = false
    @actor_id = 1
    @actor_valid = false
    @enemy_index = 0
    @enemy_valid = false
    @switch_id = 1
    @switch_valid = false
  end

end

#==============================================================================
# ** RPG::State
#==============================================================================
class RPG::State < RPG::BaseItem

  attr_accessor :priority, :restriction, :auto_removal_timing, :min_turns, :max_turns,
    :chance_by_damage, :steps_to_remove, :remove_by_walking, :remove_at_battle_end,
    :remove_by_damage, :remove_by_restriction, :message1, :message2, :message3, :message4

  def initialize
    super
    @priority = 50
    @restriction = 0
    @auto_removal_timing = 0
    @min_turns = 1
    @max_turns = 1
    @chance_by_damage = 100
    @steps_to_remove = 100
    @remove_by_walking = false
    @remove_at_battle_end = false
    @remove_by_damage = false
    @remove_by_restriction = false
    @message1 = ''
    @message2 = ''
    @message3 = ''
    @message4 = ''
  end

end

#==============================================================================
# ** RPG::Animation
#==============================================================================
class RPG::Animation

  attr_accessor :id, :name, :animation1_name, :animation1_hue, :animation2_name,
    :animation2_hue, :position, :frame_max, :timings, :frames

  def initialize
    @id = 0
    @name = ''
    @animation1_name = ''
    @animation1_hue = 0
    @animation2_name = ''
    @animation2_hue = 0
    @position = 1
    @frame_max = 1
    @timings = []
    @frames = [RPG::Animation::Frame.new]
  end

end

#==============================================================================
# ** RPG::Animation::Frame
#==============================================================================
class RPG::Animation::Frame

  attr_accessor :cell_max, :cell_data

  def initialize
    @cell_max = 0
    @cell_data = Table.new(0, 0)
  end

end

#==============================================================================
# ** RPG::Animation::Timing
#==============================================================================
class RPG::Animation::Timing

  attr_accessor :flash_duration, :se, :flash_color, :frame, :flash_scope

  def initialize
    @flash_duration = 5
    @se = RPG::SE.new('', 80)
    @flash_color = Color.new(255, 255, 255)
    @frame = 0
    @flash_scope = 0
  end

end

#==============================================================================
# ** RPG::Tileset
#==============================================================================
class RPG::Tileset

  attr_accessor :id, :name, :mode, :tileset_names, :flags, :note

  def initialize
    @id = 0
    @name = ''
    @mode = 1
    @tileset_names = [''] * 9
    @flags = Table.new(8192)
    @note = ''
  end

end

#==============================================================================
# ** RPG::CommonEvent
#==============================================================================
class RPG::CommonEvent

  attr_accessor :id, :name, :trigger, :switch_id, :list

  def initialize
    @id = 0
    @name = ''
    @trigger = 0
    @switch_id = 1
    @list = [RPG::EventCommand.new]
  end

end

#==============================================================================
# ** RPG::System
#==============================================================================
class RPG::System

  attr_accessor :start_map_id, :start_x, :start_y, :edit_map_id, :party_members, :battler_name,
    :battler_hue, :version_id, :test_troop_id, :game_title, :currency_unit, :battleback1_name,
    :battleback2_name, :title1_name, :title2_name, :switches, :variables, :elements, :skill_types,
    :weapon_types, :armor_types, :title_bgm, :battle_end_me, :battle_bgm, :gameover_me, :sounds,
    :test_battlers, :ship, :airship, :boat, :terms, :window_tone, :japanese, :opt_draw_title,
    :opt_use_midi, :opt_transparent, :opt_followers, :opt_slip_death, :opt_extra_exp,
    :opt_display_tp, :opt_floor_death
  
  def initialize
    @start_map_id = 1
    @start_x = 0
    @start_y = 0
    @edit_map_id = 1
    @party_members = [1]
    @battler_name = ''
    @battler_hue = 0
    @version_id = 0
    @test_troop_id = 1
    @game_title = ''
    @currency_unit = ''
    @battleback1_name = ''
    @battleback2_name = ''
    @title1_name = ''
    @title2_name = ''
    @switches = [nil, '']
    @variables = [nil, '']
    @elements = ['', '']
    @skill_types = ['', '']
    @weapon_types = ['', '']
    @armor_types = ['', '']
    @title_bgm = RPG::BGM.new
    @battle_bgm = RPG::BGM.new
    @battle_end_me = RPG::ME.new
    @gameover_me = RPG::ME.new
    @sounds = Array.new(24) { RPG::SE.new }
    @test_battlers = RPG::System::TestBattler.new
    @ship = RPG::System::Vehicle.new
    @airship = RPG::System::Vehicle.new
    @boat = RPG::System::Vehicle.new
    @terms = RPG::System::Terms.new
    @window_tone = Tone.new
    @japanese = true
    @opt_draw_title = true
    @opt_use_midi = false
    @opt_transparent = false
    @opt_followers = true
    @opt_slip_death = false
    @opt_extra_exp = false
    @opt_display_tp = true
    @opt_floor_death = false
  end

end

#==============================================================================
# ** RPG::System::Vehicle
#==============================================================================
class RPG::System::Vehicle

  attr_accessor :start_map_id, :start_x, :start_y, :character_name, :character_index, :bgm

  def initialize
    @character_name = ''
    @character_index = 0
    @start_map_id = 0
    @start_x = 0
    @start_y = 0
    @bgm = RPG::BGM.new
  end

end

#==============================================================================
# ** RPG::System::TestBattler
#==============================================================================
class RPG::System::TestBattler

  attr_accessor :actor_id, :level, :equips

  def initialize
    @actor_id = 1
    @level = 1
    @equips = [0] * 5
  end

end

#==============================================================================
# ** RPG::System::Terms
#==============================================================================
class RPG::System::Terms

  attr_accessor :params, :etypes, :commands, :basic

  def initialize
    @params = [''] * 8
    @etypes = [''] * 5
    @commands = [''] * 23
    @basic = [''] * 8
  end

end

#==============================================================================
# ** RPG::MapInfo
#==============================================================================
class RPG::MapInfo

  attr_accessor :name, :scroll_x, :scroll_y, :order, :parent_id, :expanded

  def initialize
    @name = ''
    @scroll_x = 0
    @scroll_y = 0
    @order = 0
    @parent_id = 0
    @expanded = false
  end

end

#==============================================================================
# ** RPG::Map
#==============================================================================
class RPG::Map

  attr_accessor :display_name, :width, :height, :events, :tileset_id, :scroll_type,
    :encounter_step, :encounter_list, :parallax_name, :parallax_sx, :parallax_sy,
    :parallax_loop_x, :parallax_loop_y, :parallax_show, :autoplay_bgs, :autoplay_bgm,
    :bgm, :bgs, :disable_dashing, :specify_battleback, :battleback1_name, :battleback2_name,
    :data, :note

  def initialize(width, height)
    @display_name = ''
    @width = width
    @height = height
    @events = {}
    @tileset_id = 1
    @scroll_type = 0
    @encounter_step = 30
    @encounter_list = []
    @parallax_name = ''
    @parallax_sx = 0
    @parallax_sy = 0
    @parallax_loop_x = false
    @parallax_loop_y = false
    @parallax_show = false
    @autoplay_bgs = false
    @autoplay_bgm = false
    @bgm = RPG::BGM.new
    @bgs = RPG::BGS.new
    @disable_dashing = false
    @specify_battleback = false
    @battleback1_name = ''
    @battleback2_name = ''
    @data = Table.new(width, height, 4)
    @note = ''
  end

end

#==============================================================================
# ** RPG::EventCommand
#==============================================================================
class RPG::EventCommand

  attr_accessor :indent, :code, :parameters

  def initialize(indent = 0, code = 0, parameters = [])
    @indent = indent
    @code = code
    @parameters = parameters
  end

end

#==============================================================================
# ** RPG::AudioFile
#==============================================================================
class RPG::AudioFile

  attr_accessor :name, :volume, :pitch

  def initialize(name = '', volume = 100, pitch = 100)
    @name = name
    @volume = volume
    @pitch = pitch
  end

end

#==============================================================================
# ** RPG::BGM
#==============================================================================
class RPG::BGM < RPG::AudioFile
end

#==============================================================================
# ** RPG::BGS
#==============================================================================
class RPG::BGS < RPG::AudioFile
end

#==============================================================================
# ** RPG::ME
#==============================================================================
class RPG::ME < RPG::AudioFile
end

#==============================================================================
# ** RPG::SE
#==============================================================================
class RPG::SE < RPG::AudioFile
end

#==============================================================================
# ** Color
#==============================================================================
class Color

  attr_accessor :red, :green, :blue, :alpha

  def initialize(red = 0, green = 0, blue = 0, alpha = 255)
    set(red, green, blue, alpha)
  end

  def set(red, green = 0, blue = 0, alpha = 255)
    if red.is_a?(Color)
      color = red
      @red = color.red
      @green = color.green
      @blue = color.blue
      @alpha = color.alpha
    else
      @red = red
      @green = green
      @blue = blue
      @alpha = alpha
    end
    self
  end

  def self._load(string)
    new(*string.unpack('D*'))
  end

end

#==============================================================================
# ** Tone
#==============================================================================
class Tone

  attr_accessor :red, :green, :blue, :gray

  def initialize(red = 0, green = 0, blue = 0, gray = 0)
    set(red, green, blue, gray)
  end

  def set(red, green = 0, blue = 0, gray = 0)
    if red.is_a?(Tone)
      tone = red
      @red = tone.red
      @green = tone.green
      @blue = tone.blue
      @gray = tone.gray
    else
      @red = red
      @green = green
      @blue = blue
      @gray = gray
    end
    self
  end

  def self._load(data)
    new(*data.unpack('E4'))
  end

end

#==============================================================================
# ** Table
#==============================================================================
class Table

  attr_reader   :xsize, :ysize, :zsize

  def initialize(xsize, ysize = 1, zsize = 1)
    @xsize = xsize
    @ysize = ysize
    @zsize = zsize

  end

  def self._load(s)

  end

end
