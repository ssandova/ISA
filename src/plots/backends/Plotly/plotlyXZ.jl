const plotlyXZ_graphTitle = "Orthographic XZ"

function plotlyXZ_plot(data::Any, freqUnits::String, buttons::Any)
    layout = plotlyXY_configureLayout(freqUnits, buttons)
    Plotly.plot(data, layout)
end

function plotlyXZ_configureButton(freqUnits::String)
    return (
        args = [(
            scene = plotlyXZ_configureScene(freqUnits),
            showlegend = true,
            title = plotlyXZ_graphTitle,
        )],
        label = "2D X & Z",
        method = "relayout",
    )
end

function plotlyXZ_configureLayout(freqUnits::String, buttons:: Any)
    return Layout(
        scene = plotlyXZ_configureScene(freqUnits),
        title = (text = plotlyXZ_graphTitle),
        updatemenus = [(
            buttons = buttons,
            showactive = true,
            type = "buttons"
        )]
    )
end

function plotlyXZ_configureScene(freqUnits::String)
    return (
        aspectmode = "manual",
        aspectratio = (x = 1, y = 1, z = 0.25),
        bgcolor = "rgb(255, 255, 255)",
        camera = plotlyXZ_configureCamera(),
        dragmode = false,
        xaxis = (
            backgroundcolor = "rgba(0, 0, 128, 0.35)",
            showbackground = true,
            showgrid = false,
            showticklabels = true,
            tickangle = 0,
            title = (text = "Time", font = (color = 0, size = 10))
        ),
        yaxis = (
            backgroundcolor = "rgba(0, 0, 0, 0.2)",
            showbackground = true,
            showgrid = false,
            showticklabels = false,
            tickangle = "auto",
            title = (text = "")
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

function plotlyXZ_configureCamera()
    return (
        center = (x = 0, y = 0, z = 0),
        eye = (x = 0, y = -1, z = 0),
        projection = (type = "orthographic",),
        up = (x = 0, y = 0, z = 1),
    )
end
