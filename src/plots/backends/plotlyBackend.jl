# ==============================================================================
# MARK: - Packages
# ==============================================================================
# The required packages to run the backend.

import JSON # Package requirement: add JSON
import Dates # Already included in standard library
using Base64 # Already included in standard library
using WAV # Package requirement: add WAV
using Dash # Package requirement: add https://github.com/plotly/Dash.jl.git
using Plotly # Package requirement: add https://github.com/plotly/Plotly.jl


# ==============================================================================
# MARK: - Global Outlets
# ==============================================================================
# The current values of the UI displayed on the screen.

plotlyBackend_viewDropDown = nothing # Holds the string value of the view drop down.
plotlyBackend_projectionChecklist = nothing # Holds an array of the checks that are selected.
plotlyBackend_lineWidthSlider = nothing # Holds a number that the slider is currently on.
plotlyBackend_XSlider = nothing # Holds an array of size 2 representing the [min, max] that the slider is currently on.
plotlyBackend_YSlider = nothing # Holds an array of size 2 representing the [min, max] that the slider is currently on.
plotlyBackend_ZSlider = nothing # Holds an array of size 2 representing the [min, max] that the slider is currently on.
plotlyBackend_fileUploader = [nothing, nothing] # Holds the string values of file name and date modified.


# ==============================================================================
# MARK: - Global Variables
# ==============================================================================
# Variables saved in memory so calculations do not need to calculated everytime.

plotlyBackend_dict = nothing # A dictionary of the raw data.
plotlyBackend_data = nothing # An array of Plotly line objects representing the data of the graph.
plotlyBackend_layout = nothing # A dictionary representing the layout of the graph.
plotlyBackend_freqUnits = nothing # A string value representing the freqency units.
plotlyBackend_XExtremities = nothing # An array of size 2 representing the [min, max] x extremities of the data.
plotlyBackend_YExtremities = nothing # An array of size 2 representing the [min, max] y extremities of the data.
plotlyBackend_ZExtremities = nothing # An array of size 2 representing the [min, max] z extremities of the data.
plotlyBackend_ZExtremitiesWithXMinProjection = nothing # An array of size 2 representing the [min, max] z extremities while showing FFT projection on X MIN.
plotlyBackend_ZExtremitiesWithYMinProjection = nothing # An array of size 2 representing the [min, max] z extremities while showing real projection on Y MIN.


# ==============================================================================
# MARK: - Global Constants
# ==============================================================================
# Constants that will remain the same during the lifecycle of the app.

const plotlyBackend_3DGraphTitle = "ISA Plot" # The graph title when 3D mode is toggled.
const plotlyBackend_XYGraphTitle = "Orthographic XY" # The graph title when XY mode is toggled.
const plotlyBackend_XZGraphTitle = "Orthographic XZ" # The graph title when XZ mode is toggled.
const plotlyBackend_YZGraphTitle = "Orthographic YZ" # The graph title when YZ mode is toggled.


# ==============================================================================
# MARK: - Public Functions
# ==============================================================================
# The public functions that outside files should access. The rest of the file
# contains private functions that outside files should not access.

# A function used to run a dash server with default data.
function runPlotlyBackend()
    defaultData = Dict("freqUnits" => "rad/s", "components" => [Dict("x" => [1,2,3], "y" => [4,5,6], "z" => [7,8,9], "colorMap" => ["rgb(255,255,0)", "rgb(0,255,0)", "rgb(255,255,0)"])])
    runPlotlyBackend(defaultData)
end

# A function used to run a dash server with specified data.
function runPlotlyBackend(dict)
    println("Loading Dash Server...")
    plotlyBackend_assignAllGlobalVariablesSafely(dict)
    plotlyBackend_hostDashServer()
end


# ==============================================================================
# MARK: - Dash Server
# ==============================================================================
# Deploys Dash server and matches interactions with the UI to the proper function.

function plotlyBackend_hostDashServer()

    app = dash("ISA app")
    app.layout = plotlyBackend_createHTML()

    callback!(app, callid"viewDropDown.value, lineWidthSlider.value, projectionChecklist.value, xSlider.value, ySlider.value, zSlider.value, uploader.contents, uploader.filename, uploader.last_modified => isaGraph.figure") do viewType, lineWidthSlider, projectionChecklist, xSlider, ySlider, zSlider, fileContents, fileName, fileDateModified
        if (plotlyBackend_viewDropDown != viewType) plotlyBackend_viewDropDownInteracted(viewType) end
        if (plotlyBackend_lineWidthSlider != lineWidthSlider) plotlyBackend_lineWidthSliderInteracted(lineWidthSlider) end
        if (plotlyBackend_projectionChecklist != projectionChecklist) plotlyBackend_projectionCheckListInteracted(projectionChecklist) end
        if (plotlyBackend_XSlider != xSlider) plotlyBackend_xSliderInteracted(xSlider) end
        if (plotlyBackend_YSlider != ySlider) plotlyBackend_ySliderInteracted(ySlider) end
        if (plotlyBackend_ZSlider != zSlider) plotlyBackend_zSliderInteracted(zSlider) end
        if (fileContents != nothing && (plotlyBackend_fileUploader[1] != fileName || plotlyBackend_fileUploader[2] != fileDateModified)) plotlyBackend_uploaderInteracted(fileName, fileDateModified, fileContents) end
        return (data = plotlyBackend_data, layout = plotlyBackend_layout)
    end

    callback!(app, callid"projectionChecklist.value, uploader.contents, uploader.filename, uploader.last_modified => zSliderDiv.children") do projectionChecklist, fileContents, fileName, fileDateModified
        if plotlyBackend_projectionChecklist != projectionChecklist plotlyBackend_projectionCheckListInteracted(projectionChecklist) end
        if (fileContents != nothing && (plotlyBackend_fileUploader[1] != fileName || plotlyBackend_fileUploader[2] != fileDateModified)) plotlyBackend_uploaderInteracted(fileName, fileDateModified, fileContents) end
        zSliderExtremities = plotlyBackend_determineZSliderExtremities()
        return dcc_rangeslider(
            id = "zSlider",
            min = zSliderExtremities[1],
            max = zSliderExtremities[2],
            tooltip = (
                alwaysvisible = true,
                placement = "bottom",
            ),
            step = (zSliderExtremities[2] - zSliderExtremities[1]) / 100,
            value = zSliderExtremities
        )
    end

    callback!(app, callid"playSoundButton.n_clicks => playSoundButtonOutletDiv.children") do numberOfClicks
        if (numberOfClicks != -1) plotlyBackend_playSoundButtonInteracted() end
    end

    callback!(app, callid"saveButton.n_clicks => downloadStatusDiv.children") do numberOfClicks
        if numberOfClicks != -1 return plotlyBackend_saveButtonInteracted() end
    end

    callback!(app, callid"uploader.contents, uploader.filename, uploader.last_modified => uploadFileDiv.children, xSliderDiv.children, ySliderDiv.children") do fileContents, fileName, fileDateModified
        if (fileContents != nothing && (plotlyBackend_fileUploader[1] != fileName || plotlyBackend_fileUploader[2] != fileDateModified)) plotlyBackend_uploaderInteracted(fileName, fileDateModified, fileContents) end
        sleep(1) # Purposely make it 1 second slower to always show loading icon
        xSliderMin = plotlyBackend_XExtremities[1]
        xSliderMax = plotlyBackend_XExtremities[2]
        xSliderStep = (xSliderMax - xSliderMin) / 100
        xSliderValue = [xSliderMin, xSliderMax]
        xSlider = dcc_rangeslider(
            id = "xSlider",
            min = xSliderMin,
            max = xSliderMax,
            tooltip = (
                alwaysvisible = true,
                placement = "bottom",
            ),
            step = xSliderStep,
            value = xSliderValue
        )
        ySliderMin = plotlyBackend_YExtremities[1]
        ySliderMax = plotlyBackend_YExtremities[2]
        ySliderStep = (ySliderMax - ySliderMin) / 100
        ySliderValue = [ySliderMin, ySliderMax]
        ySlider = dcc_rangeslider(
            id = "ySlider",
            min = ySliderMin,
            max = ySliderMax,
            tooltip = (
                alwaysvisible = true,
                placement = "bottom",
            ),
            step = ySliderStep,
            value = ySliderValue
        )
        return ["", xSlider, ySlider]
    end

    println("Deployed. CMD-click this link: http://127.0.0.1:8080")
    run_server(app, "0.0.0.0", 8080)

end


# ==============================================================================
# MARK: - Interactions
# ==============================================================================
# These functions trigger when the corresponding UI element is interacted with.
# In general, these functions update the global outlets with the newest set of
# values, then updates anything else that needs updating.

function plotlyBackend_xSliderInteracted(xSlider)
    global plotlyBackend_XSlider = xSlider
    plotlyBackend_updateLayout()
end

function plotlyBackend_ySliderInteracted(ySlider)
    global plotlyBackend_YSlider = ySlider
    plotlyBackend_updateLayout()
end

function plotlyBackend_zSliderInteracted(zSlider)
    global plotlyBackend_ZSlider = zSlider
    plotlyBackend_updateLayout()
end

function plotlyBackend_lineWidthSliderInteracted(lineWidthSlider)
    global plotlyBackend_lineWidthSlider = lineWidthSlider
    plotlyBackend_updateGlobalDataLineWidth()
end

function plotlyBackend_viewDropDownInteracted(viewType)
    global plotlyBackend_viewDropDown = viewType
    plotlyBackend_updateLayout()
end

function plotlyBackend_projectionCheckListInteracted(projectionChecklist)
    global plotlyBackend_projectionChecklist = projectionChecklist
    plotlyBackend_updateXMinProjectionVisibility() # FFT Projection
    plotlyBackend_updateYMinProjectionVisibility() # Real Projection
    plotlyBackend_updateZMinProjectionVisibility() # STFT Projection
    plotlyBackend_updateLayout()
end

function plotlyBackend_playSoundButtonInteracted()
    println("WAV Button Pressed")
    x = [0:7999;]
    y = cos.(2 * pi * x / 8000)
    y = repeat([0.1, 0.5, 1], size(plotlyBackend_data[1]["y"])[1])
    samplingFq = 200
    fileName = "ISA Sound " * Dates.format(Dates.now(), "mm-dd-yyyy HH.MM.SS")
    filePath = "./downloads/$(fileName).wav"
    wavwrite(y, filePath, Fs=samplingFq)
end

function plotlyBackend_saveButtonInteracted()
    sleep(1) # Purposely make it 1 second slower to show loading icon
    fileName = "ISA Graph " * Dates.format(Dates.now(), "mm-dd-yyyy HH.MM.SS")
    filePath = "./downloads/$(fileName).json"
    if isfile(filePath)
        println("file already exists")
        return "Save failed."
    end
    open(filePath, "w") do f
        write(f, JSON.json(plotlyBackend_dict))
    end
    return "Saved in ISA/downloads"
end

function plotlyBackend_uploaderInteracted(fileName, fileDateModified, fileContents)
    global plotlyBackend_fileUploader = [fileName, fileDateModified]
    description = split(fileContents, ",")[1]
    data = split(fileContents, ",")[2]
    if !occursin("json", description)
        println("Must be a JSON file")
        return
    end
    println("Uploading file...")
    bytes = base64decode(data)
    jsonString = String(bytes)
    try
        dict = JSON.parse(jsonString)
        plotlyBackend_assignAllGlobalVariablesSafely(dict)
    catch
        println("JSON file not formatted correctly.")
        return
    end
end


# ==============================================================================
# MARK: - Updates
# ==============================================================================
# Partially mutates an already assigned global variable. Make sure all global
# variables are already assigned when using.

function plotlyBackend_updateXMinProjectionVisibility()
    plotlyBackend_data[end - 2]["visible"] = plotlyBackend_determineChecklistStatus()["FFT"]
end

function plotlyBackend_updateYMinProjectionVisibility()
    plotlyBackend_data[end - 1]["visible"] = plotlyBackend_determineChecklistStatus()["real"]
end

function plotlyBackend_updateZMinProjectionVisibility()
    plotlyBackend_data[end]["visible"] = plotlyBackend_determineChecklistStatus()["STFT"]
    if plotlyBackend_data[end]["visible"] plotlyBackend_data[end]["z"] .= plotlyBackend_determineZSliderExtremities()[1] end # Make sure its on Z Min
end

function plotlyBackend_updateLayout()
    scene = nothing
    titleText = nothing
    if plotlyBackend_viewDropDown == "XY"
        scene = plotlyBackend_determineXYScene()
        titleText = plotlyBackend_XYGraphTitle
    elseif plotlyBackend_viewDropDown == "XZ"
        scene = plotlyBackend_determineXZScene()
        titleText = plotlyBackend_XZGraphTitle
    elseif plotlyBackend_viewDropDown == "YZ"
        scene = plotlyBackend_determineYZScene()
        titleText = plotlyBackend_YZGraphTitle
    else
        scene = plotlyBackend_determine3DScene()
        titleText = plotlyBackend_3DGraphTitle
    end
    plotlyBackend_layout["scene"] = scene
    plotlyBackend_layout["title"] = titleText
end

function plotlyBackend_updateGlobalDataLineWidth()
    for component in plotlyBackend_data
        component["line"]["width"] = plotlyBackend_lineWidthSlider
    end
end


# ==============================================================================
# MARK: - Assign Globals
# ==============================================================================
# Functions that completely assigns a global variable with a new value.

function plotlyBackend_assignAllGlobalVariablesSafely(dict)
    # Must be done in order
    plotlyBackend_assignGlobalDict(dict)
    plotlyBackend_assignGlobalLineWidth(5)
    plotlyBackend_assignGlobalData(dict, plotlyBackend_lineWidthSlider)
    plotlyBackend_assignGlobalXYZExtremities(plotlyBackend_data)
    plotlyBackend_assignGlobalFreqUnits(dict)
    plotlyBackend_assignGlobalViewDropDown("3D")
    plotlyBackend_forceAssignGlobalXMinProjectionStuff(plotlyBackend_lineWidthSlider) # depends on global data & XYZ Extremities being set
    plotlyBackend_forceAssignGlobalYMinProjectionStuff(plotlyBackend_lineWidthSlider) # depends on global data & XYZ Extremities being set & X Min projection
    plotlyBackend_forceAssignGlobalSliderValues() # depends on global XYZ & XY min projection being set
    plotlyBackend_forceAssignGlobalZMinProjectionStuff(plotlyBackend_lineWidthSlider) # depends on global data & XYZ Extremities & Z Slider being set & XY Min projection
    plotlyBackend_forceAssignGlobalLayout() # depends on global sliders & freqUnits & global view drop down being set
end

# REQUIRED DEPENDENCY: Global XYZ & XYZ min projection must be assigned
function plotlyBackend_forceAssignGlobalSliderValues()
    global plotlyBackend_XSlider = plotlyBackend_XExtremities
    global plotlyBackend_YSlider = plotlyBackend_YExtremities
    global plotlyBackend_ZSlider = plotlyBackend_determineZSliderExtremities()
end

# REQUIRED DEPENDENCY: Global sliders & freqUnits & global view drop down must be assigned
function plotlyBackend_forceAssignGlobalLayout()
    scene = nothing
    titleText = nothing
    if plotlyBackend_viewDropDown == "XY"
        scene = plotlyBackend_determineXYScene()
        titleText = plotlyBackend_XYGraphTitle
    elseif plotlyBackend_viewDropDown == "XZ"
        scene = plotlyBackend_determineXZScene()
        titleText = plotlyBackend_XZGraphTitle
    elseif plotlyBackend_viewDropDown == "YZ"
        scene = plotlyBackend_determineYZScene()
        titleText = plotlyBackend_YZGraphTitle
    else
        scene = plotlyBackend_determine3DScene()
        titleText = plotlyBackend_3DGraphTitle
    end
    global plotlyBackend_layout = Dict(
        "scene" => scene,
        "title" => titleText
    )
end

# REQUIRED DEPENDENCY: Global data & XYZ Extremities must be assigned
function plotlyBackend_forceAssignGlobalXMinProjectionStuff(lineWidth)
    numberOfPointsInProjection = size(plotlyBackend_data[1]["x"])[1]
    x = repeat([plotlyBackend_XExtremities[1]], numberOfPointsInProjection)
    y = LinRange(plotlyBackend_YExtremities[1], plotlyBackend_YExtremities[2], numberOfPointsInProjection)
    z = repeat([0.0], size(x)[1])
    zMin = plotlyBackend_data[1]["z"][1]
    zMax = plotlyBackend_data[1]["z"][1]
    for component in plotlyBackend_data
        for (index, zValue) in enumerate(component["z"])
            z[index] += zValue
            z[index] += zValue
            zMin = min(zMin, min(z[index], zValue))
            zMax = max(zMax, max(z[index], zValue))
        end
    end
    projectionLine = Dict(
        "line" => Dict(
            "color" => "rgb(255,0,0)",
            "width" => lineWidth
        ),
        "mode" => "lines",
        "type" => "scatter3d",
        "opacity" => 1.0,
        "x" => x,
        "y" => y,
        "z" => z,
        "visible" => plotlyBackend_determineChecklistStatus()["FFT"],
        "showlegend" => true
    )
    push!(plotlyBackend_data, projectionLine)
    global plotlyBackend_ZExtremitiesWithXMinProjection = [zMin, zMax]
end

# REQUIRED DEPENDENCY: Global data & XYZ Extremities & X Min Projection must be assigned
function plotlyBackend_forceAssignGlobalYMinProjectionStuff(lineWidth)
    x = plotlyBackend_data[1]["x"]
    y = repeat([plotlyBackend_YExtremities[1]], size(x)[1])
    z = repeat([0.0], size(x)[1])
    zMin = plotlyBackend_data[1]["z"][1]
    zMax = plotlyBackend_data[1]["z"][1]
    for component in plotlyBackend_data[1:end-1] # We can cut of the last element since its just a projection
        for (index, zValue) in enumerate(component["z"])
            z[index] += zValue
            zMin = min(zMin, min(z[index], zValue))
            zMax = max(zMax, max(z[index], zValue))
        end
    end
    projectionLine = Dict(
        "line" => Dict(
            "color" => "rgb(192,192,192)",
            "width" => lineWidth
        ),
        "mode" => "lines",
        "type" => "scatter3d",
        "opacity" => 1.0,
        "x" => x,
        "y" => y,
        "z" => z,
        "visible" => plotlyBackend_determineChecklistStatus()["real"],
        "showlegend" => true
    )
    push!(plotlyBackend_data, projectionLine)
    global plotlyBackend_ZExtremitiesWithYMinProjection = [zMin, zMax]
end

# REQUIRED DEPENDENCY: Global data & XYZ Extremities & XY MIN Projection & Z Slider must be assigned
# If you need to loop through plotlyBackend_data make sure you cut the last 2 components
# because they are just projections on the X MIN and Y MIN axis.
function plotlyBackend_forceAssignGlobalZMinProjectionStuff(lineWidth)
    x = plotlyBackend_data[1]["x"]
    y = LinRange(plotlyBackend_YExtremities[1], plotlyBackend_YExtremities[2], size(x)[1])
    z = repeat([plotlyBackend_determineZSliderExtremities()[1]], size(x)[1])
    projectionLine = Dict(
        "line" => Dict(
            "color" => "rgb(0,255,0)",
            "width" => lineWidth
        ),
        "mode" => "lines",
        "type" => "scatter3d",
        "opacity" => 1.0,
        "x" => x,
        "y" => y,
        "z" => z,
        "visible" => plotlyBackend_determineChecklistStatus()["STFT"],
        "showlegend" => true
    )
    push!(plotlyBackend_data, projectionLine)
end

function plotlyBackend_assignGlobalDict(dict)
    global plotlyBackend_dict = dict
end

function plotlyBackend_assignGlobalLineWidth(value)
    global plotlyBackend_lineWidthSlider = value
end

function plotlyBackend_assignGlobalData(dict, lineWidth)
    data = []
    for component in dict["components"]
        myLine = Dict(
            "line" => Dict(
                "color" => component["colorMap"],
                "width" => lineWidth
            ),
            "mode" => "lines",
            "type" => "scatter3d",
            "opacity" => 1.0,
            "visible" => true,
            "x" => component["x"],
            "y" => component["y"],
            "z" => component["z"],
        )
        push!(data, myLine)
    end
    global plotlyBackend_data = data
end

function plotlyBackend_assignGlobalXYZExtremities(data)
    xMin = data[1]["x"][1]
    yMin = data[1]["y"][1]
    zMin = data[1]["z"][1]
    xMax = data[1]["x"][1]
    yMax = data[1]["y"][1]
    zMax = data[1]["z"][1]
    for line in data
        xMin = min(xMin, minimum(line["x"]))
        yMin = min(yMin, minimum(line["y"]))
        zMin = min(zMin, minimum(line["z"]))
        xMax = max(xMax, maximum(line["x"]))
        yMax = max(yMax, maximum(line["y"]))
        zMax = max(zMax, maximum(line["z"]))
    end
    global plotlyBackend_XExtremities = [xMin, xMax]
    global plotlyBackend_YExtremities = [yMin, yMax]
    global plotlyBackend_ZExtremities = [zMin, zMax]
end

function plotlyBackend_assignGlobalFreqUnits(dict)
    global plotlyBackend_freqUnits = haskey(dict, "freqUnits") ? dict["freqUnits"] : "rad/s"
end

function plotlyBackend_assignGlobalViewDropDown(value)
    global plotlyBackend_viewDropDown = value
end


# ==============================================================================
# MARK: - Determines
# ==============================================================================
# Returns specific values based on the currently set global variables. Make sure
# the global variables are assigned before using.

# Returns a [min, max] extremity that should be assigned to the z slider
function plotlyBackend_determineZSliderExtremities()
    result = [plotlyBackend_ZExtremities[1], plotlyBackend_ZExtremities[2]]
    extraConsideration = []
    checklistStatus = plotlyBackend_determineChecklistStatus()
    if checklistStatus["FFT"] push!(extraConsideration, plotlyBackend_ZExtremitiesWithXMinProjection) end
    if checklistStatus["real"] push!(extraConsideration, plotlyBackend_ZExtremitiesWithYMinProjection) end
    for extremity in extraConsideration
        result[1] = min(result[1], extremity[1])
        result[2] = max(result[2], extremity[2])
    end
    return result
end

# Returns a dictionary that determines whether or not a checkbox in the checklist is checked
function plotlyBackend_determineChecklistStatus()
    checklistStatus = Dict()
    checklistStatus["FFT"] = (plotlyBackend_projectionChecklist != nothing && 1 in plotlyBackend_projectionChecklist)
    checklistStatus["real"] = (plotlyBackend_projectionChecklist != nothing && 2 in plotlyBackend_projectionChecklist)
    checklistStatus["STFT"] = (plotlyBackend_projectionChecklist != nothing && 3 in plotlyBackend_projectionChecklist)
    return checklistStatus
end

function plotlyBackend_determine3DScene()
    return (
        aspectmode = "manual",
        aspectratio = (x = 1, y = 1, z = 0.25),
        bgcolor = "rgb(255, 255, 255)",
        camera = (
            center = (x = 0, y = 0, z = 0),
            eye = (x = -0.5, y = -2.25, z = 1.25),
            projection = (type = "perspective",),
            up = (x = 0, y = 0, z = 1),
        ),
        dragmode = true,
        xaxis = (
            backgroundcolor = "rgba(0, 0, 128, 0.35)",
            range = plotlyBackend_XSlider,
            showbackground = true,
            showgrid = false,
            showticklabels = true,
            tickangle = "auto",
            title = (text = "Time", font = (color = 0, size = 10))
        ),
        yaxis = (
            backgroundcolor = "rgba(0, 0, 0, 0.2)",
            range = plotlyBackend_YSlider,
            showbackground = true,
            showgrid = false,
            showticklabels = true,
            tickangle = "auto",
            title = (text = string("Frequency in ", plotlyBackend_freqUnits), font = (color = 0, size = 10))
        ),
        zaxis = (
            backgroundcolor = "rgba(140, 60, 250, 1)",
            range = plotlyBackend_determineZSliderExtremities(),
            showbackground = true,
            showgrid = false,
            showticklabels = true,
            tickangle = "auto",
            title = (text = "Real", font = (color = 0, size = 10))
        )
    )
end

function plotlyBackend_determineXYScene()
    return (
        aspectmode = "manual",
        aspectratio = (x = 1, y = 1, z = 0.25),
        bgcolor = "rgb(255, 255, 255)",
        camera = (
            center = (x = 0, y = 0, z = 0),
            eye = (x = 0, y = 0, z = 1),
            projection = (type = "orthographic",),
            up = (x = 0, y = 1, z = 0),
        ),
        dragmode = false,
        xaxis = (
            backgroundcolor = "rgba(0, 0, 128, 0.35)",
            range = plotlyBackend_XSlider,
            showbackground = true,
            showgrid = false,
            showticklabels = true,
            tickangle = 0,
            title = (text = "Time", font = (color = 0, size = 10))
        ),
        yaxis = (
            backgroundcolor = "rgba(0, 0, 0, 0.2)",
            range = plotlyBackend_YSlider,
            showbackground = true,
            showgrid = false,
            showticklabels = true,
            tickangle = "auto",
            title = (text = string("Frequency in ", plotlyBackend_freqUnits), font = (color = 0, size = 10))
        ),
        zaxis = (
            backgroundcolor = "rgba(140, 60, 250, 1)",
            range = plotlyBackend_determineZSliderExtremities(),
            showbackground = true,
            showgrid = false,
            showticklabels = false,
            tickangle = "auto",
            title = (text = "",)
        )
    )
end

function plotlyBackend_determineXZScene()
    return (
        aspectmode = "manual",
        aspectratio = (x = 1, y = 1, z = 0.25),
        bgcolor = "rgb(255, 255, 255)",
        camera = (
            center = (x = 0, y = 0, z = 0),
            eye = (x = 0, y = -1, z = 0),
            projection = (type = "orthographic",),
            up = (x = 0, y = 0, z = 1),
        ),
        dragmode = false,
        xaxis = (
            backgroundcolor = "rgba(0, 0, 128, 0.35)",
            range = plotlyBackend_XSlider,
            showbackground = true,
            showgrid = false,
            showticklabels = true,
            tickangle = 0,
            title = (text = "Time", font = (color = 0, size = 10))
        ),
        yaxis = (
            backgroundcolor = "rgba(0, 0, 0, 0.2)",
            range = plotlyBackend_YSlider,
            showbackground = true,
            showgrid = false,
            showticklabels = false,
            tickangle = "auto",
            title = (text = "")
        ),
        zaxis = (
            backgroundcolor = "rgba(140, 60, 250, 1)",
            range = plotlyBackend_determineZSliderExtremities(),
            showbackground = true,
            showgrid = false,
            showticklabels = true,
            tickangle = "auto",
            title = (text = "Real", font = (color = 0, size = 10))
        )
    )
end

function plotlyBackend_determineYZScene()
    return (
        aspectmode = "manual",
        aspectratio = (x = 1, y = 1, z = 0.25),
        bgcolor = "rgb(255, 255, 255)",
        camera = (
            center = (x = 0, y = 0, z = 0),
            eye = (x = 1, y = 0, z = 0),
            projection = (type = "orthographic",),
            up = (x = 0, y = 0, z = 1),
        ),
        dragmode = false,
        xaxis = (
            backgroundcolor = "rgba(0, 0, 128, 0.35)",
            range = plotlyBackend_XSlider,
            showbackground = true,
            showgrid = false,
            showticklabels = false,
            tickangle = "auto",
            title = (text = "")
        ),
        yaxis = (
            backgroundcolor = "rgba(0, 0, 0, 0.2)",
            range = plotlyBackend_YSlider,
            showbackground = true,
            showgrid = false,
            showticklabels = true,
            tickangle = 0,
            title = (text = string("Frequency in ", plotlyBackend_freqUnits), font = (color = 0, size = 10))
        ),
        zaxis = (
            backgroundcolor = "rgba(140, 60, 250, 1)",
            range = plotlyBackend_determineZSliderExtremities(),
            showbackground = true,
            showgrid = false,
            showticklabels = true,
            tickangle = "auto",
            title = (text = "Real", font = (color = 0, size = 10))
        )
    )
end


# ==============================================================================
# MARK: - Dash HMTL
# ==============================================================================
# The HTML the dash server will present.

function plotlyBackend_createHTML()
    return html_div() do
        html_div() do
            html_div(style = (width = "275px", display = "inline-block", marginRight = "20px"),) do
                dcc_dropdown(
                    id = "viewDropDown",
                    options = [
                        (label = "3D", value = "3D"),
                        (label = "2D X & Y (Time and Frequency)", value = "XY"),
                        (label = "2D X & Z (Time and Real)", value = "XZ"),
                        (label = "2D Y & Z (Frequency and Real)", value = "YZ")
                    ],
                    value = "3D",
                    searchable = false,
                    clearable = false
                )
            end,
            html_div(style = (width = "250px", display = "inline-block", transform = "translateY(-20%)", marginRight = "20px")) do
                html_div() do
                    html_div(style = (display = "inline-block", marginRight = "20px", transform = "translateY(-5%)"),) do
                        html_p("Line Width")
                    end,
                    html_div(style = (width = "60%", display = "inline-block"),) do
                        dcc_slider(
                            id = "lineWidthSlider",
                            min = 1,
                            max = 10,
                            step = 1,
                            tooltip = (
                                alwaysvisible = true,
                                placement = "bottom",
                            ),
                            value = plotlyBackend_lineWidthSlider
                        )
                    end
                end
            end,
            html_div(style = (display = "inline-block", transform = "translateY(-75%)"),) do
                dcc_checklist(
                    id = "projectionChecklist",
                    options = [
                        (label = "FFT Projection", value = 1),
                        (label = "Real Projection", value = 2),
                        (label = "STFT Projection", value = 3)
                    ],
                    labelStyle = (display = "inline-block", marginRight = "20px")
                )
            end,
            html_div(style = (display = "inline-block", transform = "translateY(-75%)"),) do
                html_button(
                    id = "playSoundButton",
                    n_clicks = -1,
                    children = ["Play Sound"]
                ),
                html_div(id = "playSoundButtonOutletDiv")
            end
        end,
        dcc_graph(
            id = "isaGraph",
            figure = (
                data = plotlyBackend_data,
                layout = plotlyBackend_layout
            )
        ),
        html_div(style = (textAlign = "center",)) do
            html_div() do
                html_div(style = (display = "inline-block", marginRight = "20px", transform = "translateY(-5%)"),) do
                    html_p("Time Axis Traversal")
                end,
                html_div(id = "xSliderDiv", style = (width = "60%", display = "inline-block"),) do
                    dcc_rangeslider(
                        id = "xSlider",
                        min = plotlyBackend_XExtremities[1],
                        max = plotlyBackend_XExtremities[2],
                        tooltip = (
                            alwaysvisible = true,
                            placement = "bottom",
                        ),
                        step = (plotlyBackend_XExtremities[2] - plotlyBackend_XExtremities[1]) / 100,
                        value = [plotlyBackend_XExtremities[1], plotlyBackend_XExtremities[2]]
                    )
                end
            end,
            html_div() do
                html_div(style = (display = "inline-block", marginRight = "20px", transform = "translateY(-5%)"),) do
                    html_p("Frequency Axis Traversal")
                end,
                html_div(id = "ySliderDiv", style = (width = "60%", display = "inline-block"),) do
                    dcc_rangeslider(
                        id = "ySlider",
                        min = plotlyBackend_YExtremities[1],
                        max = plotlyBackend_YExtremities[2],
                        tooltip = (
                            alwaysvisible = true,
                            placement = "bottom",
                        ),
                        step = (plotlyBackend_YExtremities[2] - plotlyBackend_YExtremities[1]) / 100,
                        value = [plotlyBackend_YExtremities[1], plotlyBackend_YExtremities[2]]
                    )
                end
            end,
            html_div() do
                html_div(style = (display = "inline-block", marginRight = "20px", transform = "translateY(-5%)"),) do
                    html_p("Real Axis Traversal")
                end,
                html_div(id = "zSliderOutterDiv", style = (width = "60%", display = "inline-block"),) do
                    html_div(id = "zSliderDiv") do
                        dcc_rangeslider(
                            id = "zSlider",
                            min = plotlyBackend_ZExtremities[1],
                            max = plotlyBackend_ZExtremities[2],
                            tooltip = (
                                alwaysvisible = true,
                                placement = "bottom",
                            ),
                            step = (plotlyBackend_ZExtremities[2] - plotlyBackend_ZExtremities[1]) / 100,
                            value = [plotlyBackend_ZExtremities[1], plotlyBackend_ZExtremities[2]]
                        )
                    end
                end
            end
        end,
        html_br(),
        html_br(),
        html_div(style = (display = "inline",),) do
            html_div(style = (width = "19%", display = "inline-block", float = "left", textAlign = "center", transform = "translateY(50%)", top = "50%", position = "relative")) do
                html_h3("Save Current Signal"),
                dcc_loading(
                    type = "default",
                    children = [html_div(id = "downloadStatusDiv",)]
                ),
                html_button(
                    id = "saveButton",
                    n_clicks = -1,
                    children = ["Save!"]
                )
            end,
            html_div(style = (width = "80%", display = "inline-block")) do
                html_h3("Visualize a Different Signal"),
                html_p("Instructions: This can take several seconds. Try not to interact with the UI while uploading a file. Upload a correctly formatted JSON file with valid data. Note: the key \'freqUnits\' is optional and is defaulted to \'rad/s\'. See valid file examples in ISA/downloads."),
                dcc_loading(
                    type = "default",
                    children = [html_div(id = "uploadFileDiv",)]
                ),
                dcc_upload(
                    id = "uploader",
                    children = [
                        "Drag a JSON file or click to select"
                    ],
                    style = (
                        width = "100%",
                        height = "60px",
                        lineHeight = "60px",
                        borderWidth = "1px",
                        borderStyle = "dashed",
                        borderRadius = "5px",
                        textAlign = "center",
                    ),
                    # Do not multiple files to be uploaded
                    multiple = false
                )
            end
        end
    end
end
