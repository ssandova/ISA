
import Plots

#Construct isaPlot3d from type AMFMmodel called with a time index using PlotsGR backend
function isaPlot3d_PlotsGR(z::AMFMmodel,t::Vector{Float64})
    a_max = maximum([maximum(abs.(z.comps[k].a.(t))) for k in 1:length(z.comps)])
    ω_max = maximum([maximum(z.comps[k].ω.(t)) for k in 1:length(z.comps)])
    ω_min = minimum(append!([minimum(z.comps[k].ω.(t)) for k in 1:length(z.comps)],[0]))
    s_max = maximum([maximum(abs.(real.(z.comps[k](t)))) for k in 1:length(z.comps)])
    Plots.plot3d(
        xlims = (minimum(t), maximum(t)),
        ylims = (ω_min, ω_max),
        zlims = (-s_max, s_max),
        legend = :false,
        framestyle = :origin,
        xlab = L"t",
        ylab = L"\omega(t)",
        zlab = L"x(t)",
        camera = (20,80),
        background_color=cmap[1],
        foreground_color=:white,
        )
    for k in 1:length(z.comps)
        Plots.plot3d!(
            t,
            z.comps[k].ω.(t),
            real.(z.comps[k](t)),
            c = ISA.cmap[ max.(min.(round.(Int, abs.(z.comps[k].a.(t)) .* 256/a_max ),256),1) ],
            linealpha = max.(min.( abs.(z.comps[k].a.(t)).^(1/2) .* 1/a_max ,1),0)
            )
    end
    Plots.current()
end

#Construct isaPlot3d from Array of Numerical AMFM Componets using PlotsGR backend
function isaPlot3d_PlotsGR(ψₖ::Array{AMFMcompN,1})
    a_max = maximum([maximum(ψₖ[k].a) for k in 1:length(ψₖ)])
    ω_max = maximum([maximum(ψₖ[k].ω) for k in 1:length(ψₖ)])
    ω_min = minimum(append!([minimum(ψₖ[k].ω) for k in 1:length(ψₖ)],[0]))
    s_max = maximum([maximum(abs.(ψₖ[k].s)) for k in 1:length(ψₖ)])
    t_max = maximum([maximum(ψₖ[k].t) for k in 1:length(ψₖ)])
    t_min = minimum([minimum(ψₖ[k].t) for k in 1:length(ψₖ)])
    Plots.plot3d(
        xlims = (t_min, t_max),
        ylims = (ω_min, ω_max),
        zlims = (-s_max, s_max),
        legend = :false,
        framestyle = :origin,
        xlab = L"t",
        ylab = L"\omega(t)",
        zlab = L"x(t)",
        camera = (20,80),
        background_color=ISA.cmap[1],
        foreground_color=:white,
        )
    for k in 1:length(ψₖ)
        Plots.plot3d!(
            ψₖ[k].t,
            ψₖ[k].ω,
            ψₖ[k].s,
            c = ISA.cmap[ max.(min.(round.(Int, ψₖ[k].a .* 256/a_max ),256),1) ],
            linealpha = max.(min.( ψₖ[k].a.^(1/2) .* 1/a_max ,1),0)
            )
    end
    Plots.current()
end
