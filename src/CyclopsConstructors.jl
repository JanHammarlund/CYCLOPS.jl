#################################
##### Cyclops Constructor Check #
#################################
"""
    CheckCyclopsConstructorInput(n::Int, m::Int, c::Int)

Checks domains of input arguments to `cyclops`, and returns `nothing` if all checks are passed.

# Errors
- `CyclopsHypersphereDomainError` when `c < 2`
- `CyclopsInputAndHypersphereDomainError` when `n ≤ c`
- `CyclopsMultihotDomainError` when `m < 0`

# See also
[`CyclopsHypersphereDomainError`](@ref), [`CyclopsInputAndHypersphereDomainError`](@ref)
[`CyclopsMultihotDomainError`](@ref), [`cyclops`](@ref)

# Examples
```julia-repl
julia> n = 5; m = 0; c = 1; Cyclops.CheckCyclopsConstructorInput(n, m, c)
ERROR: CyclopsHypersphereDomainError: `c` = 1, but `c` must be ≥ 2.
[...]

julia> n = 5; m = 0; c = 5; Cyclops.CheckCyclopsConstructorInput(n, m, c)
ERROR: CyclopsInputAndHypersphereDomainError: `n` = 5 ≤ `c`, but `n` must be > 5 or `c` must be < 5.
[...]

julia> n = 5; m = -1; c = 3; Cyclops.CheckCyclopsConstructorInput(n, m, c)
ERROR: CyclopsMultihotDomainError: `m` = -1 < 0, but `m` must be ≥ 0
[...]
```
"""
function CheckCyclopsConstructorInput(n::Int, m::Int, c::Int)
    c ≥ 2 || throw(CyclopsHypersphereDomainError(c))
    n > c || throw(CyclopsInputAndHypersphereDomainError(n, c))
    m ≥ 0 || throw(CyclopsMultihotDomainError(m))

    return nothing
end

function CheckCyclopsConstructorInput(
    scale::AbstractArray{<:Real,2},
    mhoffset::AbstractArray{<:Real,2},
    offset::AbstractVecOrMat{<:Real},
    densein::Dense,
    denseout::Dense)

    scale_size = size(scale)
    mhoffset_size = size(mhoffset)
    offset_size = size(offset)
    densein_weight_size = size(densein.weight)
    denseout_weight_size = size(denseout.weight)

    # Make sure multi-hot parameters are the same size
    scale_size == mhoffset_size || throw(CyclopsMultihotMatrixShapeError(scale_size, mhoffset_size))
    
    # Make sure that offset is either a n by 1 or a n by 0 array
    if scale_size[2] == 0 
        # If scale is a n by 0 matrix, then offset must be, too
        offset_size == scale_size || throw(CyclopsMultihotOffsetShapeError(scale_size, offset_size)) 
    else
        # If scale is a n by m ≥ 1, then offset must be a Vector with n rows
        (scale_size[1],) == offset_size || throw(CyclopsMultihotOffsetShapeError((scale_size[1],), offset_size))
    end
    
    # Make sure dense layers have inverse dimensions
    densein_weight_size == reverse(denseout_weight_size) || throw(CyclopsDenseInverseShapeError(densein_weight_size, denseout_weight_size))
    
    # Make sure n > c ≥ 2
    2 ≤ densein_weight_size[1] < densein_weight_size[2] == scale_size[1] || throw(CyclopsDenseShapeError(densein_weight_size, scale_size[1]))
    
    # Convert offset to appropriate type
    offset32 = ndims(offset) == 2 ? Array{Float32}(offset) : Vector{Float32}(offset)

    return offset32
end





###########################
##### Cyclops Constructor #
###########################
"""
    cyclops(n::Int[, m::Int=0, c::Int=2])

Creates an instance of cyclops.

Type `cyclops` has fieldnames:
- `scale` (`::Array{Float32}`)
- `mhoffset` (`::Array{Float32}`)
- `offset` (`::Array{Float32}`)
- `densein` (`::Dense`)
- `denseout` (`::Dense`)

# Arguments
- `n` (`n ∈ ℕ⁺`, `n > c`): Number of rows in the model's input data.
- `m` (`m ∈ ℕ₀`): Number of groups in the input data's multi-hot encoding.
- `c` (`c ∈ ℕ⁺`, `c ≥ 2`): Dimensionality of the n-sphere node, where `2 ≤ c < n`.

# Initialization
`scale`, `mhoffset`, and `offset` are initialized as random numbers drawn from Ν(μ=0,σ²=1). 
`densein` and `denseout` are initialized according to `Flux.Dense`.

`n` dictates the number of rows in `scale`, `mhoffset`, `offset`, 
`denseout.weight`, `denseout.bias`, and the number of columns in `densein.weight`,
and must match the number of rows in the model's input data.

`m` dictates the number of columns in `scale` and `mhoffset`.

`c` dictates the number of rows in `densein.weight` and `densein.bias`, 
the number of columns in `denseout.weight`, and consequently the number of dimensions
in the hypersphere node.

When only `n` is provided, a model without multi-hot parameters, and with a
2-dimensional hypersphere node is initialized. To initialize a model without multi-hot
parameters, but with a c-dimensional hypersphere node, provide `n`, `m=0`, and `c`.

# Examples
```julia-repl
julia> Random.seed!; n = 5; cyclops(n)
cyclops(
    5x0 Matrix{Float32},                  # 0 parameters  (all zero)
    5x0 Matrix{Float32},                  # 0 parameters  (all zero)
    5x0 Matrix{Float32},                  # 0 parameters  (all zero)
    Dense(5 => 2),                        # 12 parameters
    Dense(2 => 5),                        # 15 parameters
)                   # Total: 7 arrays, 27 parameters, 468 bytes.

julia> Random.seed!; n = 5; m = 0; c = 4; cyclops(n, m, c)
cyclops(
    5x0 Matrix{Float32},                  # 0 parameters  (all zero)
    5x0 Matrix{Float32},                  # 0 parameters  (all zero)
    5x0 Matrix{Float32},                  # 0 parameters  (all zero)
    Dense(5 => 4),                        # 24 parameters
    Dense(4 => 5),                        # 25 parameters
)                   # Total: 7 arrays, 49 parameters, 556 bytes.

julia> Random.seed!; n = 5; m = 3; cyclops(n, m)
cyclops(
    5x3 Matrix{Float32},                  # 15 parameters
    5x3 Matrix{Float32},                  # 15 parameters
    5x1 Matrix{Float32},                  # 5 parameters
    Dense(5 => 2),                        # 12 parameters
    Dense(2 => 5),                        # 15 parameters
)                   # Total: 7 arrays, 62 parameters, 640 bytes.
```

# Errors
Throws:
- `CyclopsHypersphereDomainError` when `c < 2`
- `CyclopsInputAndHypersphereDomainError` when `n ≤ c`
- `CyclopsMultihotDomainError` when `m < 0`

# See also
[`CheckCyclopsConstructorInput`](@ref), [`CyclopsHypersphereDomainError`](@ref),
[`CyclopsInputAndHypersphereDomainError`](@ref), [`CyclopsMultihotDomainError`](@ref)
"""
struct cyclops
    scale::Array{Float32}
    mhoffset::Array{Float32}
    offset::AbstractVecOrMat{Float32}
    densein::Dense
    denseout::Dense

    function cyclops(n::Int, m::Int=0, c::Int=2)        
        CheckCyclopsConstructorInput(n, m, c)
        offset = m == 0 ? randn(Float32, n, m) : randn(Float32, n)

        return new(randn(Float32, n, m), randn(Float32, n, m), offset, Dense(n => c), Dense(c => n))
    end

    function cyclops(
        scale::AbstractArray{<:Real,2},
        mhoffset::AbstractArray{<:Real,2},
        offset::AbstractVecOrMat{<:Real},
        densein::Dense,
        denseout::Dense)

        offset32 = CheckCyclopsConstructorInput(scale, mhoffset, offset, densein, denseout)

        return new(Array{Float32}(scale), Array{Float32}(mhoffset), offset32, densein, denseout)
    end

end





#########################################
##### Parameter Count for Cyclops Model #
#########################################
"""
    nparams(m::cyclops)

Returns the total number of parameters in a `cyclops` model.

# See also
[`cyclops`](@ref)

# Examples
```julia-repl
julia> using Cyclops, Random

julia> Random.seed!(1234); covariate_cyclops_model = cyclops(5,3);

julia> nparams(covariate_cyclops_model)
62
```
"""
function nparams(m::cyclops)
    return 2*prod(size(m.scale)) + length(m.offset) + 2*prod(size(m.densein.weight)) + sum(size(m.densein.weight))
end