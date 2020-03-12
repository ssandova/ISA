
#Load colormap
using Colors
if (false)
    include("cubeYF.jl")
else
    include("viridis.jl")
end


#Load specific backend
using LaTeXStrings
include("backends/plotsGRBackend.jl")
include("backends/plotsMakieBackend.jl")


function isaPlot3d(z::AMFMmodel, t::Vector{Float64}; backend="PlotsGR")
    if backend=="Makie"
        isaPlot3d_Makie(z,t)
    else
        isaPlot3d_PlotsGR(z,t)
    end
end


function isaPlot3d(z::AMFMmodel, t::StepRangeLen; backend="PlotsGR")
    if backend=="Makie"
        isaPlot3d_Makie(z,collect(t))
    else
        isaPlot3d_PlotsGR(z,collect(t))
    end
end

#Construction of an isaPlot3d from a component set
function isaPlot3d(S::Array{Tuple{Function,Function,Real},1}, t::Vector{Float64}; backend="PlotsGR")
    if backend=="Makie"
        isaPlot3d_Makie(AMFMmodel(S),t)
    else
        isaPlot3d_PlotsGR(AMFMmodel(S),t)
    end
end
function isaPlot3d(S::Array{Tuple{Function,Function,Real},1}, t::StepRangeLen; backend="PlotsGR")
    if backend=="Makie"
        isaPlot3d_Makie(S,collect(t))
    else
        isaPlot3d_PlotsGR(S,collect(t))
    end
end

#Construction of an isaPlot3d from an AMFMcomp
function isaPlot3d(ψ::AMFMcomp, t::Vector{Float64}; backend="PlotsGR")
    if backend=="Makie"
        isaPlot3d_Makie(AMFMmodel([ψ]), t)
    else
        isaPlot3d_PlotsGR(AMFMmodel([ψ]), t)
    end
end
function isaPlot3d(ψ::AMFMcomp, t::StepRangeLen; backend="PlotsGR")
    if backend=="Makie"
        isaPlot3d_Makie(S,collect(t))
    else
        isaPlot3d_PlotsGR(S,collect(t))
    end
end

#Construction of an isaPlot3d from an canonical triplet
function isaPlot3d(C::Tuple{Function,Function,Real}, t::Vector{Float64}; backend="PlotsGR")
    if backend=="Makie"
        isaPlot3d_Makie(AMFMcomp(C), t)
    else
        isaPlot3d_PlotsGR(AMFMcomp(C), t)
    end
end
function isaPlot3d(C::Tuple{Function,Function,Real}, t::StepRangeLen; backend="PlotsGR")
    if backend=="Makie"
        isaPlot3d_Makie(S,collect(t))
    else
        isaPlot3d_PlotsGR(S,collect(t))
    end
end

#Construction of an isaPlot3d from a numerical component
function isaPlot3d(Ψ::Array{AMFMcompN,1}; backend="PlotsGR")
    if backend=="Makie"
        isaPlot3d_Makie(Ψ)
    else
        isaPlot3d_PlotsGR(Ψ)
    end
end
