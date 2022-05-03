include("./node.jl")

const messages = Vector{String}(undef, 0)
const wait_for_enter() = (print(stdout, "\nPress Enter key to continue"); read(stdin, 1); nothing)
const announce(msg::String) = (println(msg); push!(messages, msg * "\n"); nothing)

@kwdef mutable struct Simulation
  cable_size::Int = 0
  cable::Vector{Vector{SignalNode}} = create_vector(cable_size, [])
  free_positions::Vector{Node} = create_vector(cable_size, Node())
  active_nodes::Vector{Node} = []
  nodes_statistics::Dict{String, Dict{Symbol, Int}} = Dict()
end

function create_vector(max, x)
  return [x for _ in 1:max]
end

function cable_empty(cable::Vector{Vector{SignalNode}})
  for segment in cable
    if !(isempty(segment)) return false end
  end
  return true
end

function add_node(sim::Simulation, node::Node)
  if node.position < 1 || node.position > sim.cable_size
    println("Wrong position.")
  elseif !(sim.free_positions[node.position] != Node())
    println("Position already taken.")
  else
    sim.free_positions[node.position] = node
    if node.frames > 0 
      push!(sim.active_nodes, node)
    end
  end
  sim.nodes_statistics[node.name] = Dict(
    :collisions => 0, 
    :idle_time => 0, 
    :stop_iteration => 0
  )
end

function run(sim::Simulation, slow::Bool=false)
  iteration = 0
  while !(isempty(sim.active_nodes)) || !(cable_empty(sim.cable))
    iteration += 1
    announce("\nIteration: $iteration")
    step(sim, iteration)
    announce("Cable after $iteration:\n$(cable_state_str(sim.cable))")
    if (slow) wait_for_enter() end
  end
end

function step(sim::Simulation, iteration::Int)
  # next state of the cable
  next_state::Vector{Vector{SignalNode}} = create_vector(sim.cable_size, [])

  for (i, segment) in enumerate(sim.cable)
    for packet in segment
      if packet.direction == left && i > 1 
        push!(next_state[i - 1], packet)
      elseif packet.direction == right && i < sim.cable_size
        push!(next_state[i + 1], packet) 
      elseif packet.direction == both
        if i > 1 push!(next_state[i - 1], SignalNode(node=packet.node, direction=left)) end
        if i < sim.cable_size push!(next_state[i + 1], SignalNode(node=packet.node, direction=right)) end
      end
    end
  end

  broadcast(sim, next_state, iteration)
  sim.cable = next_state
end

function broadcast(sim::Simulation, next_state::Vector{Vector{SignalNode}}, iteration::Int)
  for a_node in sim.active_nodes  
    # if node can start broadcasting
    if a_node.idle 
      if a_node.idle_time == 0  
        if (next_state[a_node.position] == [])
          announce("$(a_node.name) started broadcasting")
          a_node.idle = false
          a_node.idle_time = 2 * sim.cable_size
        else
          announce("$(a_node.name) is waiting")
          sim.nodes_statistics[a_node.name][:idle_time] += 1
        end
      else 
        announce("$(a_node.name) is waiting")
        a_node.idle_time -= 1
      end

    elseif !(a_node.idle) && a_node.idle_time == 0
      announce("$(a_node.name) stopped broadcasting")
      a_node.idle = true
      # if there was a collision
      if a_node.collision
        a_node.collision = false

        node_collision(a_node)
        sim.nodes_statistics[a_node.name][:idle_time] += a_node.idle_time
      else
        a_node.frames -= 1
        sim.nodes_statistics[a_node.name][:collisions] += a_node.detected_collisions
        a_node.detected_collisions = 0

        # all packets has been sent
        if a_node.frames == 0 
          filter!(x -> x != a_node, sim.active_nodes)
          sim.nodes_statistics[a_node.name][:stop_iteration] = iteration
        end
      end

    elseif !(a_node.idle) && a_node.idle_time > 0
      # collision detected
      if !(a_node.collision) && !isempty(next_state[a_node.position])
        announce("$(a_node.name) detected a collision, sending collision signal")
        a_node.collision = true
        a_node.idle_time = 2 * sim.cable_size
      end
      announce("$(a_node.name) continues broadcasting")
      push!(next_state[a_node.position], SignalNode(node=a_node, direction=both))
      a_node.idle_time -= 1
    end
  end
end

function cable_state_str(cable::Vector{Vector{SignalNode}})::String
  str::String = ""
  str *= "["
  for fragment in cable
    str *= "["
    for packet_pos in 1:length(fragment)-1
      str *= "$(fragment[packet_pos].node.name)$(fragment[packet_pos].collision_packet == true ? "!" : ""),"
    end
    if (length(fragment) > 0) str *= "$(fragment[end].node.name)" end
    str *= "]"
  end
  str *= "]"
end

function statistics(sim::Simulation)
  for node_name in keys(sim.nodes_statistics)
    println("Node: $node_name")
    for statistic in keys(sim.nodes_statistics[node_name])
      println("$statistic: $(sim.nodes_statistics[node_name][statistic])")
    end
  end
end

function main(args::Array{String})
  test = Simulation(cable_size=10)
  add_node(test, create_node("A", 1, 0, 3))
  add_node(test, create_node("B", 3, 3, 4))
  add_node(test, create_node("C", 10, 5, 1))
  add_node(test, create_node("D", 6, 0, 3))

  if length(args) == 1 && args[1] == "slow" run(test, true)
  else run(test) end
end

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end
