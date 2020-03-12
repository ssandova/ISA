using QuadGK

"""
    AMFMcomp(in::Vector{Float64}, out::Vector{Complex{Float64}})
Creates an AMFM component with parameters `a`, `ω`, and `φ`.
    ψ =  a(t) exp[j(∫ω(τ)dt + φ)]

The input `t` must be a vector of Float64 and the out `ψ` will be a vector of
Complex{Float64} the same length as `t`.

```julia
julia> a₀(t)=1; ω₀(t)=1; φ₀ = 0; ψ₀ = AMFMcomp(a₀,ω₀,φ₀)
AMFMcomp(a₀, ω₀, 0)

julia> t = Array(0.0:0.5:1.0); ψ₀(t)
3-element Array{Complex{Float64},1}:
  1.0 + 0.0im
 -1.0 + 1.2246467991473532e-16im
  1.0 - 2.4492935982947064e-16im
```
"""

#Define type AMFMcomp as a struct of IA, IF, and phase reference
struct AMFMcomp
  a::Function
  ω::Function
  φ::Real
end

#Unspecifed phase references are assumed to be zero
AMFMcomp(a, ω) = AMFMcomp(a, ω, 0.0)

#Method for type AMFMcomp when called with a time index
function (ψ::AMFMcomp)(t::Vector{Float64})
  a, ω, φ = ψ.a, ψ.ω, ψ.φ
  A = quadgk.(ω, 0.0, t)
  θ = [ A[i][1] for i in 1:length(t) ]
  a.(t) .* exp.( 1im .* ( θ .+ φ ) )
end

function (ψ::AMFMcomp)(t::Float64)
  return (ψ::AMFMcomp)([t::Float64])[1]
end

function (ψ::AMFMcomp)(t::StepRangeLen)
  return (ψ::AMFMcomp)(collect(t))
end


#Construction of type AMFMcomp from a cannonical triplet
function AMFMcomp(triplet::Tuple{Function, Function, Real})
      return AMFMcomp(triplet[1],triplet[2],triplet[3])
end
