####################################
##### Check Hypersphere Node Input #
####################################
"""
    CheckHSNdomain(x::Vector{Float32})

Checks domains of values in `x` and returns `nothing` when none of the values are `NaN` or at least one value is not `0`.

# Errors
- `CyclopsHypersphereDomainError`: when any value in `x` is `NaN`
- `CyclopsHypersphereDivideError`: when all values in `x` are `0`

# See also
[`CyclopsHypersphereDomainError`](@ref), [`CyclopsHypersphereDivideError`](@ref),
[`hsn`](@ref), [`cyclops`](@ref)

# Examples
```julia-repl
julia> CheckHSNdomain([1f0, 1f0])

julia> CheckHSNdomain([1, NaN])
```
"""
function CheckHSNdomain(x::Vector{Float32})
    any(isnan.(x)) && throw(CyclopsHypersphereNaNError(x))
    all(x .== 0) && throw(CyclopsHypersphereDivideError())

    return nothing
end





#######################
##### Hyperspher Node #
#######################
"""
    hsn(x::Vector{Float32})

Returns the element-wise quotient of `x` and its Euclidean norm.

    ‖x‖₂ = √(∑(xᵢ²))
    x̂ → x / ‖x‖₂

Output has the same dimensions as input.

# Errors
- Throws a `CyclopsHypersphereDomainError` if any element of `x` is `NaN`.
- Throws a `CyclopsHypersphereDivideError` if all elements of `x` are `0`.

# Examples
```julia-repl
julia> atan(1, 1)*180/pi # Angle in degrees for the direction vector [1, 1]
45.0

julia> hsn_output = hsn(Float32.([1, 1])) # Direction vector normalized to unit vector
2-element Vector{Float32}:
    0.70710677
    0.70710677

julia> atan(hsn_output...)*180/pi # Angle of direction vector is retained
45.0f0
```

# See also 
[`cyclops`](@ref), [`mhe`](@ref), [`mhd`](@ref), [`nparams`](@ref),
[`CyclopsHypersphereDomainError`](@ref), [`CyclopsHypersphereDivideError`](@ref), 
[`CheckHSNdomain`](@ref)
"""
function hsn(x::Vector{Float32})::Array{Float32}
    CheckHSNdomain(x)
    return x ⊘ sqrt(sum(x ⩕ 2))
end





###############################
##### Multihot Encoding layer #
###############################
"""
    mhe(x::Vector{Float32}, h::Vector{Int32}, m::cyclops)

Returns `x` in 'multi-hot'-encoded space.

    x ⊙ (1 + m.scale ⊗ h) + m.mhoffset ⊗ h + m.offset

Inverse of [`mhd`](@ref).

# Operations
- `⊙` is element-wise matrix multiplication
- `⊗` is matrix multiplication

# See also
[`cyclops`](@ref), [`mhd`](@ref), [`hsn`](@ref), [`nparams`](@ref),
[`⊕`](@ref), [`⊖`](@ref), [`⊙`](@ref), [`⊗`](@ref), [`⊘`](@ref), [`⩕`](@ref)

# Examples
```julia-repl
julia> using Cyclops, Random

julia> Random.seed!(1234);

julia> covariate_cyclops_model = cyclops(5,3)

julia> Random.seed!(1234);

julia> x = rand(Float32, 5)
5-element Vector{Float32}:
    0.72619927
    0.32597667
    0.30699807
    0.5490511
    0.7889189

julia> h = [1, 0, 1];

julia> mhe_transform = mhe(x, h, covariate_cyclops_model)
5-element Vector{Float32}:
    2.1732361
    2.2111228
    2.8991385
    3.2093358
    4.121205

julia> mhd_recovery = mhd(mhe_transform, h, covariate_cyclops_model)
5-element Vector{Float32}:
    0.7261993
    0.32597664
    0.30699813
    0.5490511
    0.7889189

julia> isapprox(x, mhd_recovery, atol=1E-6)
true
```
"""
function mhe(input_data::Vector{Float32}, multihot::Vector{Int32}, m::cyclops; skip_check=false)::Array{Float32}
    skip_check || CheckCyclopsInput(input_data, multihot, m.scale)
    
    return input_data ⊙ (1 ⊕ (m.scale ⊗ multihot)) ⊕ (m.mhoffset ⊗ multihot) ⊕ reshape(m.offset, length(input_data))
end





###############################
##### Multihot Decoding Layer #
###############################
"""
    mhd(x::Vector{Float32}, h::Vector{Int32}, m::cyclops)

Restores `x` from 'multi-hot'-encoded space.

    (x - m.mhoffset ⊗ h - m.offset) ⊘ (1 + m.scale ⊗ h)

Inverse of [`mhe`](@ref).

# Operations
- `⊘` is element-wise matrix division
- `⊗` is matrix multiplication

# See also
[`cyclops`](@ref), [`mhe`](@ref), [`hsn`](@ref), [`nparams`](@ref)

# Examples 
```julia-repl
julia> using Cyclops, Random

julia> Random.seed!(1234);

julia> covariate_cyclops_model = cyclops(5,3)

julia> Random.seed!(1234);

julia> x = rand(Float32, 5)
5-element Vector{Float32}:
    0.72619927
    0.32597667
    0.30699807
    0.5490511
    0.7889189

julia> h = [1, 0, 1];

julia> mhe_transform = mhe(x, h, covariate_cyclops_model)
5-element Vector{Float32}:
    2.1732361
    2.2111228
    2.8991385
    3.2093358
    4.121205

julia> mhd_recovery = mhd(mhe_transform, h, covariate_cyclops_model)
5-element Vector{Float32}:
    0.7261993
    0.32597664
    0.30699813
    0.5490511
    0.7889189

julia> isapprox(x, mhd_recovery, atol=1E-6)
true
```
"""
function mhd(dense_decoding::Vector{Float32}, multihot::Vector{Int32}, m::cyclops; skip_check=false)::Array{Float32}
    skip_check || CheckCyclopsInput(dense_decoding, multihot, m.scale)

    return (dense_decoding ⊖ (m.mhoffset ⊗ multihot) ⊖ reshape(m.offset, length(dense_decoding))) ⊘ (1 ⊕ (m.scale ⊗ multihot))
end