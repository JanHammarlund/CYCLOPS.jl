using Cyclops
using Test

@testset "Cyclops.jl" begin
    @test plusTwo() == 2
    @test plusTwo(2) == 4
end
