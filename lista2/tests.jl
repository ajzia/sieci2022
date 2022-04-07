using JSON

# adding step to the random element of the array (not on the diagonal)
function change_matrix(times::Int, step::Int, matrix::Array{Int})
  n = collect(1:size(matrix, 1))

  for i in 1:times
    n = shuffle(n)
    i = n[1]; j = n[2]
    matrix[i, j] += step
  end
end

# adding 50 * iteration to every element in c
function change_c(iteration::Int, packets_mbs::Int, c::Array{Int})
  for i in 1:length(c)
    c[i] += packets_mbs * iteration
  end
end

# run for different T_max, different p, different 
function different_packet_c_number(funct::Int, n::Int, m::Int, T_max::Float64, pbb::Float64, c::Array{Int}, packets_mbs::Int, pack::Array{Int}, g::SimpleGraph)
  sym_dict = Dict("Tmax" => Dict(), "pbb" => Dict(), "m" => Dict())
  t = ["Tmax", collect(0.0005:0.0001:0.0009)]; ppb = ["pbb", collect(0.89:0.02:0.97)]; size = ["m", collect(1:5)]
  packets = copy(pack)
  add = 0

  for i in 100:100:1000
    if funct == 1 change_matrix(100, 10, packets) # zmiana N
    else
      i::Int = i / 100
      c = copy(c)
      if funct == 2
        change_c(i, packets_mbs, c)
      elseif funct == 3
        add = i
      end
    end
    
    println("CURRENT: $i")

    for var in (t, ppb, size) 
      name = var[1]; sym_dict[name][i] = Dict()

      for j in 1:5
        value = var[2][j]; sym_dict[name][i][value] = [] 
        for k in 1:5
          if var == t x = network_reliability(n, m, value, pbb, c, packets, g, add)[4]
          elseif var == ppb x = network_reliability(n, m, T_max, value, c, packets, g, add)[4]
          else x = network_reliability(n, value, T_max, pbb, c, packets, g, add)[4] end

          push!(sym_dict[name][i][value], x)
        end
        println("end of $j")
      end
    end

    println("END ", i)
  end

  isdir("./json_data") || mkdir("./json_data")
  if funct == 1
    open("./json_data/sym-diff-matrix-n$n.json", "w") do io
      JSON.print(io, sym_dict)
    end
  elseif funct == 2
    open("./json_data/c-diff-matrix-n$n.json", "w") do io
      JSON.print(io, sym_dict)
    end
  else
    open("./json_data/edge-diff-matrix-n$n.json", "w") do io
      JSON.print(io, sym_dict)
    end
  end
end
