#!/usr/bin/env julia
#=
Common struct
del2z <delta.z@aliyun.com>
=#
module Struct

export Model, Polar
import Base: Complex, +, -, *, /

mutable struct Model end

# Euler's formula in complex area
mutable struct Polar
    r::Real
    # -180 ~ 180
    θ::Integer
    Polar(r::Real, θ::Integer) = new(r, θ % 181)
end

function Polar(z::Complex)
    @assert(!isnan(z) && !isinf(z), "Unbounded complex number.")
    Polar(abs(z), round(Int, angle(z) / π * 180))
end

Base.Complex(z::Polar) = Complex(z.r * cos(z.θ / 180 * π), z.r * sin(z.θ / 180 * π))
Base.show(io::IO, z::Polar) = print(io, z.r, " * exp(", z.Θ, "im)")

end
