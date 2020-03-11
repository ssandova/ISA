module ISA

include("components/basicComps.jl")
export AMFMcomp

include("models/basicModels.jl")
export AMFMmodel, fourierSeries

include("plots/isaPlots.jl")
export isaPlot3d

include("decomp/emd.jl")
export findLocalMaxima, SIFT, EMD, ℂSIFT, ℂEMD

end # module
