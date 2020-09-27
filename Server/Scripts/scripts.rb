#==============================================================================
# ** Scripts
#------------------------------------------------------------------------------
#  Executa os scripts Configs, Quests, Kernel e Enums do cliente.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

scripts = load_data('Scripts.rvdata2')
# Executa os scripts Configs, Quests e Constants
eval(Zlib::Inflate.inflate(scripts[1][2]))
eval(Zlib::Inflate.inflate(scripts[2][2]))
scripts.each { |script| eval(Zlib::Inflate.inflate(script[2])) if script[1].include?('Kernel') || script[1].include?('Enums') }
