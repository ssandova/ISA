using ISA

#----------------------------
# BASIC EXAMPLES
#----------------------------

#DEFINE 0th CANONICAL TRIPLET
a₀(t) = exp(-t^2)
ω₀(t) = 100
φ₀ = 0
𝐶₀ = Tuple([a₀,ω₀,φ₀])

#DEFINE 0th COMPONENT
ψ₀ = AMFMcomp(𝐶₀)

#DEFINE 1st CANONICAL TRIPLET
a₁(t) = 1
ω₁(t) = 10*t
φ₁ = π
𝐶₁ = Tuple([a₁,ω₁,φ₁])

#DEFINE 2nd CANONICAL TRIPLET
a₂(t) = 0.8*cos(2t)
ω₂(t) = 10 + 7.5*sin(t)
φ₂ = π
𝐶₂ = Tuple([a₂,ω₂,φ₂])

#DEFINE THE COMPONENT SET
𝑆 = [𝐶₀,𝐶₁,𝐶₂]

#DEFINE THE AMFM MODEL
z = AMFMmodel(𝑆)

#DEFINE A TIME INDEX
t = Array(0.0:0.005:2.0)

#EVALUATE THE 0th COMPONENT AT THE POINTS IN THE TIME INDEX
ψ₀(t)

#EVALUATE THE AMFM MODEL AT THE POINTS IN THE TIME INDEX
z(t)

#----------------------------
# FOURIER SERIES
#----------------------------

T = 1
aₖ(k) = 1
kInds = Vector(-10:10)

z₀ = fourierSeries(T,aₖ,kInds)


#----------------------------
# PLOTS
#----------------------------

p1 = isaPlot3d(𝐶₁, t)

p2 = isaPlot3d(ψ₀, t)

p3 = isaPlot3d(z₀, t, FreqUnits="Hz")

p4 = isaPlot3d(𝑆, t, FreqUnits="Hz")

using Plots
plot(p1,p2,p3,p4)
