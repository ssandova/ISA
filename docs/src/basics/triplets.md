# Cannonical Triplets and Component Sets

## Cannonical Triplets
A **cannonical triplet** `Tuple{Function,Function,Real}` is a tuple consisting of an instantaneous amplitude (IA) `Function`, an instantaneous frequency (IF) `Function`, and a phase reference `Real`.

$\mathscr{C}\triangleq\left\{a(t),\omega(t), \phi\vphantom{0^0}\right\}$

### Defining a Cannonical Triplet
We can define a **cannonical triplet** as follows.
```
julia> a₀(t) = exp(-t^2)
a₀ (generic function with 1 method)

julia> ω₀(t) = 2.0
ω₀ (generic function with 1 method)

julia> φ₀ = 0.0
0.0

julia> 𝐶₀ = (a₀,ω₀,φ₀)
(a₀, ω₀, 0.0)
```

## Component Sets
A **component set** `Array{Tuple{Function,Function,Real},1}` is a set of **cannonical triplet** `Tuple{Function,Function,Real}` .

$\mathscr{S}\triangleq\left\{\mathscr{C}_0,\mathscr{C}_1,\cdots,\mathscr{C}_{K-1}\vphantom{0^0}\right\}$

### Defining a Component Set
We can define a **component set** as follows. First, we define several **cannonical triplet**.
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
```
Then, store the **cannonical triplets** in an array.
```
julia> 𝑆 = [𝐶₀,𝐶₁,𝐶₂]
3-element Array{Tuple{Function,Function,Real},1}:
 (a₀, ω₀, 0.0)
 (a₁, ω₁, 0.1)
 (a₂, ω₂, π)
```
