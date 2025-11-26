using Cyclops
using Test
using Random
using Flux
using InteractiveUtils: subtypes

@testset "Cyclops" begin

@testset "Cyclops Error Hierarchy" begin
    cyclops_error_hierarchy = Dict(
        CyclopsError => [
            CyclopsConstructorError,
            CyclopsFunctionError
        ],
        CyclopsConstructorError => [
            CyclopsHypersphereDomainError,
            CyclopsInputAndHypersphereDomainError,
            CyclopsMultihotDomainError,
            CyclopsMultihotMatrixShapeError,
            CyclopsMultihotOffsetShapeError,
            CyclopsDenseInverseShapeError,
            CyclopsDenseShapeError
        ],
        CyclopsFunctionError => [
            CyclopsMultihotDimensionMismatch,
            CyclopsInputDimensionMismatch,
            CyclopsHypersphereNaNError,
            CyclopsHypersphereDivideError
        ]
    )

    # Each parent’s current subtypes must be drawn from the expected set.
    for (parent, children) in cyclops_error_hierarchy
        @test Set(subtypes(parent)) ⊆ Set(children)
    end # 3 abstract types with concrete types as children, 3 tests

    concrete_errors = [
        CyclopsHypersphereDomainError,
        CyclopsInputAndHypersphereDomainError,
        CyclopsMultihotDomainError,
        CyclopsMultihotMatrixShapeError,
        CyclopsMultihotOffsetShapeError,
        CyclopsDenseInverseShapeError,
        CyclopsDenseShapeError,
        CyclopsMultihotDimensionMismatch,
        CyclopsInputDimensionMismatch,
        CyclopsHypersphereNaNError,
        CyclopsHypersphereDivideError
    ]

    for T in concrete_errors
        @test !isabstracttype(T)
    end # 11 concrete types, 11 tests

end # 14 tests

@testset "Expected Errors" begin
    
    @testset "Constructor Errors" begin
        # Errors encountered while initializing a variable::cyclops
        
        @testset "Hypersphere Domain Error" begin
            @test CyclopsHypersphereDomainError isa DataType
            @test_throws CyclopsHypersphereDomainError cyclops(5, 0, 1)
            @test_throws "`c` = 1, but `c` must be ≥ 2." cyclops(5, 0, 1)
        end # 3 tests

        @testset "Input and Hypersphere Domain Error" begin
            @test CyclopsInputAndHypersphereDomainError isa DataType
            @test_throws CyclopsInputAndHypersphereDomainError cyclops(5, 0, 6)
            @test_throws "`n` = 5 ≤ `c`, but `n` must be > 6." cyclops(5, 0, 6)
        end # 3 tests

        @testset "Multi-hot Domain Error" begin
            @test CyclopsMultihotDomainError isa DataType
            @test_throws CyclopsMultihotDomainError cyclops(5, -1, 3)
            @test_throws "`m` = -1 < 0, but `m` must be ≥ 0." cyclops(5, -1, 3)
        end # 3 tests
            
        @testset "Multi-hot Matrix Shape Error" begin
            @test CyclopsMultihotMatrixShapeError isa DataType
            @test_throws CyclopsMultihotMatrixShapeError cyclops(rand(Float32, 5, 3), rand(Float32, 6, 4), rand(Float32, 5), Flux.Dense(5 => 2), Flux.Dense(2 => 5))
            @test_throws "scale has dimensions (5, 3) ≠ (6, 4) dimensions of mhoffset." cyclops(rand(Float32, 5, 3), rand(Float32, 6, 4), rand(Float32, 5), Flux.Dense(5 => 2), Flux.Dense(2 => 5))
        end # 3 tests
        
        @testset "Multi-hot Offset Shape Error" begin
            @test CyclopsMultihotOffsetShapeError isa DataType
            @test_throws CyclopsMultihotOffsetShapeError cyclops(rand(Float32, 5, 3), rand(Float32, 5, 3), rand(Float32, 6), Flux.Dense(5 => 2), Flux.Dense(2 => 5))
            @test_throws "expected dimensions (5,), but got (6,)." cyclops(rand(Float32, 5, 3), rand(Float32, 5, 3), rand(Float32, 6), Flux.Dense(5 => 2), Flux.Dense(2 => 5))
            @test_throws CyclopsMultihotOffsetShapeError cyclops(rand(Float32, 5, 3), rand(Float32, 5, 3), rand(Float32, 5, 1), Flux.Dense(5 => 2), Flux.Dense(2 => 5))
            @test_throws "expected dimensions (5,), but got (5, 1)." cyclops(rand(Float32, 5, 3), rand(Float32, 5, 3), rand(Float32, 5, 1), Flux.Dense(5 => 2), Flux.Dense(2 => 5))
            @test_throws CyclopsMultihotOffsetShapeError cyclops(rand(Float32, 5, 0), rand(Float32, 5, 0), zeros(Float32, 5), Flux.Dense(5 => 2), Flux.Dense(2 => 5))
            @test_throws "expected dimensions (5, 0), but got (5,)." cyclops(rand(Float32, 5, 0), rand(Float32, 5, 0), zeros(Float32, 5), Flux.Dense(5 => 2), Flux.Dense(2 => 5))
        end # 7 tests
        
        @testset "Inverse Dimension Error" begin
            @test CyclopsDenseInverseShapeError isa DataType
            # densein and denseout must have inverse dimensions
            @test_throws CyclopsDenseInverseShapeError cyclops(rand(Float32, 5, 0), rand(Float32, 5, 0), rand(Float32, 5, 0), Flux.Dense(5 => 2), Flux.Dense(3 => 5))
            @test_throws "Expected 5 => 2 compression to be mirrored by 2 => 5 expansion, but got 3 => 5." cyclops(rand(Float32, 5, 0), rand(Float32, 5, 0), rand(Float32, 5, 0), Flux.Dense(5 => 2), Flux.Dense(3 => 5))
            
            @test_throws CyclopsDenseInverseShapeError cyclops(rand(Float32, 5, 0), rand(Float32, 5, 0), rand(Float32, 5, 0), Flux.Dense(4 => 1), Flux.Dense(2 => 7))
            @test_throws "Expected 4 => 1 compression to be mirrored by 1 => 4 expansion, but got 2 => 7." cyclops(rand(Float32, 5, 0), rand(Float32, 5, 0), rand(Float32, 5, 0), Flux.Dense(4 => 1), Flux.Dense(2 => 7))
        end # 3 tests
        
        @testset "Dense Compression Error" begin
            @test CyclopsDenseShapeError isa DataType
            
            @test_throws CyclopsDenseShapeError cyclops(rand(Float32, 5, 0), rand(Float32, 5, 0), rand(Float32, 5, 0), Flux.Dense(3 => 4), Flux.Dense(4 => 3))
            @test_throws "n => c ≥ 2, where n > c, but got 5 ≠ 3 => 4." cyclops(rand(Float32, 5, 0), rand(Float32, 5, 0), rand(Float32, 5, 0), Flux.Dense(3 => 4), Flux.Dense(4 => 3))
            
            @test_throws CyclopsDenseShapeError cyclops(rand(Float32, 5, 0), rand(Float32, 5, 0), rand(Float32, 5, 0), Flux.Dense(5 => 1), Flux.Dense(1 => 5))
            @test_throws "n => c ≥ 2, where n > c, but got 5 => 1 < 2." cyclops(rand(Float32, 5, 0), rand(Float32, 5, 0), rand(Float32, 5, 0), Flux.Dense(5 => 1), Flux.Dense(1 => 5))
            
            @test_throws CyclopsDenseShapeError cyclops(rand(Float32, 5, 0), rand(Float32, 5, 0), rand(Float32, 5, 0), Flux.Dense(6 => 2), Flux.Dense(2 => 6))
            @test_throws "n => c ≥ 2, where n > c, but got 5 ≠ 6 => 2." cyclops(rand(Float32, 5, 0), rand(Float32, 5, 0), rand(Float32, 5, 0), Flux.Dense(6 => 2), Flux.Dense(2 => 6))
            
            @test_throws CyclopsDenseShapeError cyclops(rand(Float32, 5, 0), rand(Float32, 5, 0), rand(Float32, 5, 0), Flux.Dense(7 => 1), Flux.Dense(1 => 7))
            @test_throws "n => c ≥ 2, where n > c, but got 5 ≠ 7 => 1 < 2." cyclops(rand(Float32, 5, 0), rand(Float32, 5, 0), rand(Float32, 5, 0), Flux.Dense(7 => 1), Flux.Dense(1 => 7))
        end # 7 tests
    end # 29 tests

    @testset "Function Errors" begin

        @testset "Multi-hot Dimension Mismatch" begin
            @test CyclopsMultihotDimensionMismatch isa DataType
            @test_throws CyclopsMultihotDimensionMismatch cyclops(5, 2, 3)(rand(Float32, 5), zeros(Int32, 3))
            @test_throws "Multi-hot encoding = 3 ≠ 2 = Multi-hot Parameters" cyclops(5, 2, 3)(rand(Float32, 5), zeros(Int32, 3))
            @test_throws CyclopsMultihotDimensionMismatch cyclops(5, 0, 3)(rand(Float32, 5), zeros(Int32, 3))
            @test_throws "Multi-hot encoding = 3 ≠ 0 = Multi-hot Parameters" cyclops(5, 0, 3)(rand(Float32, 5), zeros(Int32, 3))
        end

        @testset "Input Dimension Mismatch" begin
           @test CyclopsInputDimensionMismatch isa DataType
           @test_throws CyclopsInputDimensionMismatch cyclops(5, 0, 3)(rand(Float32, 6))
           @test_throws "Input = 6 ≠ 5 = Multi-hot" cyclops(5, 0, 3)(rand(Float32, 6))
        end

        @testset "Hypersphere NaN Error" begin
            @test CyclopsHypersphereNaNError isa DataType
            @test_throws CyclopsHypersphereNaNError hsn([1f0, NaN32])
            @test_throws "`NaN` at [2]" hsn([1f0, NaN32])
        end

        @testset "Hypersphere Divide Error" begin
            @test CyclopsHypersphereDivideError isa DataType
            @test_throws CyclopsHypersphereDivideError hsn([0f0, 0f0])
            @test_throws "hypershpere node are `0`." hsn([0f0, 0f0])
        end

    end

end # 41 tests

# ⊙, ⊗, ⊕, ⊖, ⊘, ⩕
@testset "Operators" begin # 73 tests

    @testset "oplus" begin # 14 tests
        oplus_found_methods = Set(m.sig for m in methods(⊕));
        oplus_expected_methods = Set([
            Tuple{typeof(⊕), Number, AbstractArray{<:Number}},
            Tuple{typeof(⊕), AbstractArray{<:Number}, Number},
            Tuple{typeof(⊕), AbstractArray{<:Number}, AbstractArray{<:Number}}
        ])
            
        @test oplus_expected_methods ⊆ oplus_found_methods
            
        x = [1, 2, 3]   # ::AbstractArray{<:Number}
        y1 = 1          # ::Number
        y2 = [3, 2, 1]  # ::AbstractArray{<:Number}
            
        # Tuple{typeof(⊕), AbstractArray{<:Number}, Number},
        @test x ⊕ y1 == [2, 3, 4]
        @test [x x] ⊕ y1 == [2 2; 3 3; 4 4]

        # Tuple{typeof(⊕), Number, AbstractArray{<:Number}}
        @test y1 ⊕ x == [2, 3, 4]
        @test y1 ⊕ [x x] == [2 2; 3 3; 4 4]

        # Tuple{typeof(⊕), AbstractArray{<:Number}, AbstractArray{<:Number}}
        @test x ⊕ y2 == [4, 4, 4]
        @test [x x] ⊕ y2 == y2 ⊕ [x x] == [x x] ⊕ [y2 y2] == [4 4; 4 4; 4 4]
        
        # Tuple{typeof(⊕), Number, Number}
        @test_throws MethodError 1 ⊕ 1

        # Dimension Mismatch
        @test_throws DimensionMismatch ones(3) ⊕ ones(4)
        @test_throws "x has 3 and y has 4." ones(3) ⊕ ones(4)

        @test_throws DimensionMismatch [x x] ⊕ [y2 y2 y2]
        @test_throws "x and y don't have matching dimensions" [x x] ⊕ [y2 y2 y2]

        @test_throws DimensionMismatch [x x] ⊕ ones(4)
        @test_throws "x has 3 and y has 4." [x x] ⊕ ones(4)
    end     # oplus, 14 tests
    
    @testset "ominus" begin # 15 tests
        ominus_found_methods = Set(m.sig for m in methods(⊖));
        ominus_expected_methods = Set([
            Tuple{typeof(⊖), Number, AbstractArray{<:Number}},
            Tuple{typeof(⊖), AbstractArray{<:Number}, Number},
            Tuple{typeof(⊖), AbstractArray{<:Number}, AbstractArray{<:Number}}
        ])
            
        @test ominus_expected_methods ⊆ ominus_found_methods

        x = [1, 2, 3]   # ::AbstractArray{<:Number}
        y1 = 1          # ::Number
        y2 = [3, 2, 1]  # ::AbstractArray{<:Number}

        # Tuple{typeof(⊖), AbstractArray{<:Number}, Number}
        @test x ⊖ y1 == [0, 1, 2]
        @test [x x] ⊖ y1 == [0 0; 1 1; 2 2]

        # Tuple{typeof(⊖), Number, AbstractArray{<:Number}}
        @test y1 ⊖ x == [0, -1, -2]
        @test y1 ⊖ [x x] == [0 0; -1 -1; -2 -2]

        # Tuple{typeof(⊖), AbstractArray{<:Number}, AbstractArray{<:Number}}
        @test x ⊖ y2 == [-2, 0, 2]
        @test [x x] ⊖ y2 == [x x] ⊖ [y2 y2] == [-2 -2; 0 0; 2 2]
        @test y2 ⊖ [x x] == [y2 y2] ⊖ [x x] == [2 2; 0 0; -2 -2]

        # Tuple{typeof(⊖), Number, Number}
        @test_throws MethodError 1 ⊖ 1

        # Dimension Mismatch
        @test_throws DimensionMismatch ones(3) ⊖ ones(4)
        @test_throws "x has 3 and y has 4." ones(3) ⊖ ones(4)

        @test_throws DimensionMismatch [x x] ⊖ [y2 y2 y2]
        @test_throws "don't have matching dimensions" [x x] ⊖ [y2 y2 y2]

        @test_throws DimensionMismatch [x x] ⊖ ones(4)
        @test_throws "x has 3 and y has 4." [x x] ⊖ ones(4)
    end     # ominus, 15 tests
    
    @testset "otimes" begin # 9 tests
        otimes_found_methods = Set(m.sig for m in methods(⊗));
        otimes_expected_methods = Set([
            Tuple{typeof(⊗), AbstractArray{<:Number}, Union{Number, AbstractArray{<:Number}}}
        ])

        @test otimes_expected_methods ⊆ otimes_found_methods

        x = ones(3)
        y1 = [1, 0]
        y2 = [0, 1]
        y3 = [1, 0, 1]

        # Tuple{typeof(⊗), AbstractArray{<:Number}, Number}
        @test x ⊗ 2 == [2, 2, 2]

        # Tuple{typeof(⊗), AbstractArray{<:Number}, AbstractArray{<:Number}}
        @test [x 2*x] ⊗ y1 == [1, 1, 1]
        @test [x 2*x] ⊗ y2 == [2, 2, 2]

        # Tuple{typeof(⊗), Number, Number}
        @test_throws MethodError 1 ⊗ 1
        
        # Dimension Mismatch
        @test_throws DimensionMismatch x ⊗ y3
        @test_throws "x has 1 columns and y has 3 rows." x ⊗ y3

        @test_throws DimensionMismatch [x 2*x] ⊗ 1
        @test_throws "x has 2 columns and y has 1 rows." [x 2*x] ⊗ 1
    end     # otimes, 9 tests
    
    @testset "odot" begin # 14 tests
        odot_found_methods = Set(m.sig for m in methods(⊙));
        odot_expected_methods = Set([
            Tuple{typeof(⊙), AbstractArray{<:Number}, Number},
            Tuple{typeof(⊙), Number, AbstractArray{<:Number}},
            Tuple{typeof(⊙), AbstractArray{<:Number}, AbstractArray{<:Number}}
        ])

        @test odot_expected_methods ⊆ odot_found_methods

        x = [1, 2, 3]   # ::AbstractArray{<:Number}
        y1 = 3          # ::Number
        y2 = [2, 3, 4]  # ::AbstractArray{<:Number}
        
        # Tuple{typeof(⊙), AbstractArray{<:Number}, Number}
        @test x ⊙ y1 == [3, 6, 9]
        @test [x x] ⊙ y1 == [3 3; 6 6; 9 9]

        # Tuple{typeof(⊙), Number, AbstractArray{<:Number}}
        @test y1 ⊙ x == [3, 6, 9]
        @test y1 ⊙ [x x] == [3 3; 6 6; 9 9]

        # Tuple{typeof(⊙), AbstractArray{<:Number}, AbstractArray{<:Number}}
        @test x ⊙ y2 == [2, 6, 12]
        @test [x x] ⊙ y2 == y2 ⊙ [x x] == [x x] ⊙ [y2 y2] == [2 2; 6 6; 12 12]
        
        # Tuple{typeof(⊙), Number, Number}
        @test_throws MethodError 1 ⊙ 1

        # Dimension Mismatch
        @test_throws DimensionMismatch ones(3) ⊙ ones(4)
        @test_throws "x has 3 and y has 4." ones(3) ⊙ ones(4)

        @test_throws DimensionMismatch ones(3, 2) ⊙ ones(4, 5)
        @test_throws "x and y don't have matching dimensions" ones(3, 2) ⊙ ones(4, 5)

        @test_throws DimensionMismatch ones(3, 2) ⊙ ones(4)
        @test_throws "x has 3 and y has 4." ones(3, 2) ⊙ ones(4)
    end     # odot, 14 tests
    
    @testset "oslash" begin # 15 tests
        oslash_found_methods = Set(m.sig for m in methods(⊘));
        oslash_expected_methods = Set([
            Tuple{typeof(⊘), AbstractArray{<:Number}, Number},
            Tuple{typeof(⊘), Number, AbstractArray{<:Number}},
            Tuple{typeof(⊘), AbstractArray{<:Number}, AbstractArray{<:Number}}
        ])

        @test oslash_expected_methods ⊆ oslash_found_methods

        x = [1, 2, 3]   # ::AbstractArray{<:Number}
        y1 = 2          # ::Number
        y2 = [3, 2, 1]  # ::AbstractArray{<:Number}

        # Tuple{typeof(⊘), AbstractArray{<:Number}, Number}
        @test x ⊘ y1 == [0.5, 1, 1.5]
        @test [x x] ⊘ y1 == [0.5 0.5; 1 1; 1.5 1.5]

        # Tuple{typeof(⊘), Number, AbstractArray{<:Number}}
        @test y1 ⊘ x == [2, 1, 2/3]
        @test y1 ⊘ [x x] == [2 2; 1 1; 2/3 2/3]

        # Tuple{typeof(⊘), AbstractArray{<:Number}, AbstractArray{<:Number}}
        @test x ⊘ y2 == [1/3, 1, 3]
        @test [x x] ⊘ y2 == [x x] ⊘ [y2 y2] == [1/3 1/3; 1 1; 3 3]
        @test y2 ⊘ [x x] == [y2 y2] ⊘ [x x] == [3 3; 1 1; 1/3 1/3]

        # Tuple{typeof(⊘), Number, Number}
        @test_throws MethodError 1 ⊘ 1

        # Dimension Mismatch
        @test_throws DimensionMismatch ones(3) ⊘ ones(4)
        @test_throws "x has 3 and y has 4." ones(3) ⊘ ones(4)

        @test_throws DimensionMismatch ones(3, 2) ⊘ ones(5, 7)
        @test_throws "x and y don't have matching dimensions" ones(3, 2) ⊘ ones(5, 7)

        @test_throws DimensionMismatch ones(3, 2) ⊘ ones(4)
        @test_throws "x has 3 and y has 4." ones(3, 2) ⊘ ones(4)
    end     # oslash, 15 tests

    @testset "wedge on wedge" begin # 6 tests
        wedgeonwedge_found_methods = Set(m.sig for m in methods(⩕));
        wedgeonwedge_expected_methods = Set([
            Tuple{typeof(⩕), AbstractArray{<:Number}, Number}
        ])

        @test wedgeonwedge_expected_methods ⊆ wedgeonwedge_found_methods

        x = [1 2; 3 4]
        y1 = 2
        y2 = [2, 3]
        y3 = [2 3; 4 5]

        @test x ⩕ y1 == [1 4; 9 16]

        # Tuple{typeof(⩕), AbstractArray{<:Number}, AbstractArray{<:Number}}
        @test_throws MethodError x ⩕ y2
        @test_throws MethodError x ⩕ y3

        # Tuple{typeof(⩕), Number, AbstractArray{<:Number}}
        @test_throws MethodError y2 ⩕ x

        # Tuple{typeof(⩕), Number, Number}
        @test_throws MethodError y1 ⩕ y1
    end # wedge on wedge, 6 tests
    
end # operators 73 tests

@testset "Constructor" begin

    @testset "cyclops" begin
        @test cyclops isa DataType
        @test Set(fieldnames(cyclops)) ⊆ Set([:scale, :mhoffset, :offset, :densein, :denseout])
        @test Set(m.sig for m in methods(cyclops)) ⊆ Set([
            Tuple{Type{cyclops}, Int64},
            Tuple{Type{cyclops}, Int64, Int64},
            Tuple{Type{cyclops}, Int64, Int64, Int64},
            Tuple{Type{cyclops}, AbstractMatrix{<:Real}, AbstractMatrix{<:Real}, AbstractVecOrMat{<:Real}, Dense, Dense}
        ])
        @test cyclops(3) isa cyclops 
        @test cyclops(3, 0) isa cyclops
        @test cyclops(3, 0, 2) isa cyclops
        @test cyclops(zeros(Float32, 3, 0), zeros(Float32, 3, 0), zeros(Float32, 3, 0), Flux.Dense(3 => 2), Flux.Dense(2 => 3)) isa cyclops
        @test cyclops(zeros(Float32, 3, 1), zeros(Float32, 3, 1), zeros(Float32, 3), Flux.Dense(3 => 2), Flux.Dense(2 => 3)) isa cyclops
        Random.seed!(1234); test_model = cyclops(3,2,2)
        @test test_model.scale isa Array{Float32}
        @test test_model.mhoffset isa Array{Float32}
        @test test_model.offset isa Array{Float32}
        @test test_model.densein isa Dense
        @test test_model.denseout isa Dense
        @test test_model.scale |> size == (3, 2)
        @test test_model.mhoffset |> size == (3, 2)
        @test test_model.offset |> size == (3,)
        @test test_model.densein.weight |> size == (2, 3)
        @test test_model.densein.bias |> size == (2,)
        @test test_model.denseout.weight |> size == (3, 2)
        @test test_model.denseout.bias |> size == (3,)
    end
    
    @testset "nparams" begin
        @test nparams isa Function
        @test methods(nparams)[1].sig == Tuple{typeof(nparams), cyclops}
        @test nparams(cyclops(5, 0, 2)) == 27 # n = 5; m = 0; c = 2; 2*n*c + n + c # For standard model
        @test nparams(cyclops(6, 3, 3)) == 87 # n = 6; m = 3; c = 3; (4*n*m + 2*n + m) # For multi-hot model
        @test nparams(cyclops(5, 2, 2)) == 52 # n = 5; m = 2; c = 2; (4*n*m + 2*n + m) # For multi-hot model
    end
    
end

@testset "Function" begin
    @test Set(m.sig for m in methods(cyclops(3))) ⊆ Set([
        Tuple{cyclops, Vector{Float32}, Vector{Int32}},
        Tuple{cyclops, Vector{Float32}},
        Tuple{cyclops, Vector{Float32}, Missing}
    ])
    Random.seed!(1234); test_cyclops = cyclops(3, 2, 2)
    @test test_cyclops(ones(Float32, 3), ones(Int32, 2)) isa Vector{Float32}
    @test test_cyclops(ones(Float32, 3)) isa Vector{Float32}
    @test test_cyclops(ones(Float32, 3), missing) isa Vector{Float32}
    @test test_cyclops(ones(Float32, 3), ones(Int32, 2)) |> size == (3,)
    @test test_cyclops(ones(Float32, 3)) |> size == (3,)
    @test test_cyclops(ones(Float32, 3), missing) |> size == (3,)
    Random.seed!(1234); test_cyclops_2 = cyclops(3)
    @test test_cyclops_2(ones(Float32, 3)) isa Vector{Float32}
    @test test_cyclops_2(ones(Float32, 3), missing) isa Vector{Float32}
    @test test_cyclops_2(ones(Float32, 3)) |> size == (3,)
    @test test_cyclops_2(ones(Float32, 3), missing) |> size == (3,)
end

@testset "Layers" begin
    @testset "Multihot Layers" begin
        @test mhe isa Function
        @test Set(m.sig for m in methods(mhe)) ⊆ Set([
            Tuple{typeof(mhe), Vector{Float32}, Vector{Int32}, cyclops}
        ])
        Random.seed!(1234); test_cyclops = cyclops(3,2,2)
        @test mhe(ones(Float32, 3), ones(Int32, 2), test_cyclops) isa Vector{Float32}
        @test mhe(ones(Float32, 3), ones(Int32, 2), test_cyclops) |> size == (3,)
        @test mhd(ones(Float32, 3), ones(Int32, 2), test_cyclops) isa Vector{Float32}
        @test mhd(ones(Float32, 3), ones(Int32, 2), test_cyclops) |> size == (3,)
        @test isapprox(mhd(mhe(ones(Float32, 3), ones(Int32, 2), test_cyclops), ones(Int32, 2), test_cyclops), [1f0, 1f0, 1f0], atol=1e-6)
        @test isapprox(mhe(mhd(ones(Float32, 3), ones(Int32, 2), test_cyclops), ones(Int32, 2), test_cyclops), [1f0, 1f0, 1f0], atol=1e-6)
    end

    @testset "Hypersphere Node" begin
        @test hsn isa Function
        @test Set(m.sig for m in methods(hsn)) ⊆ Set([
            Tuple{typeof(hsn), Vector{Float32}}
        ])
        @test hsn([1f0, 1f0]) isa Vector{Float32}
        @test hsn([1f0, 1f0]) |> size == (2,)
        @test hsn([1f0, 0f0]) == [1f0, 0f0]
        @test isapprox(hsn(Float32.([sqrt(0.5), sqrt(0.5)])), Float32.([sqrt(0.5), sqrt(0.5)]), atol=1e-6)
    end
end

end # 184 tests
