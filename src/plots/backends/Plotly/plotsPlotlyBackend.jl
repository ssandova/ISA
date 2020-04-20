# Put Plotly in Packages by:
# Type: ]
# Type: add https://github.com/plotly/Plotly.jl
# Type: backspace

using Plotly
include("plotly3d.jl")
include("plotlyXY.jl")
include("plotlyXZ.jl")
include("plotlyYZ.jl")

function plotlyBackend_plot(z::AMFMmodel, t::Vector{Float64}, freqUnits::String)
    println("backend started")
    data = plotlyBackend_initializeData(z, t, freqUnits)
    buttons = plotlyBackend_configureButtons(freqUnits)
    plotly3d_plot(data, freqUnits, buttons)
end

function plotlyBackend_initializeData(z::AMFMmodel, t::Vector{Float64}, freqUnits::String)
    a_max = 1 #need to finish
    data = [scatter3d()]
    for i in 1:length(z.comps)
        y = -z.comps[i].ω.(t)
        if freqUnits == "Hz" y = y .* (1/(2π)) end
        my3dLine = scatter3d(
            line = line(
                color = ISA.cmap[max.(min.(round.(Int, abs.(z.comps[i].a.(t)) .* 256 / a_max), 256), 1)],
                width = 5
            ),
            mode = "lines",
            opacity = 1.0,
            x = -t,
            y = y,
            z = real.(z.comps[i](t)),
            visible = true
        )
        push!(data, my3dLine)
    end
    return data
end

function plotlyBackend_configureButtons(freqUnits::String)
    return [
        plotly3d_configureButton(freqUnits),
        plotlyXY_configureButton(freqUnits),
        plotlyXZ_configureButton(freqUnits),
        plotlyYZ_configureButton(freqUnits)
    ]
end
