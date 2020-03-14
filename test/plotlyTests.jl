using ISA #References: Sandoval, Steven, and Phillip L. De Leon. "The Instantaneous Spectrum: A General Framework for Time-Frequency Analysis." IEEE Transactions on Signal Processing 66.21 (2018): 5679-5693.

fs = 10000
t = collect(0.0:1/fs:0.1)

a₀(t) = exp(-(t)^2)
ω₀(t) = 1000
φ₀ = 0
𝐶₀ = Tuple([a₀,ω₀,φ₀])

a₁(t) = exp(-1000.0(t-0.05)^2)
ω₁(t) = 2*π*1000 + 1500*sin(50t)
φ₁ = π
𝐶₁ = Tuple([a₁,ω₁,φ₁])

a₂(t) = 0.8*cos(2t)
ω₂(t) = 2*π*(-500 + 5000t)
φ₂ = π
𝐶₂ = Tuple([a₂,ω₂,φ₂])

𝑆 = [𝐶₀,𝐶₁,𝐶₂]
z = AMFMmodel(𝑆)

p1 = isaPlot3d(z, t, backend="Plotly")
