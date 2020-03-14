using ISA #References: Sandoval, Steven, and Phillip L. De Leon. "The Instantaneous Spectrum: A General Framework for Time-Frequency Analysis." IEEE Transactions on Signal Processing 66.21 (2018): 5679-5693.
using Plots

sig = cos.(0.0:π/100:10pi) +  cos.( 5*(0.0:π/100:10pi))+  cos.( 20*(0.0:π/100:10pi))
φ₁ = SIFT(sig)
plot(sig)
plot!(φ₁)
φ₂ = SIFT(sig-φ₁)
plot!(φ₂)
plot!(sig-φ₁-φ₂)


#-------------------------------------------

sig = cos.(0.0:π/100:10pi) +  cos.( 5*(0.0:π/100:10pi))+  cos.( 20*(0.0:π/100:10pi))
IMF = EMD(sig)
plot(sig)
plot!(IMF)

#-------------------------------------------

sig = exp.( 1im*(0.0:π/100:10pi)) +  exp.( 5im*(0.0:π/100:10pi)) +  exp.( 20im*(0.0:π/100:10pi))
φ₁ = ℂSIFT(sig)
plot(real(sig))
plot!(real(φ₁))
φ₂ = ℂSIFT(sig-φ₁)
plot!(real(φ₂))
plot!(real(sig-φ₁-φ₂))

#-------------------------------------------

sig = exp.( 1im*(0.0:π/100:10pi)) +  exp.( 5im*(0.0:π/100:10pi)) +  exp.( 20im*(0.0:π/100:10pi))
IMF = ℂEMD(sig)
plot(real(sig))
plot!(real.(IMF))
