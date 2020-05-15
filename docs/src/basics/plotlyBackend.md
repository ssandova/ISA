# PlotlyBackend.jl

Graphs of the ISA model are shown using the [Plotly](https://plotly.com/julia/) framework in combination with [Dash](https://github.com/plotly/Dash.jl). In order to use `PlotlyBackend.jl` the user must add the required packages into your Julia Package Manager. To open the Julia Package Manager by type: `]` in the Julia Terminal. Then add the required packages:

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
* [Code Base Architecture](#CodeBaseArchitecture)

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
The graphed data will be represented with an array of dictionaries. Each dictionary represents a line in the 3D graph as shown below. Please note, there is one surface object in the data set. The Z-MIN projection is appended as the last 3D graph object in the data array (which is indeed a surface object).

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
Please refer to [Plotly Documentation in Javascript](https://plotly.com/javascript/reference/) for figure references. As of May 2020, Plotly does not have figure references in Julia. Nonetheless, all Plotly figures can be represented as Julia dictionaries or tuples.

### Appended Projections
PlotlyBackend.jl will automatically make 3 new line components in addition to the original data set. Hence, the least amount of components in a data set is 4 (1 original & 3 new lines). The projection on the X-MIN axis will be in the third last position of the array. The projection on the Y-MIN axis will be in the second last position of the array. The projection on the Z-MIN axis will be in the last position of the array. Please be careful when looping through the data set. Make sure to do the following if you want to exclude the projection data:

```julia
for component in plotlyBackend_data[1:end-3]
  # do stuff
end
```


## <a name="TutorialsAndHelp"/>Tutorials & Help
If you are unfamiliar with Plotly or Dash, I would purchase this Udemy course: [Plotly and Dash Tutorials](https://www.udemy.com/course/interactive-python-dashboards-with-plotly-and-dash/). Please note that the Udemy course is in Python. However, it is relatively similar to Julia. See [Plotly Documentation in Javascript](https://plotly.com/javascript/reference/) for Plolty figure references and [Dash in Julia](https://github.com/plotly/Dash.jl) to see how Python Dash is wrapped into Julia code.


## <a name="CodeBaseArchitecture"/>Code Base Architecture
Here are the contents for this section:

* [Discussion](#codeDiscussion)
* [Packages](#codePackages)
* [Global Outlets](#codeGlobalOutlets)
* [Global Variables](#codeGlobalVariables)
* [Global Constants](#codeGlobalConstants)
* [Public Functions](#codePublicFunctions)
* [Dash Server](#codeDashServer)
* [Interaction Functions](#codeInteractionFunctions)
* [Update Functions](#codeUpdateFunctions)
* [Assign Globals Functions](#codeAssignGlobalsFunctions)
* [Determine Functions](#codeDetermineFunctions)
* [Dash HTML](#codeDashHTML)


### <a name="codeDiscussion"/>Discussion
There were many challenges and architectural choices that had to be made for this backend. First, the use of Dash.jl. Dash is an extension of Plotly enabling design of the user interface in HTML. The developer also has the power to write custom functions when certain UI components are interacted with. This choice was made because Dash is very mature and allowed for the most customization.

Second, are adaptions to the Julia programming language. Julia has its strengths and weaknesses. But one weakness is Julia's modularization. Everytime the developer wants to split up code in different files, he/she would need to export it as a module. There are no classes in Julia, and the creators of Julia basically encourage developers to use the include approach while reserving the use of modules unless really needed. The include approach is the same as copying and pasting a whole file and drastically reduces compile time. Hence, it was decided to keep the entire backend in one file. Since it is such common practice to use include in Julia, the backend will add the prefix plotlyBackend_ to all variables and functions that should not be called from another file. This also eliminates all possible name collisions that may occur.

Third, the use of global variables. In general, global variables are bad practice However, this choice was made to quicken development speed and improve code efficiency. For example, the plotly backend frequently must know what the X-min of a dataset is (and the data set may contain over a million points). The backend could have recalculated it every time or passed it in as a function parameter multiple times throughout the lifecycle of the application; but it was decided to keep it easy and keep it has a global variable. Also note that Julia's global variables are not necessarily shared throughout the whole application. It is relatively hidden.

Finally, the execution of backend goes something like this: 1) Read a dictionary and assign all global variables accordingly. 2) Create an HTML file based on global variables. 3) Add interaction functions so the UI can change the global variables. 4) Update the UI to match the global variables.


### <a name="codePackages"/>Packages
This is the first part of the backend. We declare packages we need here. A Julia user then must add the packages to their Julia Package Manager before running the program.


### <a name="codeGlobalOutlets"/>Global Outlets
These are global variables that hold the value of the UI components on the screen. It is important to update these outlets to the newest value whenever a user changes the UI. Based on the values stored in the global outlets within the graph layout, data, etc. may change.

### <a name="codeGlobalConstants"/>Global Constants
The constants declared in the file.

### <a name="codePublicFunctions"/>Public Functions
See [Public Functions](#PublicFunctions)


### <a name="codeDashServer"/>Dash Server
The Dash server sets up the UI and assigns each UI component to a [callback](https://dash.plotly.com/basic-callbacks). A callback is triggered when a UI component is changed. The plotly backend uses this to map the trigger to a corresponding interaction function.


### <a name="codeInteractionFunctions"/>Interaction Functions
The interaction functions are called using Dash's [callbacks](https://dash.plotly.com/basic-callbacks). The function name usually corresponds to the name of the UI component attached with "interacted". For example: plotlyBackend_buttonInteracted(). The primary goal of the interaction function is to 1) write the new value to the global outlet and 2) update the global variables so the Dash callback can return the correct object to modify on the screen.


### <a name="codeUpdateFunctions"/>Update Functions
The update functions changes a global variable slightly. It does not rewrite over anything and is usually pretty minimal. These functions are primarily called from [interaction functions](#codeInteractionFunctions) in order to complete their second goal of updating a global variable. Make sure the global variables are set before using.


### <a name="codeAssignGlobalsFunctions"/>Assign Functions
Assigning all the global variables is the first step to run the backend. [Update](#codeUpdateFunctions) and [determine functions](#codeDetermineFunctions) depending on global variables being set. These functions completely rewrite over any global variables and should be used very very seldomly. Functions with global variable dependencies are marked with the prefix `force`. Make sure that the global variable dependencies are set before using these functions.


### <a name="codeDetermineFunctions"/>Determine Functions
Determine functions usually calcuates or returns a value based on the current values of the global variables. It will not alter any global variables but it requires the global variables to be set.


### <a name="codeDashHTML"/>Dash HTML
This portion of the code is the HTML code that displays on the local host. This is actually not written in HTML but is wrapped by Python which is wrapped again by Julia.

