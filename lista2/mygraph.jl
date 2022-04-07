using Random
import Cairo, Fontconfig
using Graphs, GraphPlot

function print_graph(a::Array{Int}, c::Array{Int}, g::SimpleGraph)
	# color cycles
	cycle1 = 6
	colors = [1 for i in 1:cycle1]
	append!(colors, [2 for i in cycle1+1:nv(g)])
	nodecolor = ["palevioletred1", "royalblue1"]
	nodefillc = nodecolor[colors]

	# node labels
	nodelabel = 1:nv(g)
	edgelabel = ["a=$(a[i])\nc=$(c[i])" for i in 1:ne(g)]


	gplot(g, edgelabel=edgelabel, edgelabelc="plum2", edgelabelsize=0.01, nodelabel=nodelabel, nodefillc=nodefillc)
end

# hardcoded egdes for 6 : 14 
function make_edges()
	edges = [(i, i + 1) for i in 1:5]
	append!(edges, [(i, i + 1) for i in 7:19])
	append!(edges, 
	[
		(1, 4),
		(1, 7),
		(1, 9),
		(2, 10),
		(3, 12),
		(4, 14),
		(4, 16),
		(5, 17),
		(6, 19)
	])
	append!(edges, [(1, 6), (7, 20)])

	return edges
end

function make_graph(nodes::Int)
  g =  SimpleGraph(nodes, 0)
  for e in make_edges()
		add_edge!(g, e[1], e[2])
  end

  return g
end
