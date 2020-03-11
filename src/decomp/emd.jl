import Dierckx #for cubic spline interplation

function findLocalMaxima(signal::Vector; angle=0.0,  includeEdge = :false)
  Inds = Int64[]
  signal = real.(exp(-1im*angle)*signal)
  if includeEdge #include maxima on edges
    if length(signal)>1
      if signal[1]>signal[2]
        push!(Inds,1)
      end
      for i=2:length(signal)-1
        if signal[i-1]<signal[i]>signal[i+1]
          push!(Inds,i)
        end
      end
      if signal[end]>signal[end-1]
        push!(Inds,length(signal))
      end
    end
  else #ignore maxima on edges
    for i=2:length(signal)-1
      if signal[i-1]<signal[i]>signal[i+1]
        push!(Inds,i)
      end
    end
  end
  Vals = [ signal[idx[1]] for idx in Inds]
  return IndsVals = [Inds, Vals]
end

function SIFT(r::Vector{Float64}; siftStopThresh = 1e-6, includeEdge = :true)
  L = length(r)
  while true
    maxIndsVals = findLocalMaxima(r, includeEdge=includeEdge)
    maxInterpolator = Dierckx.Spline1D(maxIndsVals[1], maxIndsVals[2])
    u = maxInterpolator(1:L)
    minIndsVals = findLocalMaxima(-r, includeEdge=includeEdge)
    minInterpolator = Dierckx.Spline1D(minIndsVals[1], -minIndsVals[2])
    l = minInterpolator(1:L)
    e = (u+l)./2
    r -= e
    mae = sum(abs.(e[round(Int,L/4):round(Int,3L/4)]))/length( e[round(Int,L/4):round(Int,3L/4)])
    if mae < siftStopThresh
      break
    end
  return r
  end
end

function EMD(x::Vector{Float64}; emdStopThresh = 1e-2, siftStopThresh = 1e-3, includeEdge = :true)
  IMF = Vector{Float64}[]
  for _ = 1:2 #need to finish!!!!!!!!!!!!!!!
    φ = SIFT(x, siftStopThresh=siftStopThresh, includeEdge=includeEdge)
    x -= φ
    push!(IMF, φ)
  end
  return push!(IMF, x)
end

function ℂSIFT(r::Vector{ComplexF64}; D = 4, siftStopThresh = 1e-3, includeEdge = :true)
  while true
    L = length(r)
    e = zeros(ComplexF64,L)
    for d in 1:2D
      ϑ = 2π*(d-1)/2D
      maxIndsVals = findLocalMaxima(r, angle=ϑ, includeEdge=includeEdge)
      maxInterpolator = Dierckx.Spline1D(maxIndsVals[1], maxIndsVals[2])
      e += exp(1im*ϑ)*maxInterpolator(1:L)
    end
    e /= 2D
    r -= e
    mae = sum(abs.(e[round(Int,L/4):round(Int,3L/4)]))/length(e[round(Int,L/4):round(Int,3L/4)])
    if mae < siftStopThresh
      break
    end
  end
  return r
end

function ℂEMD(z::Vector{ComplexF64}; emdStopThresh = 1e-2, D = 4, siftStopThresh = 1e-3, includeEdge = :true)
  IMF = Vector{ComplexF64}[]
  for _ = 1:2 #need to finish!!!!!!!!!!!!!!!
    φ = ℂSIFT(z, D=D, siftStopThresh=siftStopThresh, includeEdge=includeEdge)
    z -= φ
    push!(IMF, φ)
  end
  return push!(IMF, z)
end
