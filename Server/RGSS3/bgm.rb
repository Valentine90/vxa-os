#==============================================================================
# ** RPG::BGM
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::BGM < RPG::AudioFile
  @@last = RPG::BGM.new

  def play(pos = 0)
    if @name.empty?
      Audio.bgm_stop
      @@last = RPG::BGM.new
    else
      Audio.bgm_play('Audio/BGM/' + @name, @volume, @pitch, pos)
      @@last = self.clone
    end
  end

  def replay
    play(@pos)
  end

  def self.stop
    Audio.bgm_stop
    @@last = RPG::BGM.new
  end

  def self.fade(time)
    Audio.bgm_fade(time)
    @@last = RPG::BGM.new
  end

  def self.last
    @@last.pos = Audio.bgm_pos
    @@last
  end

  attr_accessor :pos
end