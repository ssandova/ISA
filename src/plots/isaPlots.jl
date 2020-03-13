
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




function isaPlot3d(z::AMFMmodel, t::Vector{Float64}; backend="PlotsGR", FreqUnits="rad/s")
    if backend=="Makie"
        isaPlot3d_Makie(z,t )
    else
        isaPlot3d_PlotsGR(z,t, FreqUnits=FreqUnits)
    end
end


function isaPlot3d(z::AMFMmodel, t::StepRangeLen; backend="PlotsGR", FreqUnits="rad/s")
    if backend=="Makie"
        isaPlot3d_Makie(z,collect(t)  )
    else
        isaPlot3d_PlotsGR(z,collect(t), FreqUnits=FreqUnits)
    end
end

#Construction of an isaPlot3d from a component set
function isaPlot3d(S::Array{Tuple{Function,Function,Real},1}, t::Vector{Float64}; backend="PlotsGR", FreqUnits="rad/s")
    if backend=="Makie"
        isaPlot3d_Makie(AMFMmodel(S),t  )
    else
        isaPlot3d_PlotsGR(AMFMmodel(S),t, FreqUnits=FreqUnits)
    end
end
function isaPlot3d(S::Array{Tuple{Function,Function,Real},1}, t::StepRangeLen; backend="PlotsGR", FreqUnits="rad/s")
    if backend=="Makie"
        isaPlot3d_Makie(AMFMmodel(S),collect(t)  )
    else
        isaPlot3d_PlotsGR(AMFMmodel(S),collect(t), FreqUnits=FreqUnits)
    end
end

#Construction of an isaPlot3d from an AMFMcomp
function isaPlot3d(ψ::AMFMcomp, t::Vector{Float64}; backend="PlotsGR", FreqUnits="rad/s")
    if backend=="Makie"
        isaPlot3d_Makie(AMFMmodel([ψ]), t )
    else
        isaPlot3d_PlotsGR(AMFMmodel([ψ]), t, FreqUnits=FreqUnits)
    end
end
function isaPlot3d(ψ::AMFMcomp, t::StepRangeLen; backend="PlotsGR", FreqUnits="rad/s")
    if backend=="Makie"
        isaPlot3d_Makie(AMFMmodel([ψ]),collect(t)  )
    else
        isaPlot3d_PlotsGR(AMFMmodel([ψ]),collect(t), FreqUnits=FreqUnits)
    end
end

#Construction of an isaPlot3d from an canonical triplet
function isaPlot3d(C::Tuple{Function,Function,Real}, t::Vector{Float64}; backend="PlotsGR", FreqUnits="rad/s")
    if backend=="Makie"
        isaPlot3d_Makie(AMFMmodel([AMFMcomp(C)]), t  )
    else
        isaPlot3d_PlotsGR(AMFMmodel([AMFMcomp(C)]), t, FreqUnits=FreqUnits)
    end
end
function isaPlot3d(C::Tuple{Function,Function,Real}, t::StepRangeLen; backend="PlotsGR", FreqUnits="rad/s")
    if backend=="Makie"
        isaPlot3d_Makie(AMFMmodel([AMFMcomp(C)]),collect(t)  )
    else
        isaPlot3d_PlotsGR(AMFMmodel([AMFMcomp(C)]),collect(t), FreqUnits=FreqUnits)
    end
end






#Construction of an isaPlot3d from a numerical component
function isaPlot3d(𝚿ₖ::Array{AMFMcompN,1}; backend="PlotsGR")
    if backend=="Makie"
        isaPlot3d_Makie(𝚿ₖ)
    else
        isaPlot3d_PlotsGR(𝚿ₖ)
    end
end
function isaPlot3d(𝚿::AMFMcompN; backend="PlotsGR", FreqUnits="rad/s")
    if backend=="Makie"
        isaPlot3d_Makie([𝚿])
    else
        isaPlot3d_PlotsGR([𝚿])
    end
end
function isaPlot3d(Ψ::Vector{ComplexF64}, t::Vector{Float64}; backend="PlotsGR", FreqUnits="rad/s")
    if backend=="Makie"
        isaPlot3d_Makie([AMFMdemod(Ψ,t)])
    else
        isaPlot3d_PlotsGR([AMFMdemod(Ψ,t)])
    end
end
function isaPlot3d(Ψ::Vector{ComplexF64}, t::StepRangeLen; backend="PlotsGR", FreqUnits="rad/s")
    if backend=="Makie"
        isaPlot3d_Makie([AMFMdemod(Ψ,collect(t))])
    else
        isaPlot3d_PlotsGR([AMFMdemod(Ψ,collect(t))],)
    end
end
