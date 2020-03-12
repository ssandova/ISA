
import Plots

#Construct isaPlot3d from type AMFMmodel called with a time index using PlotsGR backend
function isaPlot3d_PlotsGR(z::AMFMmodel,t::Vector{Float64})
    a_max = 1 #need to finish
    for i in 1:length(z.comps)
        if i==1
            Plots.plot3d(
            t,
            z.comps[i].ω.(t),
            real.(z.comps[i](t)),
            c = ISA.cmap[max.(min.(round.(Int, abs.(z.comps[i].a.(t)) .* 256 / a_max), 256), 1)],
            linealpha = max.(min.(abs.(z.comps[i].a.(t)) .^ (1 / 2) .* 1 / a_max, 1), 0, ),
            xlims = (minimum(t), maximum(t)),
            ylims = (-5, 20),
            zlims = (-1, 1),
            legend = :false,
            framestyle = :origin,
            xlab = L"t",
            ylab = L"\omega(t)",
            zlab = L"x(t)",
            camera = (20,80),
            background_color=cmap[1],
            foreground_color=:white,
            )
        else
            Plots.plot3d!( t,
                           z.comps[i].ω.(t),
                           real.(z.comps[i](t)),
                           c = ISA.cmap[ max.(min.(round.(Int, abs.(z.comps[i].a.(t)) .* 256/a_max ),256),1) ],
                           linealpha = max.(min.( abs.(z.comps[i].a.(t)).^(1/2) .* 1/a_max ,1),0) )
        end
    end
    Plots.current()
end

#NOT WORKING!!!!!!!!!!!!!!
function isaPlot3d_PlotsGR(Ψ::Array{AMFMcompN,1})
    a_max = 1 #need to finish
    for k in 1:length(Ψ)
        ψₖ::AMFMcompN = Ψ[k]

        if k==1
            Plots.plot3d( ψₖ.t,
            ψₖ.ω,
            ψₖ.s,
            c = ISA.cmap[max.(min.(round.(Int, ψₖ.a .* 256 / a_max), 256), 1)],
            linealpha = max.(min.(ψₖ.a .^ (1 / 2) .* 1 / a_max, 1), 0, ),
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
            Plots.plot3d!(  ψₖ.t,
                            ψₖ.ω,
                            ψₖ.s,
                            c = ISA.cmap[ max.(min.(round.(Int, ψₖ.a .* 256/a_max ),256),1) ],
                            linealpha = max.(min.( ψₖ.a.^(1/2) .* 1/a_max ,1),0) )
        end
    end
    Plots.current()
end
