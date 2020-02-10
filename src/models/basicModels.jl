
#Define type AMFMmodel as a vector of type AMFMcomp
mutable struct AMFMmodel
  comps::Vector{AMFMcomp}
end

#Method for type AMFMmodel when called with a time index
function (z::AMFMmodel)(t::Vector{Float64})
  temp = zeros(size(t))
  for k = 1:length(z.comps)
    temp += z.comps[k](t)
  end
  return temp
end

#Construction of type AMFMmodel from a component set
function AMFMmodel(triplets::Vector{Tuple{Function, Function, Real}})
  components = []
  for k = 1:length(triplets)
      push!(components,AMFMcomp(triplets[k]))
  end
  return AMFMmodel(Vector(components))
end

function (z::AMFMmodel)(t::Float64)
  return (z::AMFMmodel)([t::Float64])[1]
end

function (z::AMFMmodel)(t::StepRangeLen)
  return (z::AMFMmodel)(collect(t))
end


#Construct fourierSeries as a type AMFMmodel with a sepecific form
function fourierSeries(T::Real, aₖ::Function, kInds::Array{Int,1}=Vector(-1000:1000))
  components = []
  for k in kInds
    ia(t) = aₖ(k)
    ω(t) = k / T
    push!(components, AMFMcomp(ia, ω, 0))
  end
  return AMFMmodel(components)
end
