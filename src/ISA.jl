module ISA

include("components/basicComps.jl")
export AMFMcomp

include("components/numericalComps.jl")
include("demod/demod.jl")
export derivApprox, AMFMdemod, AMFMcompN

include("models/basicModels.jl")
export AMFMmodel, fourierSeries

include("plots/isaPlots.jl")
export isaPlot3d

include("decomp/emd.jl")
export findLocalMaxima, SIFT, EMD, ℂSIFT, ℂEMD

include("TFDs/TFDs.jl")
export frameSignal, STFT

end # module
