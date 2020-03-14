using ISA #References: Sandoval, Steven, and Phillip L. De Leon. "The Instantaneous Spectrum: A General Framework for Time-Frequency Analysis." IEEE Transactions on Signal Processing 66.21 (2018): 5679-5693.

t = Array(0.0:0.005:2.0)

using Interact
@manipulate for a= 0:0.05:1, ω = -5:0.1:20, φ = -pi:pi/50:pi
    a₀(t) = a
    ω₀(t) = ω
    φ₀ = φ
    𝐶₀ = Tuple([a₀,ω₀,φ₀])

    isaPlot3d(𝐶₀, t)
end
