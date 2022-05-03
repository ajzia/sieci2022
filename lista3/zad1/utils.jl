module Utils
  export bits_to_int, bits_to_bytes, bits_to_str
  export bytes_to_bits, bytes_to_str
  export read_bytes
  export calculate_crc

  const UINTS = Union{UInt128, UInt64, UInt32, UInt16, UInt8}

  function calculate_crc(bytes::Vector{UInt8})
    data = bytes_to_str(bytes)
    crc::UInt32 = Base._crc32c(data)
    return bytes_to_bits(crc, 32)
  end

  function bytes_to_str(bytes::Vector{UInt8})
    str::String = ""
    for byte in bytes
      str *= Char(byte)
    end
    return str
  end

  function bits_to_str(bits::BitVector)
    str::String = ""
    for bit in bits
      if bit str *= "1"
      else str *= "0" end
    end
    return str
  end

  function bits_to_int(bits::BitVector)
    result::Int = 0; temp::Int = 1
    for bit in view(bits, length(bits):-1:1)
      result += bit * temp
      temp <<= 1
    end
    return result
  end

  function bits_to_bytes(bits::BitVector)::Vector{UInt8}
    if (length(bits) % 8 != 0) throw("Number of bits not a power of 8") end
    result = Vector{UInt8}(undef, 0)
    bytes_count::Int = fld(length(bits), 8)
    for i in 0:bytes_count-1
      push!(result, UInt8(bits_to_int(bits[8i+1:8(i+1)])))
    end
    return result
  end

  function bytes_to_bits(num::UINTS, padding::Int=0)::BitVector
    return BitVector(digits(num, base=2, pad=padding) |> reverse)
  end

  function read_bytes(input::IO, x::Int)
    bytes = Vector{UInt8}(undef, 0)
    readbytes!(input, bytes, x)
    return bytes
  end

end # module
