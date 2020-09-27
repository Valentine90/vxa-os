#==============================================================================
# ** RPG::System
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::System
  def initialize
    @game_title = ''
    @version_id = 0
    @japanese = true
    @party_members = [1]
    @currency_unit = ''
    @elements = [nil, '']
    @skill_types = [nil, '']
    @weapon_types = [nil, '']
    @armor_types = [nil, '']
    @switches = [nil, '']
    @variables = [nil, '']
    @boat = RPG::System::Vehicle.new
    @ship = RPG::System::Vehicle.new
    @airship = RPG::System::Vehicle.new
    @title1_name = ''
    @title2_name = ''
    @opt_draw_title = true
    @opt_use_midi = false
    @opt_transparent = false
    @opt_followers = true
    @opt_slip_death = false
    @opt_floor_death = false
    @opt_display_tp = true
    @opt_extra_exp = false
    @window_tone = Tone.new(0, 0, 0)
    @title_bgm = RPG::BGM.new
    @battle_bgm = RPG::BGM.new
    @battle_end_me = RPG::ME.new
    @gameover_me = RPG::ME.new
    @sounds = Array.new(24) { RPG::SE.new }
    @test_battlers = []
    @test_troop_id = 1
    @start_map_id = 1
    @start_x = 0
    @start_y = 0
    @terms = RPG::System::Terms.new
    @battleback1_name = ''
    @battleback2_name = ''
    @battler_name = ''
    @battler_hue = 0
    @edit_map_id = 1
  end

  attr_accessor :game_title
  attr_accessor :version_id
  attr_accessor :japanese
  attr_accessor :party_members
  attr_accessor :currency_unit
  attr_accessor :skill_types
  attr_accessor :weapon_types
  attr_accessor :armor_types
  attr_accessor :elements
  attr_accessor :switches
  attr_accessor :variables
  attr_accessor :boat
  attr_accessor :ship
  attr_accessor :airship
  attr_accessor :title1_name
  attr_accessor :title2_name
  attr_accessor :opt_draw_title
  attr_accessor :opt_use_midi
  attr_accessor :opt_transparent
  attr_accessor :opt_followers
  attr_accessor :opt_slip_death
  attr_accessor :opt_floor_death
  attr_accessor :opt_display_tp
  attr_accessor :opt_extra_exp
  attr_accessor :window_tone
  attr_accessor :title_bgm
  attr_accessor :battle_bgm
  attr_accessor :battle_end_me
  attr_accessor :gameover_me
  attr_accessor :sounds
  attr_accessor :test_battlers
  attr_accessor :test_troop_id
  attr_accessor :start_map_id
  attr_accessor :start_x
  attr_accessor :start_y
  attr_accessor :terms
  attr_accessor :battleback1_name
  attr_accessor :battleback2_name
  attr_accessor :battler_name
  attr_accessor :battler_hue
  attr_accessor :edit_map_id
end