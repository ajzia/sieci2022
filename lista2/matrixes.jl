using Random
using Graphs

function my_symetric_matrix(data_size::Int, nodes::Int)
  rng = MersenneTwister()
  arr = Vector{UInt8}()
  number = nodes * (nodes - 1) / 2
  index = 1
  
  for i in 1:number
    append!(arr, rand(rng, UInt8) % (2 * data_size - 1) + 1)
  end
  
  result::Array{Int8} = zeros(Int8, nodes, nodes)
  
  for i in 1:nodes
    for j in i+1:nodes
      result[i, j] = result[j, i] = arr[index]
      index += 1
    end
  end
  println(result)
  return result
end
  
function my_asymetric_matrix(data_size::Int, nodes::Int)
  rng = MersenneTwister()
  arr = Vector{Int8}()
      
  number = nodes * (nodes - 1)
  index = 1
  
  for i in 1:number
  append!(arr, rand(rng, UInt8) % (2 * data_size - 1) + 1)
  end
 
  result::Array{Int8} = zeros(Int8, nodes, nodes)
  
  for i in 1:nodes
    for j in i+1:nodes
      result[i, j] = arr[index]
      result[j, i] = arr[index + 1]
      index += 2
    end
  end
  
  return result
end

# a
function a_e(packets::Array{Int, 2}, g::SimpleGraph)
  e = collect(edges(g))
  nodes = nv(g)

  max_flow::Array{Int} = zeros(ne(g))

  for edge in 1:ne(g)
    for i in 1:nodes
      for j in 1:nodes
        if i == j continue end
        path = a_star(g, i, j)

        if findall(x -> x == e[edge], path) != []
          max_flow[edge] += packets[i, j]
        end
      end
    end
  end

  return max_flow
end

# c
function c_e(scale::Int, packets_mbs::Int, flow::Array{Int})  
  c::Array{Int} = zeros(length(flow))
  for i in 1:length(flow)
    c[i] = ceil(scale * flow[i] / packets_mbs) * packets_mbs
  end
  
  return c
end

function remove_edges!(ppb::Float64, edges, graph::SimpleGraph)
  for j in edges
    r = rand(Float64, 1)
    if r[1] > ppb
      rem_edge!(graph, j)
    end
  end
end

# imo git
function add_edges!(number::Int,c::Array{Int}, graph::SimpleGraph)
  possible_edges::Array{Edge} = []
  g = complete_graph(20)

  for e in collect(edges(g))
    if e in collect(edges(g)) && e ∉ collect(edges(graph))
      push!(possible_edges, e)
    end
  end
  
  possible_edges = shuffle(possible_edges)
  
  for i in 1:number
    add_edge!(graph, possible_edges[i])
    push!(c, sum(c))
  end

end

# przekazujemy tu n - powtorzenia, !m!, !Tmax!, !ppb!, c(to zmieniamy!), packets(to zmieniamy!), g
function network_reliability(n::Int, m::Int, T_max::Float64, pbb::Float64, c::Array{Int}, packets::Array{Int, 2}, g::SimpleGraph, add::Int)
  s, not_conn, a_bigger, t_bigger = 0, 0, 0, 0
  T = 0

  for i in 1:n
    graph = copy(g)
    if add == 0 remove_edges!(pbb, collect(edges(graph)), graph)
    else add_edges!(add, c, graph) end
  
    if !is_connected(graph) 
      not_conn += 1
      # println("Test $i/$n: $s successes") 
      continue
    end

    a::Array{Int} = a_e(packets, graph)
    
    for i in 1:ne(graph)
      if a[i] >= c[i] / m 
        a_bigger += 1
        break 
      end
      T += a[i] / ((c[i] / m) - a[i])
      if i == ne(graph)
        T *= 1 / sum(packets)
          
        if T != 0 && T < T_max
          s += 1
        else t_bigger += 1 end
      end
    end
    
    # println("Test $i/$n: $s successes")
  end

  return not_conn, a_bigger, t_bigger, (s / n)
end

