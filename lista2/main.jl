include("./mygraph.jl")
include("./matrixes.jl")
include("./tests.jl")
using TimesDates

function test(n::Int, m::Int, T_max::Float64, pbb::Float64)
	g = make_graph(20)
	ae::Array{Int}, ce::Array{Int} = [], []

	packets::Array{Int} = []
	for i in 1:2	# for symetric & asymetric matrix
		if i == 1 packets = my_symetric_matrix(nv(g), nv(g)); println("\nSymetric matrix:") end
		# else packets = my_asymetric_matrix(nv(g), nv(g)); println("\nAsymetric matrix:") end
	
		ae = a_e(packets, g)

		scale = 10; packets_mbs = 50
		ce = c_e(scale, packets_mbs, ae)

		# a, b, c, r = network_reliability(n, m, T_max, pbb, ce, packets, g)
		# println("Not conn: $a, a bigger: $b, t bigger: $c\nNetwork reliability: $r")

		# jsons for changing matrix, changing c, adding edges
		# if i == 1 different_packet_c_number(1, n, m, T_max, pbb, ce, packets_mbs, packets, g) end
		# if i == 1 different_packet_c_number(2, n, m, T_max, pbb, ce, packets_mbs, packets, g) end
		# if i == 1 different_packet_c_number(3, 100, m, T_max, pbb, ce, packets_mbs, packets, g) end
	end

	print_graph(ae, ce, g)
end

function main(args::Array{String})
	n = 100; m = 1; t_max = 0.005; p = 0.95
	test(n, m, t_max, p)
end

main(ARGS)
