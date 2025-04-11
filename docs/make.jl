using RebranchingIP
using Documenter

DocMeta.setdocmeta!(RebranchingIP, :DocTestSetup, :(using RebranchingIP); recursive=true)

makedocs(;
    modules=[RebranchingIP],
    authors="nzy1997",
    sitename="RebranchingIP.jl",
    format=Documenter.HTML(;
        canonical="https://nzy1997.github.io/RebranchingIP.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/nzy1997/RebranchingIP.jl",
    devbranch="main",
)
