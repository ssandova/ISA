
using DSP, AbstractFFTs

function frameSignal(z::Vector{<:Number}, windowFunction::Vector{<:Number}, frameAdvance::Int64)
    local zPad = copy(z)
    if iseven(length(windowFunction)); windowFunction=windowFunction[1:end-1]; end
    frameLength=length(windowFunction);
    padLen::Int64 = (frameLength-1)/2
    prepend!(zPad, zeros(ComplexF64,padLen))
    append!(zPad, zeros(ComplexF64,padLen))
    return [ zPad[i:frameLength+i-1].*windowFunction  for i in 1:frameAdvance:length(z)]
end

function STFT(z::Vector{<:Number}, windowFunction::Vector{<:Number}, frameAdvance::Int64; fs=1)
#References: Lim, Jae S., and Alan V. Oppenheim. Advanced topics in signal processing. Prentice-Hall, Inc., 1987.
    return ( fftshift.(fft.(frameSignal(z, windowFunction, frameAdvance))), fftshift(collect(AbstractFFTs.fftfreq(length(windowFunction), fs))) )
end
