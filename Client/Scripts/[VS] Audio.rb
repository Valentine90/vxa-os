#==============================================================================
# ** Audio
#------------------------------------------------------------------------------
#  Este script lida com o volume das músicas e sons.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Audio
  
  @music_volume = 100
  @sound_volume = 100
  @resolution_id = 0
  @fullscreen = 1
  @vsync = 0
  
  def self.load
    return unless FileTest.exist?('System/Audio.rvdata2')
    file = File.open('System/Audio.rvdata2', 'rb')
    @music_volume = Marshal.load(file)
    @sound_volume = Marshal.load(file)
    @resolution_id = Marshal.load(file)
    @fullscreen = Marshal.load(file)
    @vsync = Marshal.load(file)
    file.close
  end
  
  def self.save
    file = File.open('System/Audio.rvdata2', 'wb')
    file.write(Marshal.dump(@music_volume))
    file.write(Marshal.dump(@sound_volume))
    file.write(Marshal.dump(@resolution_id))
    file.write(Marshal.dump(@fullscreen))
    file.write(Marshal.dump(@vsync))
    file.close
  end
  
  def self.music_volume=(volume)
    @music_volume = volume
    update_bgm_volume
  end
  
  def self.sound_volume=(volume)
    @sound_volume = volume
    update_bgs_volume
  end
  
  def self.resolution_id=(resolution_id)
    @resolution_id = resolution_id
  end
  
  def self.fullscreen=(fullscreen)
    @fullscreen = fullscreen
    Graphics.toggle_fullscreen if fullscreen == 0 && !Graphics.is_fullscreen? || fullscreen == 1 && Graphics.is_fullscreen?
  end
  
  def self.vsync=(vsync)
    @vsync = vsync
    Graphics.vsync = (@vsync == 0)
  end
  
  class << self
    
    alias vxaos_bgm_play bgm_play
    alias vxaos_bgm_stop bgm_stop
    alias vxaos_bgs_play bgs_play
    alias vxaos_bgs_stop bgs_stop
    alias vxaos_me_play me_play
    alias vxaos_se_play se_play
    
    attr_reader   :music_volume, :sound_volume, :resolution_id, :fullscreen, :vsync
    
    def update_bgm_volume
      return unless @bgm_filename
      bgm_play(@bgm_filename, @bgm_volume, @bgm_pitch)
    end
    
    def update_bgs_volume
      return unless @bgs_filename
      bgs_play(@bgs_filename, @bgs_volume, @bgs_pitch)
    end
    
    def bgm_play(filename, volume = 100, pitch = 100, pos = 0)
      @bgm_filename = filename
      @bgm_volume = volume
      @bgm_pitch = pitch
      volume = @music_volume * volume / 100
      vxaos_bgm_play(filename, volume, pitch, pos)
    end
    
    def bgm_stop
      @bgm_filename = nil
      vxaos_bgm_stop
    end
    
    def bgs_play(filename, volume = 100, pitch = 100, pos = 0)
      @bgs_filename = filename
      @bgs_volume = volume
      @bgs_pitch = pitch
      volume = @sound_volume * volume / 100
      vxaos_bgs_play(filename, volume, pitch, pos)
    end
    
    def bgs_stop
      @bgs_filename = nil
      vxaos_bgs_stop
    end
    
    def me_play(filename, volume = 100, pitch = 100)
      volume = @music_volume * volume / 100
      vxaos_me_play(filename, volume, pitch)
    end
    
    def se_play(filename, volume = 100, pitch = 100)
      volume = @sound_volume * volume / 100
      vxaos_se_play(filename, volume, pitch)
    end
    
  end
  
end

Audio.load
Graphics.resize_screen(Configs::RESOLUTIONS[Audio.resolution_id][:width], Configs::RESOLUTIONS[Audio.resolution_id][:height])
# Se a tela cheia está ativada e o executável utiliza DirectX 9
Graphics.toggle_fullscreen if Audio.fullscreen == 0 && Graphics.respond_to?(:toggle_fullscreen)
Graphics.vsync = (Audio.vsync == 0) if Graphics.respond_to?(:vsync)
Graphics.background_exec = true if Graphics.respond_to?(:background_exec)
