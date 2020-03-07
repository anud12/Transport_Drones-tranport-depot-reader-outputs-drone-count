local transport_drone = require("script/transport_drone")
local road_network = require("script/road_network")

local request_spawn_timeout = 37

local script_data = 
{
  request_depots = {}
}

local request_depot = {}
local depot_metatable = {__index = request_depot}

local corpse_offsets = 
{
  [0] = {0, -2},
  [2] = {2, 0},
  [4] = {0, 2},
  [6] = {-2, 0},
}

function request_depot.new(entity)

  local position = entity.position
  local direction = entity.direction
  local force = entity.force
  local surface = entity.surface
  local offset = corpse_offsets[direction]

  entity.destroy()

  local machine = surface.create_entity{name = "request-depot-machine", position = position, force = force}
  machine.active = false
  local corpse_position = {position.x + offset[1], position.y + offset[2]}
  local corpse = surface.create_entity{name = "caution-corpse", position = corpse_position}
  corpse.corpse_expires = false
  
  local depot =
  {
    entity = machine,
    corpse = corpse,
    index = tostring(machine.unit_number),
    on_the_way = 0,
    node_position = {math.floor(corpse_position[1]), math.floor(corpse_position[2])},
    item = false,
    drones = {},
    last_spawn_tick = 0
  }
  setmetatable(depot, depot_metatable)

  script_data.request_depots[depot.index] = depot


end

function request_depot:check_request_change()
  local requested_item = self:get_requested_item()
  if self.item == requested_item then return end

  if self.item then
    self:remove_from_network()
  end

  self.item = requested_item

  if not self.item then return end

  self:add_to_network()

end

function request_depot:get_requested_item()
  local recipe = self.entity.get_recipe()
  if not recipe then return end
  return recipe.products[1].name
end

function request_depot:get_stack_size()
  return game.item_prototypes[self.item].stack_size
end

function request_depot:get_output_inventory()
  return self.entity.get_output_inventory()
end

function request_depot:get_needed_item_count()
  local stack_size = self:get_stack_size()
  local needed = self:get_drone_item_count() * stack_size
  needed = needed - self.on_the_way
  return needed - self:get_output_inventory().get_item_count(self.item)
end

function request_depot:get_drone_inventory()
  return self.entity.get_inventory(defines.inventory.assembling_machine_input)
end

function request_depot:get_active_drone_count()
  return table_size(self.drones)
end

function request_depot:can_spawn_drone()
  if game.tick - self.last_spawn_tick <= request_spawn_timeout then return end
  return self:get_drone_item_count() > self:get_active_drone_count()
end

function request_depot:get_drone_item_count()
  return self.entity.get_item_count("transport-drone")
end

function request_depot:handle_offer(supply_depot, name, count)

  if not self:can_spawn_drone() then return 0 end

  local stack_size = self:get_stack_size()
  local current_count = self:get_output_inventory().get_item_count(self.item)
  local max_count = self:get_drone_item_count()
  local drone_spawn_count = max_count - math.floor(current_count / stack_size)
  if (drone_spawn_count - self:get_active_drone_count()) <= 0 then return 0 end

  --Just assume we will always try to take a whole stack.
  local needed_count = self:get_stack_size()

  self.on_the_way = self.on_the_way + needed_count

  local drone = transport_drone.new(self, supply_depot, name, needed_count)
  self.drones[drone.index] = drone
  self.last_spawn_tick = game.tick
  self:update_sticker()

  return needed_count
end

function request_depot:take_item(name, count)
  self.on_the_way = self.on_the_way - count
  self.entity.get_output_inventory().insert({name = name, count = count})
end

function request_depot:remove_drone(drone, remove_item)
  self.drones[drone.index] = nil
  if remove_item then
    self:get_drone_inventory().remove{name = "transport-drone", count = 1}
  end
  self:update_sticker()
end

function request_depot:update_sticker()

  if self.rendering and rendering.is_valid(self.rendering) then
    rendering.set_text(self.rendering, self:get_active_drone_count().."/"..self:get_drone_item_count())
    return
  end

  if not self.item then return end

  self.rendering = rendering.draw_text
  {
    surface = self.entity.surface.index,
    target = self.entity,
    text = self:get_active_drone_count().."/"..self:get_drone_item_count(),
    only_in_alt_mode = true,
    forces = {self.entity.force},
    color = {r = 1, g = 1, b = 1},
    alignment = "center",
    scale = 1.5
  }

end


function request_depot:say(string)
  self.entity.surface.create_entity{name = "flying-text", position = self.entity.position, text = string}
end

function request_depot:add_to_network()
  self:say("Adding to network")
  self.network_id = road_network.add_request_depot(self, self.item)
end

function request_depot:remove_from_network()

  local network = road_network.get_network_by_id(self.network_id)
  if not network then return end
  local requesters = network.requesters

  requesters[self.item][self.index] = nil

  self.network_id = nil

end

function request_depot:remove_from_node()
  local node = road_network.get_node(self.entity.surface.index, self.node_position[1], self.node_position[2])
  node.requesters[self.index] = nil
end


function request_depot:on_removed()
  self:remove_from_network()
  self:remove_from_node()
  self.corpse.destroy()
  script_data.request_depots[self.index] = nil
end

local on_created_entity = function(event)
  local entity = event.entity or event.created_entity
  if not (entity and entity.valid) then return end

  if entity.name ~= "request-transport-depot" then return end

  request_depot.new(entity)

end

local check_request_change = function(event)
  for k, request_depot in pairs (script_data.request_depots) do
    request_depot:check_request_change()
  end
end

local on_entity_removed = function(event)
  local entity = event.entity

  if not (entity and entity.valid) then return end

  if entity.name ~= "request-depot-machine" then return end

  local index = tostring(entity.unit_number)
  local depot = script_data.request_depots[index]
  if depot then
    depot:on_removed()
  end

end

local lib = {}

lib.events =
{
  [defines.events.on_built_entity] = on_created_entity,
  [defines.events.on_robot_built_entity] = on_created_entity,
  [defines.events.script_raised_built] = on_created_entity,
  [defines.events.script_raised_revive] = on_created_entity,

  [defines.events.on_entity_died] = on_entity_removed,
  [defines.events.on_robot_mined_entity] = on_entity_removed,
  [defines.events.script_raised_destroy] = on_entity_removed,
  [defines.events.on_player_mined_entity] = on_entity_removed
}

lib.on_nth_tick =
{
  [237] = check_request_change
}


lib.on_init = function()
  global.request_depots = global.request_depots or script_data
end

lib.on_load = function()
  script_data = global.request_depots or script_data
  for k, depot in pairs (script_data.request_depots) do
    setmetatable(depot, depot_metatable)
  end
end

lib.get_depots_for_item = function(item)
  return script_data.item_map[item]
end

return lib