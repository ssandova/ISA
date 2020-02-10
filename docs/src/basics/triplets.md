#Cannonical Triplets

## Defining a Cannonical Triplet

We define a **cannonical triplet** as a tuple consisting of an instantaneous amplitude (IA), an instantaneous frequency (IF), and a phase reference.
```julia codeSnippet
julia> a₀(t) = exp(-t^2)
a₀ (generic function with 1 method)

julia> ω₀(t) = 2.0
ω₀ (generic function with 1 method)

julia> φ₀ = 0.0
0.0

julia> 𝐶₀ = (a₀,ω₀,φ₀)
(a₀, ω₀, 0)
```
