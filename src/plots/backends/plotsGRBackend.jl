
import Plots

#Construct isaPlot3d from type AMFMmodel called with a time index using PlotsGR backend
function isaPlot3d_PlotsGR(z::AMFMmodel,t::Vector{Float64};
    a_max = maximum([maximum(abs.(z.comps[k].a.(t))) for k in 1:length(z.comps)]),
    ω_max = maximum([maximum(z.comps[k].ω.(t)) for k in 1:length(z.comps)]),
    ω_min = minimum(append!([minimum(z.comps[k].ω.(t)) for k in 1:length(z.comps)],[0])),
    s_max = maximum([maximum(abs.(real.(z.comps[k](t)))) for k in 1:length(z.comps)]),
    s_min = -s_max,
    t_max = minimum(t),
    t_min = maximum(t),
    FreqUnits = "rad/s",
    )
    if FreqUnits == "rad/s"
         Fnorm = 1
     elseif FreqUnits == "Hz"
         Fnorm = 1/2π
     else
         error("invalid FreqUnits")
     end
     Plots.plot3d(
        xlims = (t_max, t_min),
        ylims = (Fnorm*ω_min, Fnorm*ω_max),
        zlims = (s_min, s_max),
        legend = :false,
        framestyle = :origin,
        xlab = "time",
        ylab = "freq ("*FreqUnits*")",
        zlab = "real",
        camera = (20,80),
        background_color=ISA.cmap[1],
        foreground_color=:white,
        )
    for k in 1:length(z.comps)
        Plots.plot3d!(
            t,
            Fnorm.*z.comps[k].ω.(t),
            real.(z.comps[k](t)),
            c = ISA.cmap[ max.(min.(round.(Int, abs.(z.comps[k].a.(t)) .* 256/a_max ),256),1) ],
            linealpha = max.(min.( abs.(z.comps[k].a.(t)).^(1/2) .* 1/a_max ,1),0)
            )
    end
    Plots.current()
end

#Construct isaPlot3d from Array of Numerical AMFM Componets using PlotsGR backend
function isaPlot3d_PlotsGR(𝚿ₖ::Array{AMFMcompN,1};
    a_max = maximum([maximum(𝚿ₖ[k].a) for k in 1:length(𝚿ₖ)]),
    ω_max = maximum([maximum(𝚿ₖ[k].ω) for k in 1:length(𝚿ₖ)]),
    ω_min = minimum(append!([minimum(𝚿ₖ[k].ω) for k in 1:length(𝚿ₖ)],[0])),
    s_max = maximum([maximum(abs.(𝚿ₖ[k].s)) for k in 1:length(𝚿ₖ)]),
    s_min = -s_max,
    t_max = maximum([maximum(𝚿ₖ[k].t) for k in 1:length(𝚿ₖ)]),
    t_min = minimum([minimum(𝚿ₖ[k].t) for k in 1:length(𝚿ₖ)]),
    FreqUnits = "rad/s",
    )
    if FreqUnits == "rad/s"
         Fnorm = 1
     elseif FreqUnits == "Hz"
         Fnorm = 1/2π
     else
         error("invalid FreqUnits")
     end
    Plots.plot3d(
        xlims = (t_min, t_max),
        ylims = (Fnorm*ω_min, Fnorm*ω_max),
        zlims = (s_min, s_max),
        legend = :false,
        framestyle = :origin,
        xlab = "time",
        ylab = "freq ("*FreqUnits*")",
        zlab = "real",
        camera = (20,80),
        background_color=ISA.cmap[1],
        foreground_color=:white,
        )
    for k in 1:length(𝚿ₖ)
        Plots.plot3d!(
            𝚿ₖ[k].t,
            Fnorm.*𝚿ₖ[k].ω,
            𝚿ₖ[k].s,
            c = ISA.cmap[ max.(min.(round.(Int, 𝚿ₖ[k].a .* 256/a_max ),256),1) ],
            linealpha = max.(min.( 𝚿ₖ[k].a.^(1/2) .* 1/a_max ,1),0)
            )
    end
    Plots.current()
end
