
#Load colormap
using Colors
if (false)
    include("cubeYF.jl")
else
    include("viridis.jl")
end


#Load specific backend
using LaTeXStrings
if (true)
    include("backends/plotsGRBackend.jl")
else
    include("backends/plotsMakieBackend.jl")
end
function isaPlot3d(z::AMFMmodel,t::StepRangeLen)
     return isaPlot3d(z,collect(t))
end

#Construction of an isaPlot3d from a component set
function isaPlot3d(S::Array{Tuple{Function,Function,Real},1}, t::Vector{Float64})
     return isaPlot3d(AMFMmodel(S),t)
end
function isaPlot3d(S::Array{Tuple{Function,Function,Real},1}, t::StepRangeLen)
     return isaPlot3d(S,collect(t))
end

#Construction of an isaPlot3d from an AMFMcomp
function isaPlot3d(ψ::AMFMcomp, t::Vector{Float64})
     return isaPlot3d(AMFMmodel([ψ]), t)
end
function isaPlot3d(ψ::AMFMcomp, t::StepRangeLen)
    return isaPlot3d(S,collect(t))
end

#Construction of an isaPlot3d from an canonical triplet
function isaPlot3d(C::Tuple{Function,Function,Real}, t::Vector{Float64})
     return isaPlot3d(AMFMcomp(C), t)
end
function isaPlot3d(C::Tuple{Function,Function,Real}, t::StepRangeLen)
    return isaPlot3d(S,collect(t))
end
