def unpack_metadata data
  items = data.reduce([]) {|items, itemdata| items+itemdata.items}
  descs = data.reduce([]) {|descs, itemdata| descs+itemdata.descriptions}
  comms = data.reduce([]) {|comms, itemdata| comms+itemdata.commands}

  [items, descs, comms]
end
