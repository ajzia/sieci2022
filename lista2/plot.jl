using JSON
using Plots, Statistics

# plotly()

function lexicographic_cmp(x::String)
  number_idx = findfirst(isdigit, x)
  str, num = SubString(x, 1, number_idx-1), SubString(x, number_idx, length(x))
  return str, parse(Float64, num)
end

function sort_keys(dict::Dict)
  return sort(collect(keys(dict)), by=lexicographic_cmp)
end

function sort_array(j, m, z1, z2, z3, z4, z5)
  y1 = ["1" "2" "3" "4" "5"]; y2 = ["0.0005" "0.0006" "0.0007" "0.0008" "0.0009"]; y3 = ["0.89" "0.91" "0.93" "0.95" "0.97"]
  y = y3 # hardcoded, must-change!
  x = mean(m[j]); 

  if j == y[1] push!(z1, x)
  elseif j == y[2] push!(z2, x)
  elseif j == y[3] push!(z3, x)
  elseif j == y[4] push!(z4, x)
  else push!(z5, x) end
end

function make_plot(name::String, name1::String, m::Dict, name2::String, tmax::Dict, name3::String, p::Dict)
  if name == "sym-diff" x = (collect(100:100:1000))
  else x = collect(1:10) end
  
  # y = collect(1:5)  # for m
  # y = collect(0.0005:0.0001:0.0009) # for tmax
  y = collect(0.89:0.02:0.97) # for p
  z1, z2, z3, z4, z5 = [], [], [], [], []

  for i in x 
    for j in y
      sort_array("$j", p["$i"], z1, z2, z3, z4, z5) # change 2nd parameter: m/tmax/p
    end
  end

  z = Array{Float64}(undef, 5, length(z1))
  it = 1
  for i in [z1, z2, z3, z4, z5]
    for el in 1:length(i)
      z[it, el] = i[el]
    end
    it += 1
  end

  if name == "c-diff" x_axis = "I-th c iteration"; title = "Incresing c"; 
  elseif name == "edge-diff" x_axis = "Number of added edges"; title = "Adding_edges"
  else x_axis = "Number of changes in the flow matrix"; title = "Increasing values in N" end


  plt = heatmap(x, y, z, 
  xticks=:all, 
  yformatter = :plain, 
  title="$title,  m = 1, Tmax = 0.005", # must change: m = 1, T_max = 0.005, p = 0.95
  margin=15Plots.mm,
  c = cgrad(:dense),
  xlabel="$x_axis",
  ylabel="Probability"
  )

  savefig(plt, "./plots/$name-$name3.png")  # hardcoded, must-change name1/name2/name3
end

function draw_plot(name::String, data_dict::Dict)
  x, y1, y2, y3, y4 = ([], [], [], [], [])

  for i in ("14", "17", "22", "26", "29", "42", "51", "70", "76", "96", "100", "107", "127", "130", "137", "144", "150", "159", "175", "200")
    opt::Int64 = floor(data_dict[i][4])
    if name == "prd"
      a = prd(data_dict[i][1], opt)
      b = prd(data_dict[i][2], opt)
      c = prd(data_dict[i][3], opt)

    elseif name == "k-random"
      a = data_dict[i][1]
      b = data_dict[i][2]
      c = data_dict[i][3]
      d = data_dict[i][4]

      push!(y4, d)
    end
    push!(x, i); push!(y1, a); push!(y2, b); push!(y3, c); 
  end

  plotlyjs()
  isdir("./plots") || mkdir("./plots")
  
  if name == "prd"
    plt = Plots.plot(x, y1, xticks=:all, marker=(:circle,5), yformatter = :plain, title="$name for k_random algorithm", label = "k_random", legend=:outertopright,
      margin=5Plots.mm, xlabel = "number of nodes", ylabel = "prd in %")
    Plots.savefig(plt, "./plots/$name-krand.png")
    Plots.plot()
    l2, l3 = "rnn", "2opt"
  elseif name == "k-random"
    plt = Plots.plot(x, y1, xticks=:all, marker=(:circle,5), yformatter = :plain, title=name, label = "k = 1000", legend=:outertopright)
    l2, l3 = "k = 10000", "k = 100000"
  end 

  plt = Plots.plot!(x, y2, xticks=:all, marker=(:circle,5), yformatter = :plain, title=name, label = l2, legend=:outertopright,
    margin=5Plots.mm, xlabel = "number of nodes", ylabel = "prd in %")
  plt = Plots.plot!(x, y3, xticks=:all, marker=(:circle,5), yformatter = :plain, title=name, label = l3, legend=:outertopright,
    margin=5Plots.mm, xlabel = "number of nodes", ylabel = "prd in %")
  
  if name == "k-random" 
    plt = Plots.plot!(x, y4, xticks=:all, marker=(:circle,5), yformatter = :plain, title=name, label = "k = 1000000", legend=:outertopright, 
    margin=5Plots.mm, xlabel = "number of nodes", ylabel = "path's weight for the best path found for specific k")
  end

  Plots.savefig(plt, "./plots/$name.png")
end

function main()
  for (root, dirs, files) in walkdir("./json_data")
    for file in files
      data_dict = JSON.parsefile(joinpath(root, file); dicttype=Dict, inttype=Int, use_mmap=true)
      make_plot(data_dict["name"][1], "m", data_dict["m"], "tmax", data_dict["Tmax"], "p", data_dict["pbb"])
    end
  end

end

if abspath(PROGRAM_FILE) == @__FILE__
  main()
end
