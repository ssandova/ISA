const plotly3d_graphTitle = "ISA Plot"

function plotly3d_plot(data::Any, freqUnits::String, buttons::Any)
    layout = plotly3d_configureLayout(freqUnits, buttons)
    Plotly.plot(data, layout)
end

function plotly3d_configureButton(freqUnits::String)
    return (
        args = [(
            scene = plotly3d_configureScene(freqUnits),
            showlegend = true,
            title = plotly3d_graphTitle,
        )],
        label = "3D",
        method = "relayout",
    )
end

function plotly3d_configureLayout(freqUnits::String, buttons:: Any)
    return Layout(
        scene = plotly3d_configureScene(freqUnits),
        title = (text = plotly3d_graphTitle),
        updatemenus = [(
            buttons = buttons,
            showactive = true,
            type = "buttons"
        )]
    )
end

function plotly3d_configureScene(freqUnits::String)
    return (
        aspectmode = "manual",
        aspectratio = (x = 1, y = 1, z = 0.25),
        bgcolor = "rgb(255, 255, 255)",
        camera = plotly3d_configureCamera(),
        dragmode = true,
        xaxis = (
            backgroundcolor = "rgba(0, 0, 128, 0.35)",
            showbackground = true,
            showgrid = false,
            showticklabels = true,
            tickangle = "auto",
            title = (text = "Time", font = (color = 0, size = 10))
        ),
        yaxis = (
            backgroundcolor = "rgba(0, 0, 0, 0.2)",
            showbackground = true,
            showgrid = false,
            showticklabels = true,
            tickangle = "auto",
            title = (text = string("Frequency in ", freqUnits), font = (color = 0, size = 10))
        ),
        zaxis = (
            backgroundcolor = "rgba(140, 60, 250, 1)",
            showbackground = true,
            showgrid = false,
            showticklabels = true,
            tickangle = "auto",
            title = (text = "Real", font = (color = 0, size = 10))
        )
    )
end

function plotly3d_configureCamera()
    return (
        center = (x = 0, y = 0, z = 0),
        eye = (x = -1.25, y = -1.25, z = 1.25),
        projection = (type = "perspective",),
        up = (x = 0, y = 0, z = 1),
    )
end
