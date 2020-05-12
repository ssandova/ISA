
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
include("backends/plotlyBackend.jl")


function isaPlot3d()
    runPlotlyBackend()
end

function isaPlot3d(z::AMFMmodel, t::Vector{Float64}; backend="PlotsGR", FreqUnits="rad/s")
    if backend=="Makie"
        isaPlot3d_Makie(z,t )
    elseif backend=="Plotly"
        dict = Dict()
        components = []
        for i in 1:length(z.comps)
            componentDict = Dict()
            y = -z.comps[i].ω.(t)
            if FreqUnits == "Hz" y = y .* (1/(2π)) end
            colorMap = cmap[max.(min.(round.(Int, abs.(z.comps[i].a.(t)) .* 256 / 1), 256), 1)]
            colorMap = map(color -> "rgb($(red(color)),$(green(color)),$(blue(color)))", colorMap)
            componentDict["x"] = -t .* -1
            componentDict["y"] = y .* -1
            componentDict["z"] = real.(z.comps[i](t))
            componentDict["colorMap"] = colorMap
            push!(components, componentDict)
        end
        dict["components"] = components
        dict["freqUnits"] = FreqUnits
        runPlotlyBackend(dict)
    else
        isaPlot3d_PlotsGR(z,t, FreqUnits=FreqUnits)
    end
end


function isaPlot3d(z::AMFMmodel, t::StepRangeLen; backend="PlotsGR", FreqUnits="rad/s")
    if backend=="Makie"
        isaPlot3d_Makie(z,collect(t)  )
    elseif backend=="Plotly"
        runPlotlyBackend() # use runPlotlyBackend(dict) to specify data
    else
        isaPlot3d_PlotsGR(z,collect(t), FreqUnits=FreqUnits)
    end
end

#Construction of an isaPlot3d from a component set
function isaPlot3d(S::Array{Tuple{Function,Function,Real},1}, t::Vector{Float64}; backend="PlotsGR", FreqUnits="rad/s")
    if backend=="Makie"
        isaPlot3d_Makie(AMFMmodel(S),t  )
    elseif backend=="Plotly"
        runPlotlyBackend() # use runPlotlyBackend(dict) to specify data
    else
        isaPlot3d_PlotsGR(AMFMmodel(S),t, FreqUnits=FreqUnits)
    end
end
function isaPlot3d(S::Array{Tuple{Function,Function,Real},1}, t::StepRangeLen; backend="PlotsGR", FreqUnits="rad/s")
    if backend=="Makie"
        isaPlot3d_Makie(AMFMmodel(S),collect(t)  )
    elseif backend=="Plotly"
        runPlotlyBackend() # use runPlotlyBackend(dict) to specify data
    else
        isaPlot3d_PlotsGR(AMFMmodel(S),collect(t), FreqUnits=FreqUnits)
    end
end

#Construction of an isaPlot3d from an AMFMcomp
function isaPlot3d(ψ::AMFMcomp, t::Vector{Float64}; backend="PlotsGR", FreqUnits="rad/s")
    if backend=="Makie"
        isaPlot3d_Makie(AMFMmodel([ψ]), t )
    elseif backend=="Plotly"
        runPlotlyBackend() # use runPlotlyBackend(dict) to specify data
    else
        isaPlot3d_PlotsGR(AMFMmodel([ψ]), t, FreqUnits=FreqUnits)
    end
end
function isaPlot3d(ψ::AMFMcomp, t::StepRangeLen; backend="PlotsGR", FreqUnits="rad/s")
    if backend=="Makie"
        isaPlot3d_Makie(AMFMmodel([ψ]),collect(t)  )
    elseif backend=="Plotly"
        runPlotlyBackend() # use runPlotlyBackend(dict) to specify data )
    else
        isaPlot3d_PlotsGR(AMFMmodel([ψ]),collect(t), FreqUnits=FreqUnits)
    end
end

#Construction of an isaPlot3d from an canonical triplet
function isaPlot3d(C::Tuple{Function,Function,Real}, t::Vector{Float64}; backend="PlotsGR", FreqUnits="rad/s")
    if backend=="Makie"
        isaPlot3d_Makie(AMFMmodel([AMFMcomp(C)]), t  )
    elseif backend=="Plotly"
        runPlotlyBackend() # use runPlotlyBackend(dict) to specify data
    else
        isaPlot3d_PlotsGR(AMFMmodel([AMFMcomp(C)]), t, FreqUnits=FreqUnits)
    end
end
function isaPlot3d(C::Tuple{Function,Function,Real}, t::StepRangeLen; backend="PlotsGR", FreqUnits="rad/s")
    if backend=="Makie"
        isaPlot3d_Makie(AMFMmodel([AMFMcomp(C)]),collect(t)  )
    elseif backend=="Plotly"
        runPlotlyBackend() # use runPlotlyBackend(dict) to specify data
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
