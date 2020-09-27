#==============================================================================
# ** RPG::SE
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::SE < RPG::AudioFile
  def play
    unless @name.empty?
      Audio.se_play('Audio/SE/' + @name, @volume, @pitch)
    end
  end

  def self.stop
    Audio.se_stop
  end
end