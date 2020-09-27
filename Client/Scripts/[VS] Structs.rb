#==============================================================================
# ** Structs
#------------------------------------------------------------------------------
#  Este script lida com as estruturas.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

Actor = Struct.new(
  :name,
  :character_name,
  :character_index,
  :face_name,
  :face_index,
  :sex,
  :equips
)

Guild = Struct.new(
  :leader,
  :notice,
  :flag,
  :members,
  :online_size
)

Chat_Line = Struct.new(
  :text,
  :color_id
)

Reward = Struct.new(
  :item,
  :item_amount,
  :exp,
  :gold
)
