# AM--FM Components

An **AM--FM component** is defined by a **component tripplet**.


## Defining an AM--FM Component

We define an **AM--FM component** by passing the function `AMFMcomp` a **cannonical triplet**.
```julia codeSnippet
 julia> a₀(t) = exp(-t^2)
 a₀ (generic function with 1 method)

 julia> ω₀(t) = 2.0
 ω₀ (generic function with 1 method)

 julia> φ₀ = 0.0
 0.0

 julia> 𝐶₀ = (a₀,ω₀,φ₀)
 (a₀, ω₀, 0.0)

 julia> ψ₀ = AMFMcomp(𝐶₀)
 AMFMcomp(a₀, ω₀, 0.0)
```

Alternately, we allow an **AM--FM component**  to be defined direct by passing the function `AMFMcomp` an instantaneous amplitude (IA) `Function`, an instantaneous frequency (IF) `Function`, and a phase reference `Real`.
```julia codeSnippet
julia> a₀(t) = exp(-t^2)
a₀ (generic function with 1 method)

julia> ω₀(t) = 2.0
ω₀ (generic function with 1 method)

julia> φ₀ = 0.0
0.0

julia> ψ₀ = AMFMcomp(a₀,ω₀,φ₀)
AMFMcomp(a₀, ω₀, 0.0)
```

## Evaluating an AM--FM Component

Once an  **AM--FM component** is defined it can be evaluated at a time instant
```julia codeSnippet
julia> ψ₀(0.15)
-0.302141748563871 + 0.9298966854483709im
```
