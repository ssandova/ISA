# PlotlyBackend.jl

Graphs of the ISA model are shown using the [Plotly](https://plotly.com/julia/) framework in combination with [Dash](https://github.com/plotly/Dash.jl). In order to use `PlotlyBackend.jl` you must add the required packages in your Julia Package Manager. To open the Julia Package Manager by type: `]` in the Julia Terminal. Then add the required packages:

```
julia> ]
pkg> add https://github.com/plotly/Plotly.jl
pkg> add https://github.com/plotly/Dash.jl.git
pkg> add JSON
pkg> add WAV
```

## Contents
* [Public Functions](#PublicFunctions)
* [Shutting Down Server](#ShuttingDownServer)
* [Dictionary Representation](#DictionaryRepresentation)
* [Data Representation](#DataRepresentation)
* [Tutorials & Help](#TutorialsAndHelp)

## <a name="PublicFunctions"/>Public Functions
`runPlotlyBackend()` and `runPlotlyBackend(dict)` are the only two functions that should be accessed outside of the file. `runPlotlyBackend()` will run a Dash server with default data while `runPlotlyBackend(dict)` will run with specific data.

## <a name="ShuttingDownServer"/>Shutting Down Server
When `runPlotlyBackend()` or `runPlotlyBackend(dict)` is called, a Dash Server will run. To stop the dash server, hold CONTROL + C in the terminal.

## <a name="DictionaryRepresentation"/>Dictionary Representation
A dictionary will be used to contain all the information plotlyBackend.jl will need. The dictionary will contain two keys: `components` and `freqUnits`. An example of two 3D lines is shown below:

```json
{
  "freqUnits": "rad/s",
  "components": [
    {
      "colorMap": [
        "rgb(255,255,0)",
        "rgb(0,255,0)",
        "rgb(255,255,0)"
      ],
      "x": [
        1,
        2,
        3
      ],
      "z": [
        7,
        8,
        9
      ],
      "y": [
        4,
        5,
        6
      ]
    },
    {
      "colorMap": [
        "rgb(255,0,0)",
        "rgb(0,0,255)",
        "rgb(255,0,0)"
      ],
      "x": [
        1,
        2,
        3
      ],
      "z": [
        70,
        80,
        90
      ],
      "y": [
        40,
        50,
        60
      ]
    }
  ]
}
```

### Components Key
The `components` key holds an array of dictionaries. The minimum length must be 1. Each component dictionary has four keys: `x`, `y`, `z`, and `colorMap`. Each of these keys holds an array of values representing the points of a 3D line. While the `x`, `y`, and `z` arrays contain float or integer values; the `colorMap` array holds string values. The string is formatted like: "rgb(255,0,0)" representing the RGB color. Please make sure the array lengths of the `x`, `y`, `z`, and `colorMap` are equal. Additionally, if you have multiple components, ensure the `x` arrays are equal throughout the entire data set.

### FreqUnits Key
The `freqUnits` key holds a string value. This key is optional and is not required since it is defaulted to: "rad/s". NOTE: the sole purpose of this key is to display the frequency units label on the y-axis. It does NOT perform any transformations to the data. Please perform these calculations before calling any functions in plotlyBackend.jl.

## <a name="DataRepresentation"/>Data Representation
The graphed data will be represented with an array of dictionaries. Each dictionary represents a line in the 3D graph like so:

```julia
myLine = Dict(
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
data = [myLine] # A data array with one line component
```

### Plotly Graph Objects
Please refer to [Plotly Documentation in Javascript](https://plotly.com/javascript/reference/) for figure references. As of May 2020, Plotly does not have figure references in Julia. Nontheless, all Plotly figures can be represented as Julia dictionaries or tuples.

### Appended Projections
PlotlyBackend.jl will automatically make 3 new line components in addition to the original data set. Hence, the least amount of components in a data set is 4 (1 original & 3 new lines). The projection on the X-MIN axis will be in the third last position of the array. The projection on the Y-MIN axis will be in the second last position of the array. The projection on the Z-MIN axis will be in the last position of the array. Please be careful when looping through the data set. Make sure to do the following if you want to exclude the projection data:

```julia
for component in plotlyBackend_data[1:end-3]
  # do stuff
end
```

## <a name="TutorialsAndHelp"/>Tutorials & Help
If you are someone who is unfamiliar with Plotly or Dash, I would purchase this Udemy course: [Plotly and Dash Tutorials](https://www.udemy.com/course/interactive-python-dashboards-with-plotly-and-dash/). Please note that the Udemy course is in Python, however, it is relatively similar to Julia. See [Plotly Documentation in Javascript](https://plotly.com/javascript/reference/) for Plolty figure references and [Dash in Julia](https://github.com/plotly/Dash.jl) to see how Python Dash is wrapped into Julia code.
