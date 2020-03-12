
using ISA


function main()
#DEFINE COMPONENT
a₀(t) = exp(-t^2)
ω₀(t) = 15
φ₀ = 0
𝐶₀ = Tuple([a₀,ω₀,φ₀])
ψ₀ = AMFMcomp(𝐶₀)

#DEFINE COMPONENT
a₁(t) = exp(-0.5t^2)
ω₁(t) = 10
φ₁ = 0
𝐶₁ = Tuple([a₁,ω₁,φ₁])
ψ₁ = AMFMcomp(𝐶₁)

#COMPONENT OBSERVATION
t = -1.0:0.01:1.0
ψ₀Vec = ψ₀(t)
ψ₁Vec = ψ₁(t)

#ESTIMATE NUMERICAL COMPONENT
ψ₀Num = AMFMdemod(ψ₀Vec,t)
ψ₁Num = AMFMdemod(ψ₁Vec,t)

isaPlot3d([ψ₀Num,ψ₁Num])

end

main()
