using Documenter
using Cyclops

makedocs(
    sitename = "Cyclops.jl",
    modules = [Cyclops],
    pages = [
        "Home" => "index.md",
        "Getting Started" => "getting_started.md",
        "API" => "api.md",
        "Errors" => "errors.md",
    ],
    doctest = true,
)

deploydocs(
    repo = "github.com/JanHammarlund/Cyclops.jl.git",
    devbranch = "main",
)
