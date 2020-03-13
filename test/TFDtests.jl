

using ISA

t = (0.0:0.01:1.0)
z = exp.(1im*t)
windowFunction = ones(Float64,11)
frameAdvance = 5

zₖ = frame(z, windowFunction, frameAdvance)

Z,freqs = STFT(z, windowFunction, frameAdvance)
