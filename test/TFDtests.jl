

using ISA
using Plots


fs=40000.0
t = collect(0.0:1/fs:1.0)
z = exp.(1im*(2*π*10000t))
windowFunction = ones(Float64,25)
frameAdvance = 1

zₖ = frameSignal(z, windowFunction, frameAdvance)
Z,freqs = STFT(z, windowFunction, frameAdvance,fs=fs)

contour(t[1:frameAdvance:end], freqs, abs.(reduce(hcat,Z)), fill=:true, seriescolor=cgrad(ISA.cmap), )
