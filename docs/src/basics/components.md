# AM--FM Components

An **AM--FM component** is defined by a **component tripplet**.


## Defining an AM--FM Component

We define an **AM--FM component** by passing the function `AMFMcomp` a **cannonical triplet**. First define a **cannonical triplet**.
```julia codeSnippet
a₀(t) = exp(-t^2)
ω₀(t) = 2.0
φ₀ = 0.0
𝐶₀ = (a₀,ω₀,φ₀)
```
Then pass it to the function `AMFMcomp`.
```julia codeSnippet
julia> ψ₀ = AMFMcomp(𝐶₀)
AMFMcomp(a₀, ω₀, 0.0)
```

Alternately, we allow an **AM--FM component**  to be defined direct by passing the function `AMFMcomp` an instantaneous amplitude (IA) `Function`, an instantaneous frequency (IF) `Function`, and a phase reference `Real`.
```julia codeSnippet
a₀(t) = exp(-t^2)
ω₀(t) = 2.0
φ₀ = 0.0
```
Then call the function `AMFMcomp` as follows.

```julia codeSnippet
julia> ψ₀ = AMFMcomp(a₀,ω₀,φ₀)
AMFMcomp(a₀, ω₀, 0.0)
```


## Evaluating an AM--FM Component

Once an  **AM--FM component** is defined it can be evaluated at a time instant
```julia codeSnippet
julia> ψ₀(0.15)
-0.302141748563871 + 0.9298966854483709im
```
or over a range of time instants.
