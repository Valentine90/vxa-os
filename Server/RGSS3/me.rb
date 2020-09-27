#==============================================================================
# ** RPG::ME
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::ME < RPG::AudioFile
  def play
    if @name.empty?
      Audio.me_stop
    else
      Audio.me_play('Audio/ME/' + @name, @volume, @pitch)
    end
  end

  def self.stop
    Audio.me_stop
  end

  def self.fade(time)
    Audio.me_fade(time)
  end
end