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
plotlyBackend_XSliderPushable = nothing # Holds [1] if checked
plotlyBackend_YSliderPushable = nothing # Holds [1] if checked
plotlyBackend_ZSliderPushable = nothing # Holds [1] if checked
plotlyBackend_fileUploader = Dict("fileName" => nothing, "dateModified" => nothing) # Holds a dictionary with the keys: fileName and dateModified


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
plotlyBackend_soundData = nothing # A dictionary containing the key: "y" and "samplingFq" to create WAV files.


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
        if (fileContents != nothing && (plotlyBackend_fileUploader["fileName"] != fileName || plotlyBackend_fileUploader["dateModified"] != fileDateModified)) plotlyBackend_uploaderInteracted(fileName, fileDateModified, fileContents) end
        return (data = plotlyBackend_data, layout = plotlyBackend_layout)
    end

    callback!(app, callid"zSliderPushable.value, projectionChecklist.value, uploader.contents, uploader.filename, uploader.last_modified => zSliderDiv.children") do zSliderPushable, projectionChecklist, fileContents, fileName, fileDateModified
        zPushData = nothing
        if (plotlyBackend_ZSliderPushable != zSliderPushable)
            plotlyBackend_ZSliderPushableInteracted(zSliderPushable)
            zPushData = (plotlyBackend_ZSliderPushable == [1])
        end
        if plotlyBackend_projectionChecklist != projectionChecklist plotlyBackend_projectionCheckListInteracted(projectionChecklist) end
        if (fileContents != nothing && (plotlyBackend_fileUploader["fileName"] != fileName || plotlyBackend_fileUploader["dateModified"] != fileDateModified)) plotlyBackend_uploaderInteracted(fileName, fileDateModified, fileContents) end
        return plotlyBackend_determineZSliderDashComponent(zPushData)
    end

    callback!(app, callid"downloadSoundButton.n_clicks => downloadSoundButtonOutletDiv.children") do numberOfClicks
        if (numberOfClicks != -1) plotlyBackend_downloadSoundButtonInteracted() end
    end

    callback!(app, callid"saveButton.n_clicks => downloadStatusDiv.children") do numberOfClicks
        if numberOfClicks != -1 return plotlyBackend_saveButtonInteracted() end
    end

    callback!(app, callid"xSliderPushable.value, ySliderPushable.value, uploader.contents, uploader.filename, uploader.last_modified => uploadFileDiv.children, xSliderDiv.children, ySliderDiv.children") do xSliderPushable, ySliderPushable, fileContents, fileName, fileDateModified
        if (plotlyBackend_XSliderPushable != xSliderPushable) plotlyBackend_XSliderPushableInteracted(xSliderPushable) end
        if (plotlyBackend_YSliderPushable != ySliderPushable) plotlyBackend_YSliderPushableInteracted(ySliderPushable) end
        xPushData = (plotlyBackend_XSliderPushable == [1])
        yPushData = (plotlyBackend_YSliderPushable == [1])
        if (fileContents != nothing && (plotlyBackend_fileUploader["fileName"] != fileName || plotlyBackend_fileUploader["dateModified"] != fileDateModified))
            plotlyBackend_uploaderInteracted(fileName, fileDateModified, fileContents)
            sleep(1) # Purposely make it 1 second slower to always show loading icon
            xPushData = nothing
            yPushData = nothing
        end
        return ["", plotlyBackend_determineXSliderDashComponent(xPushData), plotlyBackend_determineYSliderDashComponent(yPushData)]
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
    plotlyBackend_updateXMinProjectionLocation()
    plotlyBackend_updateLayout()
end

function plotlyBackend_ySliderInteracted(ySlider)
    global plotlyBackend_YSlider = ySlider
    plotlyBackend_updateYMinProjectionLocation()
    plotlyBackend_updateLayout()
end

function plotlyBackend_zSliderInteracted(zSlider)
    global plotlyBackend_ZSlider = zSlider
    plotlyBackend_updateZMinProjectionLocation()
    plotlyBackend_updateLayout()
end

function plotlyBackend_XSliderPushableInteracted(xSliderPushable)
    global plotlyBackend_XSliderPushable = xSliderPushable
end

function plotlyBackend_YSliderPushableInteracted(ySliderPushable)
    global plotlyBackend_YSliderPushable = ySliderPushable
end


function plotlyBackend_ZSliderPushableInteracted(zSliderPushable)
    global plotlyBackend_ZSliderPushable = zSliderPushable
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
    plotlyBackend_updateXMinProjectionLocation()
    plotlyBackend_updateYMinProjectionLocation()
    plotlyBackend_updateZMinProjectionLocation()
    plotlyBackend_updateLayout()
end

function plotlyBackend_downloadSoundButtonInteracted()
    println("WAV Button Pressed")
    values = plotlyBackend_data[end - 2]["z"] # Get the projection on the X MIN axis's z values
    maxAbsoluteValue = max(abs(plotlyBackend_ZExtremitiesWithXMinProjection[1]), abs(plotlyBackend_ZExtremitiesWithXMinProjection[2]))
    y = map(value -> (value / maxAbsoluteValue), values) # Formula: y = y divided by max(abs(Y))
    samplingFq = trunc(Int, float(size(plotlyBackend_data[end - 2]["z"])[1]) / (plotlyBackend_XExtremities[2] - plotlyBackend_XExtremities[1]))
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
    global plotlyBackend_fileUploader = Dict("fileName" => fileName, "dateModified" => fileDateModified)
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

function plotlyBackend_updateXMinProjectionLocation()
    if plotlyBackend_data[end - 2]["visible"] && plotlyBackend_data[end - 2]["x"][1] != plotlyBackend_XSlider[1]
        plotlyBackend_data[end - 2]["x"] .= plotlyBackend_XSlider[1]
    end
end

function plotlyBackend_updateYMinProjectionLocation()
    if plotlyBackend_data[end - 1]["visible"] && plotlyBackend_data[end - 1]["y"][1] != plotlyBackend_YSlider[1]
        plotlyBackend_data[end - 1]["y"] .= plotlyBackend_YSlider[1]
    end
end

function plotlyBackend_updateZMinProjectionLocation()
    if plotlyBackend_data[end]["visible"] && plotlyBackend_data[end]["z"][1][1] != plotlyBackend_ZSlider[1]
        onePercentBuffer = float(plotlyBackend_ZSlider[2] + plotlyBackend_ZSlider[1]) / float(100) # Sometimes if we put the plane exactly on Z-MIN, it gets hidden
        for dimension in plotlyBackend_data[end]["z"]
            dimension .= (plotlyBackend_ZSlider[1] + abs(onePercentBuffer))
        end
    end
end

function plotlyBackend_updateXMinProjectionVisibility()
    plotlyBackend_data[end - 2]["visible"] = plotlyBackend_determineChecklistStatus()["FFT"]
end

function plotlyBackend_updateYMinProjectionVisibility()
    plotlyBackend_data[end - 1]["visible"] = plotlyBackend_determineChecklistStatus()["real"]
end

function plotlyBackend_updateZMinProjectionVisibility()
    plotlyBackend_data[end]["visible"] = plotlyBackend_determineChecklistStatus()["STFT"]
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
    for component in plotlyBackend_data[1:end-1] # Make sure not to mess with Z-projection plane
        component["line"]["width"] = plotlyBackend_lineWidthSlider
    end
end


# ==============================================================================
# MARK: - Assign Globals
# ==============================================================================
# Functions that completely assigns a global variable with a new value. Note that
# force assign functions have dependencies, so please be careful when using them.

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
    plotlyBackend_forceAssignSoundData() # depends on global data & XYZ Extremities being set & XYZ Min projection
    plotlyBackend_forceAssignGlobalLayout() # depends on global sliders & freqUnits & global view drop down being set
end

# REQUIRED DEPENDENCY: Global data & XYZ MIN Projection's extremities must be set
function plotlyBackend_forceAssignSoundData()
    values = plotlyBackend_data[end - 2]["z"] # Get the projection on the X MIN axis's z values
    maxAbsoluteValue = max(abs(plotlyBackend_ZExtremitiesWithXMinProjection[1]), abs(plotlyBackend_ZExtremitiesWithXMinProjection[2]))
    y = map(value -> (value / maxAbsoluteValue), values) # Formula: y = y divided by max(abs(Y))
    samplingFq = trunc(Int, float(size(plotlyBackend_data[end - 2]["z"])[1]) / (plotlyBackend_XExtremities[2] - plotlyBackend_XExtremities[1]))
    global plotlyBackend_soundData = Dict("y" => y, "samplingFq" => samplingFq)
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
# because they are just projections on the X MIN and Y MIN axis. This projection
# is has O(N^2) data points so make sure it is reasonable in size or the UI will freeze
function plotlyBackend_forceAssignGlobalZMinProjectionStuff(lineWidth)
    sizeOfProjection = 64
    x = LinRange(plotlyBackend_XExtremities[1], plotlyBackend_XExtremities[2], sizeOfProjection) # must be length of z[1]
    y = LinRange(plotlyBackend_YExtremities[1], plotlyBackend_YExtremities[2], sizeOfProjection) # must be length of z
    z = [repeat([plotlyBackend_ZExtremities[1]], size(x)[1]) for _ in 1:size(y)[1]] # A 2D array of size: length(y) by length(x)
    minIntensity = 1.0
    maxIntensity = 0.0
    intensities = [LinRange(0.0, 1.0, size(x)[1]) for _ in 1:size(z)[1]] # A 2D array that correlatates to each color a square is
    projectionPlane = Dict(
        "type" => "surface",
        "opacity" => 1.0,
        "cmax" => maxIntensity,
        "cmin" => minIntensity,
        "showlegend" => false,
        "showscale" => false,
        "surfacecolor" => intensities,
        "colorscale" => "Viridis",
        "x" => x,
        "y" => y,
        "z" => z,
        "visible" => plotlyBackend_determineChecklistStatus()["STFT"],
        "showlegend" => false
    )
    push!(plotlyBackend_data, projectionPlane)
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
            "x" => Float64.(component["x"]),
            "y" => Float64.(component["y"]),
            "z" => Float64.(component["z"]),
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

function plotlyBackend_determineIfSignalIsAudiable()
    # https://discourse.julialang.org/t/how-to-play-an-audio-in-julia/31881
    lengthInSeconds = float(size(plotlyBackend_soundData["y"])[1]) / float(plotlyBackend_soundData["samplingFq"])
    if lengthInSeconds < 0.5 return false end
    if plotlyBackend_soundData["samplingFq"] < 4000 || plotlyBackend_soundData["samplingFq"] > 50000 return false end
    return true
end

function plotlyBackend_determineXSliderDashComponent(pushData = nothing)
    dcc_rangeslider(
        id = "xSlider",
        min = plotlyBackend_XExtremities[1],
        max = plotlyBackend_XExtremities[2],
        tooltip = (
            alwaysvisible = true,
            placement = "bottom",
        ),
        pushable = (pushData == true) ? (plotlyBackend_XSlider[2] - plotlyBackend_XSlider[1]) : false,
        step = (plotlyBackend_XExtremities[2] - plotlyBackend_XExtremities[1]) / 100,
        value = (pushData == nothing) ? [plotlyBackend_XExtremities[1], plotlyBackend_XExtremities[2]] : [plotlyBackend_XSlider[1], plotlyBackend_XSlider[2]]
    )
end

function plotlyBackend_determineYSliderDashComponent(pushData = nothing)
    dcc_rangeslider(
        id = "ySlider",
        min = plotlyBackend_YExtremities[1],
        max = plotlyBackend_YExtremities[2],
        tooltip = (
            alwaysvisible = true,
            placement = "bottom",
        ),
        pushable = (pushData == true) ? (plotlyBackend_YSlider[2] - plotlyBackend_YSlider[1]) : false,
        step = (plotlyBackend_YExtremities[2] - plotlyBackend_YExtremities[1]) / 100,
        value = (pushData == nothing) ? [plotlyBackend_YExtremities[1], plotlyBackend_YExtremities[2]] : [plotlyBackend_YSlider[1], plotlyBackend_YSlider[2]]
    )
end

function plotlyBackend_determineZSliderDashComponent(pushData = nothing)
    zSliderExtremities = plotlyBackend_determineZSliderExtremities()
    return dcc_rangeslider(
        id = "zSlider",
        min = zSliderExtremities[1],
        max = zSliderExtremities[2],
        tooltip = (
            alwaysvisible = true,
            placement = "bottom",
        ),
        pushable = (pushData == true) ? (plotlyBackend_ZSlider[2] - plotlyBackend_ZSlider[1]) : false,
        step = (zSliderExtremities[2] - zSliderExtremities[1]) / 100,
        value = (pushData == nothing) ? zSliderExtremities : [plotlyBackend_ZSlider[1], plotlyBackend_ZSlider[2]]
    )
end

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
            range = plotlyBackend_ZSlider,
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
            range = plotlyBackend_ZSlider,
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
            range = plotlyBackend_ZSlider,
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
            range = plotlyBackend_ZSlider,
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
                    id = "downloadSoundButton",
                    n_clicks = -1,
                    children = ["Download Sound"],
                    disabled = !plotlyBackend_determineIfSignalIsAudiable()
                ),
                html_div(id = "downloadSoundButtonOutletDiv")
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
                html_div(id = "xSliderDiv", style = (width = "50%", display = "inline-block", marginRight = "20px"),) do
                    plotlyBackend_determineXSliderDashComponent()
                end,
                html_div(id = "xSliderPushableDiv", style = (width = "100px", display = "inline-block", transform = "translateY(-10%)"),) do
                    dcc_checklist(
                        id = "xSliderPushable",
                        options = [(label = "Push Mode", value = 1)],
                    )
                end
            end,
            html_div() do
                html_div(style = (display = "inline-block", marginRight = "20px", transform = "translateY(-5%)"),) do
                    html_p("Frequency Axis Traversal")
                end,
                html_div(id = "ySliderDiv", style = (width = "50%", marginRight = "20px", display = "inline-block"),) do
                    plotlyBackend_determineYSliderDashComponent()
                end,
                html_div(id = "ySliderPushableDiv", style = (width = "100px", display = "inline-block", transform = "translateY(-10%)"),) do
                    dcc_checklist(
                        id = "ySliderPushable",
                        options = [(label = "Push Mode", value = 1)],
                    )
                end
            end,
            html_div() do
                html_div(style = (display = "inline-block", marginRight = "20px", transform = "translateY(-5%)"),) do
                    html_p("Real Axis Traversal")
                end,
                html_div(id = "zSliderOutterDiv", style = (width = "50%", marginRight = "20px", display = "inline-block"),) do
                    html_div(id = "zSliderDiv") do
                        plotlyBackend_determineZSliderDashComponent()
                    end
                end,
                html_div(id = "zSliderPushableDiv", style = (width = "100px", display = "inline-block", transform = "translateY(-10%)"),) do
                    dcc_checklist(
                        id = "zSliderPushable",
                        options = [(label = "Push Mode", value = 1)],
                    )
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
                html_p("Instructions: This can take several seconds. Try not to interact with the UI while uploading a file. Seldomly, the uploader will have troubles with layout. If this happens, just toggle the projection buttons and the layout should correct itself. If there are further issues, please reupload until correct. Make sure to upload a correctly formatted JSON file with valid data. Note: the key \'freqUnits\' is optional and is defaulted to \'rad/s\'. See valid file examples in ISA/downloads."),
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
