#==============================================================================
# ** Quests
#------------------------------------------------------------------------------
#  Este módulo lida com as missões. Ele também é executado
# no servidor. Caso não entenda como acrescentar novas 
# missões, estude sobre Arrays da linguágem Ruby.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Quests
  
  # Dados das missões
  DATA = []
  
  # Missão 1
  DATA << {
    :name            => 'Estimulante Mágico',
    :desc            => 'Pegue 1 Estimulante no baú mágico.',
    # Requisitos para finalizar a missão
    :switch_id       => 0,
    :variable_id     => 0,
    :variable_amount => 0,
    :item_id         => 5,
    :item_kind       => 1, # (1 = item, 2 = arma, 3 = protetor)
    :item_amount     => 1,
    :enemy_id        => 0,
    :enemy_amount    => 0,
    # Recompensas
    :rew_exp         => 10,
    :rew_gold        => 10,
    :rew_item_id     => 0,
    :rew_item_kind   => 0, # (1 = item, 2 = arma, 3 = protetor)
    :rew_item_amount => 0

  }
  
  # Missão 2
  DATA << {
    :name            => 'Morcegos Malditos',
    :desc            => 'Mate 10 Morcegos na Caverna.',
    # Requisitos para finalizar a missão
    :switch_id       => 0,
    :variable_id     => 0,
    :variable_amount => 0,
    :item_id         => 0,
    :item_kind       => 0, # (1 = item, 2 = arma, 3 = protetor)
    :item_amount     => 0,
    :enemy_id        => 2,
    :enemy_amount    => 10,
    # Recompensas
    :rew_exp         => 20,
    :rew_gold        => 20,
    :rew_item_id     => 2,
    :rew_item_kind   => 2, # (1 = item, 2 = arma, 3 = protetor)
    :rew_item_amount => 1,
    # Repetição da missão (opcional)
    :repeat          => true
  }
  
end
