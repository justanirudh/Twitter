# def get_keys(list) do
#     if
# end

:ets.new(:ht_table, [:set, :public, :named_table])
# :ets.insert(:ht_table, {1,"10"})
# :ets.insert(:ht_table, {2,"20"})
# :ets.insert(:ht_table, {3,"30"})
first = :ets.first(:ht_table)
# next = :ets.next(:ht_table, first)
IO.inspect first
# IO.inspect next
# get_keys([])
