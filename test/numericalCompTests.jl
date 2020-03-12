
using ISA

#DEFINE COMPONENT
a₀(t) = exp(-t^2)
ω₀(t) = 15
φ₀ = 0
𝐶₀ = Tuple([a₀,ω₀,φ₀])
ψ₀ = AMFMcomp(𝐶₀)

#COMPONENT OBSERVATION
t = -1.0:0.01:1.0
ψVec = ψ₀(t)

#ESTIMATE NUMERICAL COMPONENT
ψNum = AMFMdemod(ψVec,t)


A = [ψNum]
A[1].t

isaPlot3d(A)






length(A)

import Plots
i=1
a_max = 1 #need to finish
Plots.plot3d( A[i].t,
A[i].ω,
A[i].s,
c = ISA.cmap[max.(min.(round.(Int, A[i].a .* 256 / a_max), 256), 1)],
linealpha = max.(min.(A[i].a .^ (1 / 2) .* 1 / a_max, 1), 0, ),)



using LaTeXStrings


function isaPlot3d_PlotsGR2(ψₖ::Array{AMFMcompN,1})
    for i in 1:length(ψₖ)
        a_max = 1 #need to finish
        if i==1
            Plots.plot3d( ψₖ[i].t,
            ψₖ[i].ω,
            ψₖ[i].s,
            c = ISA.cmap[max.(min.(round.(Int, ψₖ[i].a .* 256 / a_max), 256), 1)],
            linealpha = max.(min.(ψₖ[i].a .^ (1 / 2) .* 1 / a_max, 1), 0, ),
            xlims = (minimum(t), maximum(t)),
            ylims = (-5, 20),
            zlims = (-1, 1),
            legend = :false,
            framestyle = :origin,
            xlab = L"t",
            ylab = L"\omega(t)",
            zlab = L"x(t)",
            camera = (20,80),
            background_color=ISA.cmap[1],
            foreground_color=:white,
            )
        else
            Plots.plot3d!(  ψₖ[i].t,
                            ψₖ[i].ω,
                            ψₖ[i].s,
                            c = cmap[ max.(min.(round.(Int, ψₖ[i].a .* 256/a_max ),256),1) ],
                            linealpha = max.(min.( ψₖ[i].a.^(1/2) .* 1/a_max ,1),0) )
        end
    end
    Plots.current()
end


isaPlot3d_PlotsGR2(A)
