
import Makie

#Construct isaPlot3d from type AMFMmodel called with a time index using Makie backend
function isaPlot3d_Makie(z::AMFMmodel,t::Vector{Float64})
    a_max = 1 #need to finish
    myScene = Makie.Scene(resolution = (1080,1080),
    camera = Makie.cam3d!)
    for i in 1:length(z.comps)
        myScene = Makie.lines!(-t,
         -z.comps[i].ω.(t),
          real.(z.comps[i](t)),
           color = ISA.cmap[max.(min.(round.(Int, abs.(z.comps[i].a.(t)) .* 256 / a_max), 256), 1)])
    end
              axis = myScene[Makie.Axis] # get the axis object from the scene
              axis.names.axisnames = ("t", "ω(t)","x(t)")
              myScene
end


#lims = FRect3D(Vec3f0(-1, -1, -1), Vec3f0(1, 1, 2))
