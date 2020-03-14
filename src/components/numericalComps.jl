
using DSP #for phase unwrapping

struct AMFMcompN
#References: Sandoval, Steven, and Phillip L. De Leon. "The Instantaneous Spectrum: A General Framework for Time-Frequency Analysis." IEEE Transactions on Signal Processing 66.21 (2018): 5679-5693.
  a::Vector{Float64}
  ω::Vector{Float64}
  s::Vector{Float64}
  σ::Vector{Float64}
  θ::Vector{Float64}
  t::Vector{Float64}
  fs::Float64
end
