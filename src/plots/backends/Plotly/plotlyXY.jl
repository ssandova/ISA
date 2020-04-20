const plotlyXY_graphTitle = "Orthographic XY"

function plotlyXY_plot(data::Any, freqUnits::String, buttons::Any)
    layout = plotlyXY_configureLayout(freqUnits, buttons)
    Plotly.plot(data, layout)
end

function plotlyXY_configureButton(freqUnits::String)
    return (
        args = [(
            scene = plotlyXY_configureScene(freqUnits),
            showlegend = true,
            title = plotlyXY_graphTitle,
        )],
        label = "2D X & Y",
        method = "relayout",
    )
end

function plotlyXY_configureLayout(freqUnits::String, buttons:: Any)
    return Layout(
        scene = plotlyXY_configureScene(freqUnits),
        title = (text = plotlyXY_graphTitle),
        updatemenus = [(
            buttons = buttons,
            showactive = true,
            type = "buttons"
        )]
    )
end

function plotlyXY_configureScene(freqUnits::String)
    return (
        aspectmode = "manual",
        aspectratio = (x = 1, y = 1, z = 0.25),
        bgcolor = "rgb(255, 255, 255)",
        camera = plotlyXY_configureCamera(),
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
            showticklabels = true,
            tickangle = "auto",
            title = (text = string("Frequency in ", freqUnits), font = (color = 0, size = 10))
        ),
        zaxis = (
            backgroundcolor = "rgba(140, 60, 250, 1)",
            showbackground = true,
            showgrid = false,
            showticklabels = false,
            tickangle = "auto",
            title = (text = "",)
        )
    )
end

function plotlyXY_configureCamera()
    return (
        center = (x = 0, y = 0, z = 0),
        eye = (x = 0, y = 0, z = 1),
        projection = (type = "orthographic",),
        up = (x = 0, y = 1, z = 0),
    )
end
