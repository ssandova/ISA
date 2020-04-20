const plotlyYZ_graphTitle = "Orthographic YZ"

function plotlyYZ_plot(data::Any, freqUnits::String, buttons::Any)
    layout = plotlyYZ_configureLayout(freqUnits, buttons)
    Plotly.plot(data, layout)
end

function plotlyYZ_configureButton(freqUnits::String)
    return (
        args = [(
            scene = plotlyYZ_configureScene(freqUnits),
            showlegend = true,
            title = plotlyYZ_graphTitle,
        )],
        label = "2D Y & Z",
        method = "relayout",
    )
end

function plotlyYZ_configureLayout(freqUnits::String, buttons:: Any)
    return Layout(
        scene = plotlyYZ_configureScene(freqUnits),
        title = (text = plotlyYZ_graphTitle),
        updatemenus = [(
            buttons = buttons,
            showactive = true,
            type = "buttons"
        )]
    )
end

function plotlyYZ_configureScene(freqUnits::String)
    return (
        aspectmode = "manual",
        aspectratio = (x = 1, y = 1, z = 0.25),
        bgcolor = "rgb(255, 255, 255)",
        camera = plotlyYZ_configureCamera(),
        dragmode = false,
        xaxis = (
            backgroundcolor = "rgba(0, 0, 128, 0.35)",
            showbackground = true,
            showgrid = false,
            showticklabels = false,
            tickangle = "auto",
            title = (text = "")
        ),
        yaxis = (
            backgroundcolor = "rgba(0, 0, 0, 0.2)",
            showbackground = true,
            showgrid = false,
            showticklabels = true,
            tickangle = 0,
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

function plotlyYZ_configureCamera()
    return (
        center = (x = 0, y = 0, z = 0),
        eye = (x = 1, y = 0, z = 0),
        projection = (type = "orthographic",),
        up = (x = 0, y = 0, z = 1),
    )
end
