import Base.@kwdef
using Random

@enum directions begin
  left
  right
  both
end

@kwdef mutable struct Node
  name::String = ""
  position::Int = -1
  id::Int = position
  idle::Bool = true
  idle_time::Int = -1
  collision::Bool = false
  detected_collisions::Int = 0
  frames::Int = -1
end

@kwdef mutable struct SignalNode
  node::Node = nothing
  collision_packet::Bool = node.collision
  direction::directions
end

function create_node(node_name::String, node_pos::Int, node_idle_time::Int, node_frames::Int)
  return Node(name=node_name, position=node_pos, idle_time=node_idle_time, frames=node_frames)
end

function node_collision(node::Node)
  node.detected_collisions += 1
  node.idle_time = rand(0:(2 ^ min(node.detected_collisions, 10)))
end
