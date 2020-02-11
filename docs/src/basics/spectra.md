# Instantaneous Spectra

A **component set** `Array{Tuple{Function,Function,Real},1}` maps to an instantaneous spectrum (IS). Visualization for ISs are provided in the ISA module.
```
using ISA
```

## Visualizing and Instantaneous Spectrum
We can define an **AM--FM model** as follows. First, define a **component set**.
```
a₀(t) = exp(-t^2)
ω₀(t) = 2.0
φ₀ = 0.0
𝐶₀ = (a₀,ω₀,φ₀)

a₁(t) = 1.0
ω₁(t) = 10*t
φ₁ = 0.1
𝐶₁ = (a₁,ω₁,φ₁)

a₂(t) = 0.8*cos(2t)
ω₂(t) = 10 + 7.5*sin(t)
φ₂ = π
𝐶₂ = (a₂,ω₂,φ₂)

𝑆 = [𝐶₀,𝐶₁,𝐶₂]
```
Then, pass the **component set** `Array{Tuple{Function,Function,Real},1}` and a time index `Array{Float64,1}` to the function `isaPlot3d()`.
```
isaPlot3d(𝑆, t)
```
