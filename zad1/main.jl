include("./utils.jl")
using .Utils

const FRAME_BORDER = "01111110"

function encode(input::IO, output::IO)
  bytes = Vector{UInt8}(undef, 0)
  bits = BitVector(undef, 0)

  while !eof(input)
    bytes = read_bytes(input, 4)
    for byte in bytes
      push!(bits, bytes_to_bits(byte, 8)...)
    end

    crc::BitVector = calculate_crc(bytes)
    for crc_bit in crc
      push!(bits, crc_bit)
    end

    bits_str::String = bits_to_str(bits)
    stuffed::String = replace(bits_str, r"11111" => s"111110")
    write(output, FRAME_BORDER * stuffed * FRAME_BORDER * "\n")
    empty!(bits)
  end
end

function decode(input::IO, output::IO)
  input_str::String = read(input, String)
  input_str = replace(input_str, r"\n" => s"")
  input_str = replace(input_str, r"01111110" => s"-")
  input_str = replace(input_str, r"111110" => s"11111")

  bits = BitVector(undef, 0)
  frames = split(input_str, "-")

  for frame in frames
    if isempty(frame) continue end

    for bit in frame
      push!(bits, parse(Int, bit))
    end
    
    data_bits = bits[1:end-32]
    crc_bits = bits[end-31:end]

    try
      data_bytes = bits_to_bytes(data_bits)
      if crc_bits != calculate_crc(data_bytes)
        throw("Mismatched crc.")
      else 
        for byte in data_bytes
          write(output, byte)
        end
      end
    catch e
      println(e)
    end
    empty!(bits)
  end
end

function main(args::Array{String})
  if length(args) < 3 println("Wrong number of arguments."); return end

  if !(isfile(args[1]) && isfile(args[2])) println("No such file/s."); return
  elseif !(args[3] in ["enc", "dec"]) println("Wrong mode chosen."); return end

  input = open(args[1], "r")
  output = open(args[2], "w")

  if args[3] == "enc" encode(input, output)
  else decode(input, output) end
end

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end