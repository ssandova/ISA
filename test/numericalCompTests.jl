
using ISA
using Plots


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
Ψ₀ = ψ₀(t)
Ψ₁ = ψ₁(t)

#ESTIMATE NUMERICAL COMPONENT
𝚿₀ = AMFMdemod(Ψ₀,t)
𝚿₁ = AMFMdemod(Ψ₁,t)

p1 = isaPlot3d([𝚿₀,𝚿₁])
p2 = isaPlot3d(𝚿₀)
plot(p1,p2)

end

main()
