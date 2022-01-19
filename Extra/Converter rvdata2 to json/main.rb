#==============================================================================
# ** Main
#------------------------------------------------------------------------------
#  Este script inicia o processamento.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

require 'json'
require 'zlib'

require_relative 'jsonable'
require_relative 'rgss'

path_names = [
  'Data/Actors.rvdata2',
  'Data/Classes.rvdata2',
  'Data/Skills.rvdata2',
  'Data/Items.rvdata2',
  'Data/Weapons.rvdata2',
  'Data/Armors.rvdata2',
  'Data/Enemies.rvdata2',
  'Data/States.rvdata2',
  'Data/Animations.rvdata2',
  'Data/Tilesets.rvdata2',
  'Data/CommonEvents.rvdata2',
  'Data/System.rvdata2',
  'Data/MapInfos.rvdata2',
  #*Dir.glob('Data/Map[0-9][0-9][0-9].rvdata2')
]
unless File.exist?(path_names.first)
  puts('Nenhum arquivo encontrado na pasta Data.')
  return
end
Dir.mkdir('json') unless Dir.exist?('json')
path_names.each do |path_name|
  file_name = File.basename(path_name, '.rvdata2')
  puts("Convertendo #{file_name}...")
  rvdata = Jsonable.load_rvdata(path_name)
  Jsonable.save_to_json(file_name, rvdata)
end
puts('Todos os arquivos foram convertidos com sucesso.')
