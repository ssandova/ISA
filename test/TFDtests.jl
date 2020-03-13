

using ISA
using Plots


fs=500
t = collect(0.0:1/fs:2.0)

a₀(t) = exp(-t^2)
ω₀(t) = 50
φ₀ = 0
𝐶₀ = Tuple([a₀,ω₀,φ₀])

a₁(t) = exp(-(t-1.0)^2)
ω₁(t) = 2*π*100 + 150*sin(2t)
φ₁ = π
𝐶₁ = Tuple([a₁,ω₁,φ₁])

a₂(t) = 0.8*cos(2t)
ω₂(t) = 2*π*(-100 + 50t)
φ₂ = π
𝐶₂ = Tuple([a₂,ω₂,φ₂])

𝑆 = [𝐶₀,𝐶₁,𝐶₂]
z = AMFMmodel(𝑆)



p1 = isaPlot3d(z, t, FreqUnits="Hz")


windowFunction = ones(Float64,25)
frameAdvance = 1
zₖ = frameSignal(z(t), windowFunction, frameAdvance)
Z,freqs = STFT(z(t), windowFunction, frameAdvance,fs=fs)

p2 = contour(t[1:frameAdvance:end], freqs, abs.(reduce(hcat,Z)), fill=:true, seriescolor=cgrad(ISA.cmap),levels=5 )

plot(p1,p2,layout=(2,1))
