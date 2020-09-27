#==============================================================================
# ** RPG::BGS
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::BGS < RPG::AudioFile
  @@last = RPG::BGS.new

  def play(pos = 0)
    if @name.empty?
      Audio.bgs_stop
      @@last = RPG::BGS.new
    else
      Audio.bgs_play('Audio/BGS/' + @name, @volume, @pitch, pos)
      @@last = self.clone
    end
  end

  def replay
    play(@pos)
  end

  def self.stop
    Audio.bgs_stop
    @@last = RPG::BGS.new
  end

  def self.fade(time)
    Audio.bgs_fade(time)
    @@last = RPG::BGS.new
  end

  def self.last
    @@last.pos = Audio.bgs_pos
    @@last
  end

  attr_accessor :pos
end