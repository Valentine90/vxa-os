#==============================================================================
# ** Audio
#------------------------------------------------------------------------------
#  Este script lida com o volume das músicas e sons.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Audio
  
  class << self
    alias vxaos_bgm_play bgm_play
    alias vxaos_bgm_stop bgm_stop
    alias vxaos_bgs_play bgs_play
    alias vxaos_bgs_stop bgs_stop
    alias vxaos_me_play me_play
    alias vxaos_se_play se_play
  end
  
  def self.update_bgm_volume
    return unless @bgm_filename
    bgm_play(@bgm_filename, @bgm_volume, @bgm_pitch)
  end
    
  def self.update_bgs_volume
    return unless @bgs_filename
    bgs_play(@bgs_filename, @bgs_volume, @bgs_pitch)
  end
    
  def self.bgm_play(filename, volume = 100, pitch = 100, pos = 0)
    @bgm_filename = filename
    @bgm_volume = volume
    @bgm_pitch = pitch
    volume = $settings_file.music_volume * volume / 100
    vxaos_bgm_play(filename, volume, pitch, pos)
  end
    
  def self.bgm_stop
    @bgm_filename = nil
    vxaos_bgm_stop
  end
    
  def self.bgs_play(filename, volume = 100, pitch = 100, pos = 0)
    @bgs_filename = filename
    @bgs_volume = volume
    @bgs_pitch = pitch
    volume = $settings_file.sound_volume * volume / 100
    vxaos_bgs_play(filename, volume, pitch, pos)
  end
    
  def self.bgs_stop
    @bgs_filename = nil
    vxaos_bgs_stop
  end
    
  def self.me_play(filename, volume = 100, pitch = 100)
    volume = $settings_file.music_volume * volume / 100
    vxaos_me_play(filename, volume, pitch)
  end
    
  def self.se_play(filename, volume = 100, pitch = 100)
    volume = $settings_file.sound_volume * volume / 100
    vxaos_se_play(filename, volume, pitch)
  end
  
end
