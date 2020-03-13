

using ISA
using Plots

Ts = 0.001
fs=1/Ts
t = collect(0.0:Ts:1.0)
z = exp.(1im*(2*π*200t))
windowFunction = ones(Float64,25)
frameAdvance = 1

zₖ = frameSignal(z, windowFunction, frameAdvance)
Z,freqs = STFT(z, windowFunction, frameAdvance,fs=fs)

contour(t[1:frameAdvance:end], freqs, abs.(reduce(hcat,Z)), fill=:true, seriescolor=cgrad(ISA.cmap), )
