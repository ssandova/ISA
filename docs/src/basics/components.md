# AM--FM Components

## Defining an AM--FM Components

We can define an **AM--FM component** by passing the function `AMFMcomp` an instantaneous amplitude (IA), an instantaneous frequency (IF), and a phase reference.
```julia codeSnippet
julia> a₀(t) = exp(-t^2)
a₀ (generic function with 1 method)

julia> ω₀(t) = 2.0
ω₀ (generic function with 1 method)

julia> φ₀ = 0.0
0.0

julia> ψ₀ = AMFMcomp(a₀,ω₀,φ₀)
AMFMcomp(a₀, ω₀, 0)
```

Alternately, we can define an **AM--FM component** by passing the function `AMFMcomp` a cannonical triplet.
```julia codeSnippet
 julia> a₀(t) = exp(-t^2)
 a₀ (generic function with 1 method)

 julia> ω₀(t) = 2.0
 ω₀ (generic function with 1 method)

 julia> φ₀ = 0.0
 0.0

 julia> 𝐶₀ = (a₀,ω₀,φ₀)
 (a₀, ω₀, 0)

 julia> ψ₀ = AMFMcomp(𝐶₀)
 AMFMcomp(a₀, ω₀, 0)
```
