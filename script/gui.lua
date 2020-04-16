local road_network = require("script/road_network")

local network_size = function(network)
  
  --This is a meh way to do it.

  local sum = 0
  
  for category, depots in pairs (network.depots) do
    sum = sum + table_size(depots)
  end

  return sum
end

local cache = {}
local get_item_icon_and_locale = function(name)
  if cache[name] then
    return cache[name]
  end

  local items = game.item_prototypes
  if items[name] then
    icon = "item/"..name 
    locale = items[name].localised_name
    local value = {icon = icon, locale = locale}
    cache[name] = value
    return value
  end

  local fluids = game.fluid_prototypes
  if fluids[name] then
    icon = "fluid/"..name
    locale = fluids[name].localised_name
    local value = {icon = icon, locale = locale}
    cache[name] = value
    return value
  end

end

local add_contents_tab = function(tabbed_pane, network)
  local contents_tab = tabbed_pane.add{type = "tab", caption = "Contents"}
  local contents = tabbed_pane.add{type = "scroll-pane"}
  contents.style.maximal_width = 1900
  --contents.style.width = 1900
  --contents.style.horizontally_stretchable = true
  --contents.style.horizontally_squashable = false
  local contents_table = contents.add{type = "table", column_count = 4, style = "bordered_table"}
  contents_table.style.column_alignments[1] = "center"
  contents_table.style.column_alignments[2] = "center"
  contents_table.style.column_alignments[3] = "center"
  contents_table.style.column_alignments[4] = "center"
  --contents_table.style.horizontally_stretchable = false
  --contents_table.style.horizontally_squashable = false
  local items = game.item_prototypes
  local fluids = game.fluid_prototypes
  for name, counts in pairs (network.item_supply) do
    local item_locale = get_item_icon_and_locale(name)
    if item_locale then
      local sum = 0
      for depot_id, count in pairs (counts) do
        sum = sum + count
      end
      if sum > 0 then
        local flow = contents_table.add{type = "flow"}
        flow.add{type = "sprite-button", sprite = item_locale.icon, number = sum, style = "slot_button"}
        local label = flow.add{type = "label", caption = item_locale.locale}
        --label.style.width = 128
        flow.style.vertical_align = "center"
        flow.style.horizontally_stretchable = true
      end
    end
  end
  tabbed_pane.add_tab(contents_tab, contents)
end

local add_contents = function(gui, contents)
  local items = game.item_prototypes
  local fluids = game.fluid_prototypes

  for name, count in pairs (contents) do
    local item_locale = get_item_icon_and_locale(name)
    if item_locale then
      --local flow = gui.add{type = "flow"}
      gui.add{type = "sprite-button", sprite = item_locale.icon, number = count, style = "slot_button"}
      --flow.add{type = "sprite-button", sprite = icon, number = count, style = "slot_button"}
      --local label = flow.add{type = "label", caption = locale}
      --label.style.width = 128
      --flow.style.vertical_align = "center"
      
    end
  end
  
end

local map_size = 70
local add_supply_tab = function(tabbed_pane, network)
  local supply_tab = tabbed_pane.add{type = "tab", caption = "Supply depots"}
  local contents = tabbed_pane.add{type = "scroll-pane"}
  
  local depots = network.depots.supply
  
  if not depots then
    supply_tab.enabled = false
    tabbed_pane.add_tab(supply_tab, contents)
    return
  end

  local depot_table = contents.add{type = "table", column_count = 2, style = "bordered_table"}
  depot_table.style.horizontally_stretchable = true

  for index, depot in pairs (depots) do
    --local depot_frame = depot_table.add{type = "frame", style = "bordered_frame"}
    local depot_frame = depot_table.add{type = "flow"}
    depot_frame.style.horizontally_stretchable = true
    local button = depot_frame.add{type = "button"}
    button.style.width = map_size + 8
    button.style.height = map_size + 8
    button.style.horizontal_align = "center"
    button.style.vertical_align = "center"
    button.style.padding = {0,0,0,0}
    local entity = depot.entity
    local map = button.add
    {
      type = "minimap",
      position = entity.position,
      surface_index = entity.surface.index,
      force = entity.force.name,
      zoom = 1,
      ignored_by_interaction = true
    }
    map.style.width = map_size
    map.style.height = map_size
    local contents = depot.old_contents
    if next(contents) then
      local table = depot_frame.add{type = "table", column_count = 6}
      table.style.horizontally_stretchable = true
      add_contents(table, contents)
    else
      --depot_frame.add{type = "label", caption = "No contents"}
    end
    local pusher = depot_frame.add{type = "empty-widget"}
    pusher.style.horizontally_stretchable = true
  end


  tabbed_pane.add_tab(supply_tab, contents)
end

local map_size = 70
local add_fluid_tab = function(tabbed_pane, network)
  local fluid_tab = tabbed_pane.add{type = "tab", caption = "Fluid depots"}
  local contents = tabbed_pane.add{type = "scroll-pane"}

  local depots = network.depots.fluid

  if not depots then
    fluid_tab.enabled = false
    tabbed_pane.add_tab(fluid_tab, contents)
    return
  end

  local depot_table = contents.add{type = "table", column_count = 2, style = "bordered_table"}
  depot_table.style.horizontally_stretchable = true

  for index, depot in pairs (depots) do
    --local depot_frame = depot_table.add{type = "frame", style = "bordered_frame"}
    local depot_frame = depot_table.add{type = "flow"}
    depot_frame.style.horizontally_stretchable = true
    local button = depot_frame.add{type = "button"}
    button.style.width = map_size + 8
    button.style.height = map_size + 8
    button.style.horizontal_align = "center"
    button.style.vertical_align = "center"
    button.style.padding = {0,0,0,0}
    local entity = depot.entity
    local map = button.add
    {
      type = "minimap",
      position = entity.position,
      surface_index = entity.surface.index,
      force = entity.force.name,
      zoom = 1,
      ignored_by_interaction = true
    }
    map.style.width = map_size
    map.style.height = map_size
    local contents = depot.old_contents
    if next(contents) then
      local table = depot_frame.add{type = "table", column_count = 6}
      table.style.horizontally_stretchable = true
      add_contents(table, contents)
    else
      --depot_frame.add{type = "label", caption = "No contents"}
    end
    local pusher = depot_frame.add{type = "empty-widget"}
    pusher.style.horizontally_stretchable = true
  end


  tabbed_pane.add_tab(fluid_tab, contents)
end

local map_size = 70
local add_mining_tab = function(tabbed_pane, network)
  local mining_tab = tabbed_pane.add{type = "tab", caption = "Mining depots"}
  local contents = tabbed_pane.add{type = "scroll-pane"}
  
  local depots = network.depots.mining

  if not depots then
    mining_tab.enabled = false
    tabbed_pane.add_tab(mining_tab, contents)
    return
  end

  local depot_table = contents.add{type = "table", column_count = 2, style = "bordered_table"}
  depot_table.style.horizontally_stretchable = true

  for index, depot in pairs (depots) do
    --local depot_frame = depot_table.add{type = "frame", style = "bordered_frame"}
    local depot_frame = depot_table.add{type = "flow"}
    depot_frame.style.horizontally_stretchable = true
    local button = depot_frame.add{type = "button"}
    button.style.width = map_size + 8
    button.style.height = map_size + 8
    button.style.horizontal_align = "center"
    button.style.vertical_align = "center"
    button.style.padding = {0,0,0,0}
    local entity = depot.entity
    local map = button.add
    {
      type = "minimap",
      position = entity.position,
      surface_index = entity.surface.index,
      force = entity.force.name,
      zoom = 1,
      ignored_by_interaction = true
    }
    map.style.width = map_size
    map.style.height = map_size
    local contents = depot.old_contents
    if next(contents) then
      local table = depot_frame.add{type = "table", column_count = 6}
      table.style.horizontally_stretchable = true
      add_contents(table, contents)
    else
      depot_frame.add{type = "label", caption = "No contents"}
    end
    local pusher = depot_frame.add{type = "empty-widget"}
    pusher.style.horizontally_stretchable = true
  end


  tabbed_pane.add_tab(mining_tab, contents)
end

local map_size = 70
local add_requester_tab = function(tabbed_pane, network)
  local requester_tab = tabbed_pane.add{type = "tab", caption = "Request depots"}
  local contents = tabbed_pane.add{type = "scroll-pane"}
  
  local depots = network.depots.request
  
  if not depots then
    requester_tab.enabled = false
    tabbed_pane.add_tab(requester_tab, contents)
    return
  end

  local depot_table = contents.add{type = "table", column_count = 2, style = "bordered_table"}
  depot_table.style.horizontally_stretchable = true

  for index, depot in pairs (depots) do
    --local depot_frame = depot_table.add{type = "frame", style = "bordered_frame"}
    local depot_frame = depot_table.add{type = "flow"}
    depot_frame.style.horizontally_stretchable = true
    local button = depot_frame.add{type = "button"}
    button.style.width = map_size + 8
    button.style.height = map_size + 8
    button.style.horizontal_align = "center"
    button.style.vertical_align = "center"
    button.style.padding = {0,0,0,0}
    local entity = depot.entity
    local map = button.add
    {
      type = "minimap",
      position = entity.position,
      surface_index = entity.surface.index,
      force = entity.force.name,
      zoom = 1,
      ignored_by_interaction = true
    }
    map.style.width = map_size
    map.style.height = map_size
    local contents = depot.old_contents
    if next(contents) then
      local table = depot_frame.add{type = "table", column_count = 6}
      table.style.horizontally_stretchable = true
      add_contents(table, contents)
    else
      depot_frame.add{type = "label", caption = "No contents"}
    end
    local pusher = depot_frame.add{type = "empty-widget"}
    pusher.style.horizontally_stretchable = true
  end

  tabbed_pane.add_tab(mining_tab, contents)
end

local fuel_map_size = 90
local add_fuel_tab = function(tabbed_pane, network)
  local fuel_tab = tabbed_pane.add{type = "tab", caption = "Fuel depots"}
  local contents = tabbed_pane.add{type = "scroll-pane"}
  
  local depots = network.depots.fuel
  
  if not depots then
    fuel_tab.enabled = false
    tabbed_pane.add_tab(fuel_tab, contents)
    return
  end

  local depot_table = contents.add{type = "table", column_count = 2, style = "bordered_table"}
  depot_table.style.horizontally_stretchable = true

  for index, depot in pairs (network.depots.fuel) do
    --local depot_frame = depot_table.add{type = "frame", style = "bordered_frame"}
    local depot_frame = depot_table.add{type = "flow"}
    depot_frame.style.horizontally_stretchable = true
    local button = depot_frame.add{type = "button"}
    button.style.width = fuel_map_size + 8
    button.style.height = fuel_map_size + 8
    button.style.horizontal_align = "center"
    button.style.vertical_align = "center"
    button.style.padding = {0,0,0,0}
    local entity = depot.entity
    local map = button.add
    {
      type = "minimap",
      position = entity.position,
      surface_index = entity.surface.index,
      force = entity.force.name,
      zoom = 1,
      ignored_by_interaction = true
    }
    map.style.width = fuel_map_size
    map.style.height = fuel_map_size
    local flow = depot_frame.add{type = "table", column_count = 1, style = "bordered_table"}
    local label = flow.add{type = "label", caption = "Active Drones: "..depot:get_active_drone_count()}
    label.style.horizontally_stretchable = true
    flow.add{type = "label", caption = "Available Drones: "..depot:get_drone_item_count()}
    flow.add{type = "label", caption = "Available Fuel: "..math.floor(depot:get_fuel_amount())}
    flow.style.horizontally_stretchable = true
  end


  tabbed_pane.add_tab(fuel_tab, contents)
end

local request_map_size = 90
local floor = math.floor
local add_request_tab = function(tabbed_pane, network)
  local request_tab = tabbed_pane.add{type = "tab", caption = "Request depots"}
  local contents = tabbed_pane.add{type = "scroll-pane"}
  
  local depots = network.depots.request
  if not depots then
    request_tab.enabled = false
    tabbed_pane.add_tab(request_tab, contents)
    return
  end

  local depot_table = contents.add{type = "table", column_count = 2, style = "bordered_table"}
  depot_table.style.horizontally_stretchable = true

  for index, depot in pairs (depots) do
    --local depot_frame = depot_table.add{type = "frame", style = "bordered_frame"}
    local depot_frame = depot_table.add{type = "flow"}
    depot_frame.style.horizontally_stretchable = true
    local button = depot_frame.add{type = "button"}
    button.style.width = request_map_size + 8
    button.style.height = request_map_size + 8
    button.style.horizontal_align = "center"
    button.style.vertical_align = "center"
    button.style.padding = {0,0,0,0}
    local entity = depot.entity
    local map = button.add
    {
      type = "minimap",
      position = entity.position,
      surface_index = entity.surface.index,
      force = entity.force.name,
      zoom = 1,
      ignored_by_interaction = true
    }
    map.style.width = request_map_size
    map.style.height = request_map_size
    local flow = depot_frame.add{type = "table", column_count = 1, style = "bordered_table"}
    local label = flow.add{type = "label", caption = "Active Drones: "..depot:get_active_drone_count()}
    label.style.horizontally_stretchable = true
    flow.add{type = "label", caption = "Available Drones: "..depot:get_drone_item_count()}
    flow.add{type = "label", caption = "Available Fuel: "..math.floor(depot:get_fuel_amount())}
    flow.style.horizontally_stretchable = true
    
    
    local item = depot.item
    if item then
      local item_locale = get_item_icon_and_locale(item)
      if item_locale then
        local request_flow = depot_frame.add{type = "table", column_count = 1, style = "bordered_table"}
        local current_item_flow = request_flow.add{type = "flow"}
        current_item_flow.style.vertical_align = "center"
        local current_count = floor(depot:get_current_amount())
        current_item_flow.add
        {
          type = "sprite-button",
          sprite = item_locale.icon,
          number = current_count,
          tooltip = {"", item_locale.locale, ": ", current_count},
          style = "slot_button"
        }
        current_item_flow.add{type = "label", caption = "Current"}    
        local requested_item_flow = request_flow.add{type = "flow"}
        requested_item_flow.style.vertical_align = "center"
        local request_count = depot:get_request_size() * depot:get_drone_item_count()
        requested_item_flow.add
        {
          type = "sprite-button",
          sprite = item_locale.icon,
          number = request_count,
          tooltip = {"", item_locale.locale, ": ", request_count},
          style = "slot_button"
        }
        requested_item_flow.add{type = "label", caption = "Requested"}    
        --flow.add{type = "sprite-button", sprite = icon, number = count, style = "slot_button"}
        --local label = flow.add{type = "label", caption = locale}
        --label.style.width = 128
        --flow.style.vertical_align = "center"
      end
    else
      depot_frame.add{type = "label", caption = "No request set"}    

    end
  end


  tabbed_pane.add_tab(request_tab, contents)
end


local buffer_map_size = 90
local floor = math.floor
local add_buffer_tab = function(tabbed_pane, network)
  local buffer_tab = tabbed_pane.add{type = "tab", caption = "Buffer depots"}
  local contents = tabbed_pane.add{type = "scroll-pane"}
  
  local depots = network.depots.buffer
  if not depots then
    buffer_tab.enabled = false
    tabbed_pane.add_tab(buffer_tab, contents)
    return
  end
  
  local depot_table = contents.add{type = "table", column_count = 2, style = "bordered_table"}
  depot_table.style.horizontally_stretchable = true

  for index, depot in pairs (depots) do
    --local depot_frame = depot_table.add{type = "frame", style = "bordered_frame"}
    local depot_frame = depot_table.add{type = "flow"}
    depot_frame.style.horizontally_stretchable = true
    local button = depot_frame.add{type = "button"}
    button.style.width = request_map_size + 8
    button.style.height = request_map_size + 8
    button.style.horizontal_align = "center"
    button.style.vertical_align = "center"
    button.style.padding = {0,0,0,0}
    local entity = depot.entity
    local map = button.add
    {
      type = "minimap",
      position = entity.position,
      surface_index = entity.surface.index,
      force = entity.force.name,
      zoom = 1,
      ignored_by_interaction = true
    }
    map.style.width = request_map_size
    map.style.height = request_map_size
    local flow = depot_frame.add{type = "table", column_count = 1, style = "bordered_table"}
    local label = flow.add{type = "label", caption = "Active Drones: "..depot:get_active_drone_count()}
    label.style.horizontally_stretchable = true
    flow.add{type = "label", caption = "Available Drones: "..depot:get_drone_item_count()}
    flow.add{type = "label", caption = "Available Fuel: "..math.floor(depot:get_fuel_amount())}
    flow.style.horizontally_stretchable = true
    
    
    local item = depot.item
    if item then
      local item_locale = get_item_icon_and_locale(item)
      if item_locale then
        local request_flow = depot_frame.add{type = "table", column_count = 1, style = "bordered_table"}
        local current_item_flow = request_flow.add{type = "flow"}
        current_item_flow.style.vertical_align = "center"
        local current_count = floor(depot:get_current_amount())
        current_item_flow.add
        {
          type = "sprite-button",
          sprite = item_locale.icon,
          number = current_count,
          tooltip = {"", item_locale.locale, ": ", current_count},
          style = "slot_button"
        }
        current_item_flow.add{type = "label", caption = "Current"}    
        local requested_item_flow = request_flow.add{type = "flow"}
        requested_item_flow.style.vertical_align = "center"
        local request_count = depot:get_request_size() * depot:get_drone_item_count()
        requested_item_flow.add
        {
          type = "sprite-button",
          sprite = item_locale.icon,
          number = request_count,
          tooltip = {"", item_locale.locale, ": ", request_count},
          style = "slot_button"
        }
        requested_item_flow.add{type = "label", caption = "Requested"}    
        --flow.add{type = "sprite-button", sprite = icon, number = count, style = "slot_button"}
        --local label = flow.add{type = "label", caption = locale}
        --label.style.width = 128
        --flow.style.vertical_align = "center"
      end
    else
      depot_frame.add{type = "label", caption = "No request set"}    

    end
  end


  tabbed_pane.add_tab(buffer_tab, contents)
end

local make_network_gui = function(inner, network)
  local tabbed_pane = inner.add{type = "tabbed-pane"}
  add_contents_tab(tabbed_pane, network)
  add_supply_tab(tabbed_pane, network)
  add_fluid_tab(tabbed_pane, network)
  add_mining_tab(tabbed_pane, network)
  add_fuel_tab(tabbed_pane, network)
  add_request_tab(tabbed_pane, network)
  add_buffer_tab(tabbed_pane, network)
  

  
end

local refresh_network_gui = function(player, selected_index)
  local gui = player.gui.screen

  local frame = gui.road_network_frame
  if not frame then return end

  local networks = road_network.get_networks()

  local index, network
  for k = 1, selected_index do
    index, network = next(networks, index)
  end

  if not network then return end

  local inner = frame.add{type = "frame", style = "inside_deep_frame_for_tabs"}

  make_network_gui(inner, network)

end

local open_gui = function(player)
  local gui = player.gui.screen

  local frame = gui.add{type = "frame", direction = "vertical", name = "road_network_frame"}
  frame.style.maximal_height = 1000

  local title_flow = frame.add{type = "flow"}

  local title = title_flow.add{type = "label", caption = "Road networks", style = "frame_title"}
  title.drag_target = frame

  local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
  pusher.style.vertically_stretchable = true
  pusher.style.horizontally_stretchable = true
  pusher.drag_target = frame

  local drop_down = title_flow.add{type = "drop-down", name = "road_network_drop_down"}
  
  local networks = road_network.get_networks()
  
  local selected
  local big = 0
  local count = 0
  for k, network in pairs (networks) do
    count = count + 1
    if not selected then selected = count end
    local size = network_size(network)
    drop_down.add_item("Network #"..count.." - "..size.." depots")
    if size > big then
      big = size
      selected = count
    end
  end

  if count == 0 then return end
  drop_down.selected_index = selected

  refresh_network_gui(player, selected)

  frame.auto_center = true

end



commands.add_command("toggle-transport-depot-gui", "idk",
function(command)
  local player = game.player
  if not player then return end
  open_gui(player)
end)

local lib = {}

lib.events =
{
  [defines.events.on_gui_click] = on_gui_click
}

return lib
