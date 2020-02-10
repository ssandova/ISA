using Documenter, ISA

makedocs(;
    modules=[ISA],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
        "Basics" =>
                    ["Cannonical Triplets and Component Sets"   => "basics/triplets.md",
                     "AM--FM Components"     => "basics/components.md",
                     "AM--FM Models"         => "basics/models.md",
                     "Instantaneous Spectra" => "basics/spectra.md",],

    ],
    repo="https://github.com/ssandova/ISA.jl/blob/{commit}{path}#L{line}",
    sitename="ISA.jl",
    authors="Steven Sandoval",
    assets=String[],
)








#deploydocs(;
#    repo="github.com/ssandova/ISA.jl",
#)
