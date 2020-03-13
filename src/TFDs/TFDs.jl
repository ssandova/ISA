
using DSP, AbstractFFTs

function frame(z::Vector{<:Number}, windowFunction::Vector{<:Number}, frameAdvance::Int64)
    frameLength = length(windowFunction)
    if iseven(frameLength); error("frame: frameLength must be odd"); end
    L::Int64 = (frameLength-1)/2
    zPadded = append!(append!(zeros(ComplexF64,L),z), zeros(ComplexF64,L)  )
    return [ zPadded[1+i:length(frameLength)+i].*windowFunction  for i in 1:frameAdvance:length(z)]
end

function STFT(z::Vector{<:Number}, windowFunction::Vector{<:Number}, frameAdvance::Int64)
    zₖ = frame(z, windowFunction, frameAdvance)
    return ( fftshift.(fft.(zₖ)), fftshift(collect(0:2π/length(windowFunction):2π-2π/length(windowFunction))) )
end
