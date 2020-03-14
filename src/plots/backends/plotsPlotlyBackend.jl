# Put Plotly in Packages by:
# Type: ]
# Type: add https://github.com/plotly/Plotly.jl
# Type: backspace

using Plotly

# Constants
ASPECT_MODE_MANUAL = "manual"
ASPECT_RATIO_X = 1
ASPECT_RATIO_Y = 1
ASPECT_RATIO_Z = 0.25
BUTTON_TITLE_XY = "2D X & Y"
BUTTON_TITLE_XYZ = "3D"
BUTTON_TITLE_XZ = "2D X & Z"
BUTTON_TITLE_YZ = "2D Y & Z"
CAMERA_CENTER_X_DEFAULT = 0
CAMERA_CENTER_Y_DEFAULT = 0
CAMERA_CENTER_Z_DEFAULT = 0
CAMERA_EYE_MAX = 2.5
CAMERA_EYE_MIN = 0.0
CAMERA_EYE_X_DEFAULT = 1.25
CAMERA_EYE_Y_DEFAULT = 1.25
CAMERA_EYE_Z_DEFAULT = 1.25
CAMERA_TYPE_ORTHOGRPHIC = "orthographic"
CAMERA_TYPE_PERSPECTIVE = "perspective"
CAMERA_UP_X_DEFAULT = 0
CAMERA_UP_Y_DEFAULT = 0
CAMERA_UP_Z_DEFAULT = 1
DEFAULT_FLOAT_VALUE = 0.0
DEFAULT_STRING_VALUE = "Default"
GRAPH_OPACITY = 1
GRAPH_TITLE_XY = "Orthographic XY"
GRAPH_TITLE_XYZ = "ISA Plot"
GRAPH_TITLE_XZ = "Orthographic XZ"
GRAPH_TITLE_YZ = "Orthographic YZ"
GRAY_COLOR = "rgb(200,200,200)"
LIGHT_GRAY_COLOR = "rgb(240,240,240)"
LINE_WIDTH = 4
MENU_TYPE_BUTTONS = "buttons"
PURPLE_COLOR = "rgb(140,60,250)"
RELAYOUT_METHOD = "relayout"
SCATTER_3D_MODE_LINES = "lines"
SHOW_GRAPH_LEGEND = true
XYZ_MODE = "XYZ"
XY_MODE = "XY"
XZ_MODE = "XZ"
YZ_MODE = "YZ"

function isaPlot3d_Plotly(z::AMFMmodel,t::Vector{Float64})
    data = configureData(z, t)
    layout = configureLayout()
    Plotly.plot(data, layout)
end

function configureData(z::AMFMmodel,t::Vector{Float64})
    a_max = 1 #need to finish
    data = [scatter3d()]
    for i in 1:length(z.comps)
        myLine = scatter3d(
            x = -t,
            y = -z.comps[i].ω.(t),
            z = real.(z.comps[i](t)),
            mode = SCATTER_3D_MODE_LINES,
            opacity = GRAPH_OPACITY,
            line = line(
              width = LINE_WIDTH,
              color = ISA.cmap[max.(min.(round.(Int, abs.(z.comps[i].a.(t)) .* 256 / a_max), 256), 1)],
              reversesScale = false
            )
        )
        push!(data, myLine)
    end
    return data
end

function configureLayout()
    myLayout = Layout(
        title = (text = GRAPH_TITLE_XYZ,),
        scene = configureScene(mode = XYZ_MODE),
        updatemenus = [(
            type = MENU_TYPE_BUTTONS,
            showactive = true,
            buttons = [
                configureButton(mode = XYZ_MODE),
                configureButton(mode = XY_MODE),
                configureButton(mode = XZ_MODE),
                configureButton(mode = YZ_MODE),
            ]
        )],
    )
    return myLayout
end

function configureButton(; mode::String)
    buttonTitle = DEFAULT_STRING_VALUE
    graphTitle = DEFAULT_STRING_VALUE
    if mode == XYZ_MODE
        buttonTitle = BUTTON_TITLE_XYZ
        graphTitle = GRAPH_TITLE_XYZ
    elseif mode == XY_MODE
        buttonTitle = BUTTON_TITLE_XY
        graphTitle = GRAPH_TITLE_XY
    elseif mode == XZ_MODE
        buttonTitle = BUTTON_TITLE_XZ
        graphTitle = GRAPH_TITLE_XZ
    elseif mode == YZ_MODE
        buttonTitle = BUTTON_TITLE_YZ
        graphTitle = GRAPH_TITLE_YZ
    end
    return (
        label = buttonTitle,
        method = RELAYOUT_METHOD,
        args = [(
            title = graphTitle,
            showlegend = SHOW_GRAPH_LEGEND,
            scene = configureScene(mode = mode)
        )]
    )
end

function configureScene(; mode::String)
    dragMode = false
    if mode == XYZ_MODE
        dragMode = true
    end
    return (
        dragmode = dragMode,
        bgcolor = LIGHT_GRAY_COLOR,
        aspectmode = ASPECT_MODE_MANUAL,
        aspectratio = configureAspectRatio(),
        camera = configureCamera(mode = mode),
        xaxis = (showbackground = true, backgroundcolor = GRAY_COLOR),
        yaxis = (showbackground = true, backgroundcolor = GRAY_COLOR),
        zaxis = (showbackground = true, backgroundcolor = PURPLE_COLOR),
    )
end

function configureAspectRatio()
    return (
        x = ASPECT_RATIO_X,
        y = ASPECT_RATIO_Y,
        z = ASPECT_RATIO_Z,
    )
end

function configureCamera(; mode::String)
    return (
        eye = configureEye(mode = mode),
        projection = configureProjection(mode = mode),
        center = configureDefaultCenter(),
        up = configureDefaultUp(),
    )
end

function configureProjection(; mode::String)
    type = CAMERA_TYPE_ORTHOGRPHIC
    if mode == XYZ_MODE
        projection = CAMERA_TYPE_PERSPECTIVE
    end
    return Dict(
        "type" => type
    )
end

function configureDefaultUp()
    return (
        x = CAMERA_UP_X_DEFAULT,
        y = CAMERA_UP_Y_DEFAULT,
        z = CAMERA_UP_Z_DEFAULT,
    )
end

function configureDefaultCenter()
    return (
        x = CAMERA_CENTER_X_DEFAULT,
        y = CAMERA_CENTER_Y_DEFAULT,
        z = CAMERA_CENTER_Z_DEFAULT,
    )
end

function configureEye(; mode::String)
    x = DEFAULT_FLOAT_VALUE
    y = DEFAULT_FLOAT_VALUE
    z = DEFAULT_FLOAT_VALUE
    if mode == XYZ_MODE
        x = CAMERA_EYE_X_DEFAULT
        y = CAMERA_EYE_Y_DEFAULT
        z = CAMERA_EYE_Z_DEFAULT
    elseif mode == XY_MODE
        x = CAMERA_EYE_MIN
        y = CAMERA_EYE_MIN
        z = CAMERA_EYE_MAX
    elseif mode == XZ_MODE
        x = CAMERA_EYE_MIN
        y = CAMERA_EYE_MAX
        z = CAMERA_EYE_MIN
    elseif mode == YZ_MODE
        x = CAMERA_EYE_MAX
        y = CAMERA_EYE_MIN
        z = CAMERA_EYE_MIN
    end
    return (
        x = x,
        y = y,
        z = z,
    )
end
