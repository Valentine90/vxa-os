#==============================================================================
# ** Settings_File
#------------------------------------------------------------------------------
#  Este script lida com o arquivo INI de configurações.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Settings_File
  
  attr_reader   :music_volume
  attr_reader   :sound_volume
  attr_reader   :fullscreen
  attr_reader   :vsync
  attr_accessor :user
  attr_accessor :resolution_id
  
  def initialize(filename)
    @ini = INI.new(filename)
    @user = @ini['Settings']['User']
    @music_volume = @ini['Settings']['MusicVolume']
    @sound_volume = @ini['Settings']['SoundVolume']
    @resolution_id = @ini['Settings']['ResolutionID']
    @fullscreen = @ini['Settings']['Fullscreen']
    @vsync = @ini['Settings']['VSync']
  end
  
  def music_volume=(volume)
    @music_volume = volume
    Audio.update_bgm_volume
  end
  
  def sound_volume=(volume)
    @sound_volume = volume
    Audio.update_bgs_volume
  end
  
  def fullscreen=(fullscreen)
    @fullscreen = fullscreen
    Graphics.toggle_fullscreen if fullscreen == 0 && !Graphics.is_fullscreen? || fullscreen == 1 && Graphics.is_fullscreen?
  end
  
  def vsync=(vsync)
    @vsync = vsync
    Graphics.vsync = (vsync == 0)
  end
  
  def save
    @ini['Settings']['User'] = @user
    @ini['Settings']['MusicVolume'] = @music_volume
    @ini['Settings']['SoundVolume'] = @sound_volume
    @ini['Settings']['ResolutionID'] = @resolution_id
    @ini['Settings']['Fullscreen'] = @fullscreen
    @ini['Settings']['VSync'] = @vsync
    file = File.open(@ini.filename, 'w')
    @ini.each do |key, property|
      file.puts("[#{key}]")
      property.each { |name, value| file.puts("#{name}=#{value}") }
    end
    file.close
  end
  
end
