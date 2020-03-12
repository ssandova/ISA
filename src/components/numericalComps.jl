
using DSP #for phase unwrapping

struct AMFMcompN
  a::Vector{Float64}
  ω::Vector{Float64}
  s::Vector{Float64}
  σ::Vector{Float64}
  θ::Vector{Float64}
  t::Vector{Float64}
  fs::Float64
end
