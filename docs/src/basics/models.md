# AM--FM Models

An **AM--FM model** is a set of superimposed **AM--FM components**.

## Defining an AM--FM Model

For example, we can define a **AM--FM model** as follows. First, define a **component set**.
```julia codeSnippet
a₀(t) = exp(-t^2)
ω₀(t) = 2.0
φ₀ = 0.0
𝐶₀ = (a₀,ω₀,φ₀)

a₁(t) = 1.0
ω₁(t) = 10*t
φ₁ = 0.1
𝐶₁ = Tuple([a₁,ω₁,φ₁])

a₂(t) = 0.8*cos(2t)
ω₂(t) = 10 + 7.5*sin(t)
φ₂ = π
𝐶₂ = Tuple([a₂,ω₂,φ₂])

𝑆 = [𝐶₀,𝐶₁,𝐶₂]
```
Then, define an **AM--FM model** by passing the function `AMFMmodel` the **component set**.
```julia codeSnippet
z = AMFMmodel(𝑆)
```

Alternately, we allow an **AM--FMmodel**  to be defined by passing the function `AMFMmodel` an array of components. First, define a the components.
```julia codeSnippet
a₀(t) = exp(-t^2)
ω₀(t) = 2.0
φ₀ = 0.0
ψ₀ = AMFMcomp(a₀,ω₀,φ₀)

a₁(t) = 1.0
ω₁(t) = 10*t
φ₁ = 0.1
ψ₁ = AMFMcomp(a₁,ω₁,φ₁)

a₂(t) = 0.8*cos(2t)
ω₂(t) = 10 + 7.5*sin(t)
φ₂ = π
ψ₂ = AMFMcomp(a₂,ω₂,φ₂)
```
Then pass them to the function `AMFMmodel` as an array.
```julia codeSnippet
z = AMFMmodel([ψ₀,ψ₁,ψ₂])
```


## Evaluating an AM--FM Model

Once an  **AM--FM model** is defined it can be evaluated at a time instant
```julia codeSnippet
julia> z(0.15)
-0.1844131722041218 + 1.146808452231523im
```
or over a range of time instants.
```julia codeSnippet
julia> t = 0.0:0.25:1.0
julia> z(t)
5-element Array{Complex{Float64},1}:
  2.3127623746121317 + 1.2092678279852234im
 -1.2963995650827416 + 0.025282127799684584im
  0.5931797251405191 + 0.9674372363846413im
 0.25073410019471093 - 0.5690871746595758im
  1.4587415832942454 + 0.7649782375222325im
 ```
