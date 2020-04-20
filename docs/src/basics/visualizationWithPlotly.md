# Visualization with Plotly

Graphs of the ISA model may be shown using the [Plotly](https://plotly.com/julia/) framework. In order to use Plotly, you must add Plotly to your Julia packages. You can easily add Plotly to your Julia packages with the Julia Package Manager. To open the Julia Package Manager by type: `]` in the Julia Terminal. Then type `add https://github.com/plotly/Plotly.jl` to install the package. You may press backspace after the installation to return back to the Julia terminal.
```
julia> ]
pkg> add https://github.com/plotly/Plotly.jl
```

## Contents
* [Overview](#PlotlyOverview)
* [Parent: plotsPlotlyBackend.jl](#plotsPlotlyBackend.jl)
  * [Child: plotly3d.jl](#plotly3d.jl)
  * [Child: plotlyXY.jl](#plotlyXY.jl)
  * [Child: plotlyXZ.jl](#plotlyXZ.jl)
  * [Child: plotlyYZ.jl](#plotlyYZ.jl)

## <a name="PlotlyOverview"/>Overview
The Plotly framework is utilized in many different langauges. The strongest and most supported language being Python. However, the ISA project will use a Plotly Julia wrapper class. See more at: [Plotly Julia GitHub Repo](https://github.com/plotly/Plotly.jl). Due to this fact, Plotly documentation in Julia is not as good when compared to other langauges. The most similar langauge implementation is Javascript. Hence, if you need to interpret some details of Plotly, try starting here: [Plotly Documentation in Javascript](https://plotly.com/javascript/reference/). Additionally, all Plotly backend files will live in: `src/plots/backend/Plotly`

## <a name="plotsPlotlyBackend.jl"/>plotsPlotlyBackend.jl
This is the main file you should include when you want to utilize the Plotly backend. [`plotsPlotlyBackend.jl`](#plotsPlotlyBackend.jl) is a parent of: [`plotly3d.jl`](#plotly3d.jl), [`plotlyXY.jl`](#plotlyXY.jl), [`plotlyXZ.jl`](#plotlyXZ.jl), and [`plotlyYZ.jl`](#plotlyYZ.jl).

### <a name="plotly3d.jl"/>plotly3d.jl
More documentation to come.

### <a name="plotlyXY.jl"/>plotlyXY.jl
More documentation to come.

### <a name="plotlyXZ.jl"/>plotlyXZ.jl
More documentation to come.

### <a name="plotlyYZ.jl"/>plotlyYZ.jl
More documentation to come.
