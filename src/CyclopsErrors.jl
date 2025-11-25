#############################
# Abstract Errors ###########
#############################
"""
```text
CyclopsError
│
├── CyclopsConstructorError
│      ├── CyclopsHypersphereDomainError
│      ├─── CyclopsInputAndHypersphereDomainError
│      ├──── CyclopsMultihotDomainError
│      ├───── CyclopsMultihotMatrixShapeError
│      ├────── CyclopsMultihotOffsetShapeError
│      ├─────── CyclopsDenseInverseShapeError
│      └──────── CyclopsDenseShapeError
│
└── CyclopsFunctionError
       ├── CyclopsMultihotDimensionMismatch
       ├─── CyclopsInputDimensionMismatch
       ├──── CyclopsHypersphereNaNError
       └───── CyclopsHypersphereDivideError
```
"""
abstract type CyclopsError <: Exception end

# Constructor Errors
abstract type CyclopsConstructorError <: CyclopsError end

# Function Errors
abstract type CyclopsFunctionError <: CyclopsError end
#                └── CyclopsMethodError





####################################
######### Hypersphere Domain Error #
####################################
"""
    CyclopsHypersphereDomainError(c::Int)

An error when `c < 2`.

# Examples
```julia-repl
julia> n = 5; m = 0; c = 1; cyclops(n, m, c)
ERROR: CyclopsHypersphereDomainError: `c` = 1, but `c` must be ≥ 2.
[...]
```

# Supertype Hierarchy
    CyclopsHypersphereDomainError <: CyclopsConstructorError <: CyclopsError <: Exception <: Any

# See also
[`CheckCyclopsConstructorInput`](@ref), [`CyclopsInputAndHypersphereDomainError`](@ref),
[`CyclopsMultihotDomainError`](@ref), [`cyclops`](@ref)
"""
struct CyclopsHypersphereDomainError <: CyclopsConstructorError 
    c::Int
end

Base.showerror(io::IO, e::CyclopsHypersphereDomainError) = begin
    print(io, "CyclopsHypersphereDomainError: `c` = $(e.c), but `c` must be ≥ 2.")
end





##############################################
######### Input And Hypersphere Domain Error #
##############################################
"""
    CyclopsInputAndHypersphereDomainError(n::Int, c::Int)

An error when `n ≤ c`.

# Examples
```julia-repl
julia> n = 5; m = 0; c = 5; cyclops(n, m, c)
ERROR: CyclopsInputAndHypersphereDomainError: `n` = 5 ≤ `c`, but `n` must be > 5.
[...]
```

# Supertype Hierarchy
    CyclopsInputAndHypersphereDomainError <: CyclopsConstructorError <: CyclopsError <: Exception <: Any

# See also
[`CheckCyclopsConstructorInput`](@ref), [`CyclopsHypersphereDomainError`](@ref),
[`CyclopsMultihotDomainError`](@ref), [`cyclops`](@ref)
"""
struct CyclopsInputAndHypersphereDomainError <: CyclopsConstructorError 
    n::Int
    c::Int
end

Base.showerror(io::IO, e::CyclopsInputAndHypersphereDomainError) = begin
    print(io, "CyclopsInputAndHypersphereDomainError: `n` = $(e.n) ≤ `c`, but `n` must be > $(e.c).")
end





#####################################
############# Multihot Domain Error #
#####################################
"""
    CyclopsMultihotDomainError(m::Int)

An error when `m < 0`.

# Examples
```julia-repl
julia> n = 5; m = -1; c = 3; cyclops(n, m, c)
ERROR: CyclopsMultihotDomainError: `m` = -1 < 0, but `m` must be ≥ 0
[...]
```

# Supertype Hierarchy
    CyclopsMultihotDomainError <: CyclopsConstructorError <: CyclopsError <: Exception <: Any

# See also
[`CheckCyclopsConstructorInput`](@ref), [`CyclopsHypersphereDomainError`](@ref),
[`CyclopsInputAndHypersphereDomainError`](@ref), [`cyclops`](@ref)
"""
struct CyclopsMultihotDomainError <: CyclopsConstructorError 
    m::Int
end

Base.showerror(io::IO, e::CyclopsMultihotDomainError) = begin
    print(io, "CyclopsMultihotDomainError: `m` = $(e.m) < 0, but `m` must be ≥ 0.")
end





#######################################
######### Multihot Matrix Shape Error #
#######################################
"""
    CyclopsMultihotMatrixShapeError(s::Tuple{Vararg{Int}}, o::Tuple{Vararg{Int}})

An error when the dimensions of scale do not match those of mhoffset.

# Examples
```julia-repl
julia> 
[...]
```

# Supertype Hierarchy
    CyclopsMultihotMatrixShapeError <: CyclopsConstructorError <: CyclopsError <: Exception <: Any

# See also
[`cyclops`](@ref), [`CheckCyclopsConstructorInput`](@ref)
"""
struct CyclopsMultihotMatrixShapeError <: CyclopsConstructorError 
    s::Tuple{Vararg{Int}}
    o::Tuple{Vararg{Int}}
end

Base.showerror(io::IO, e::CyclopsMultihotMatrixShapeError) = begin
    print(io, 
    "CyclopsMultihotMatrixShapeError: ",
    "scale and mhoffset do not have the same dimensions.",
    "\nscale has dimensions $(e.s) ≠ $(e.o) dimensions of mhoffset.")
end





###########################################
############# Multihot Offset Shape Error #
###########################################
"""
    CyclopsMultihotOffsetShapeError(s::Tuple{Vararg{Int}}, o::Tuple{Vararg{Int}})

An error when offset has the wrong dimensions.

# Examples
```julia-repl
julia>
[...]
```

# Supertype Hierarchy
    CyclopsMultihotOffsetShapeError <: CyclopsConstructorError <: CyclopsError <: Exception <: Any

# See also
[`cyclops`](@ref), [`CheckCyclopsConstructorInput`](@ref)
"""
struct CyclopsMultihotOffsetShapeError <: CyclopsConstructorError 
    s::Tuple{Vararg{Int}}
    o::Tuple{Vararg{Int}}
end

Base.showerror(io::IO, e::CyclopsMultihotOffsetShapeError) = begin
    print(io,
        "CyclopsMultihotOffsetShapeError: ",
        "expected dimensions $(e.s), ",
        "but got $(e.o)."
    )
end





#########################################
############# Dense Inverse Shape Error #
#########################################
"""
    CyclopsDenseInverseShapeError(comp::Tuple{Int, Int}, expan::Tuple{Int, Int})

An error when densein and denseout do not have inverse dimensions.

# Example
```julia-repl
julia>
[...]
```

# See also
[`cyclops`](@ref), [`CheckCyclopsConstructorInput`](@ref)
"""
struct CyclopsDenseInverseShapeError <: CyclopsConstructorError 
    din::Tuple{Int, Int}
    dout::Tuple{Int, Int}
end

Base.showerror(io::IO, e::CyclopsDenseInverseShapeError) = begin
    print(
        io,
        "CyclopsInverseDimensionMismatch: ",
        "dense in and dense out do not have inverse dimensions.\n",
        "Expected $(e.din[2]) => $(e.din[1]) compression ",
        "to be mirrored by $(e.din[1]) => $(e.din[2]) expansion, ",
        "but got $(e.dout[2]) => $(e.dout[1])."
    )
end





#################################
############# Dense Shape Error #
#################################
"""
    CyclopsDenseShapeError(d::Tuple{Varag{Int}})

An error when the shape of the dense layer is not a compression to ≥ 2 dimensions.

# Example
```julia-repl
```

# See also
[`cyclops`](@ref), [`CheckCyclopsConstructorInput`](@ref), [`CheckCyclopsConstructorInput`](@ref)
"""
struct CyclopsDenseShapeError <: CyclopsConstructorError 
    d::Tuple{Int, Int}
    s::Int
end

Base.showerror(io::IO, e::CyclopsDenseShapeError) = begin
    print(
        io,
        "CyclopsDenseShapeError: ",
        "dense compression must satisfy n => c ≥ 2, where n > c, ",
        "but got $(e.d[2]==e.s ? "" : "$(e.s) ≠ ")$(e.d[2]) => $(e.d[1])$(e.d[1]<2 ? " < 2" : "")."
    )
end






#######################
##### Function Errors #
#######################################
######### Multihot Dimension Mismatch #
#######################################
"""
    CyclopsMultihotDimensionMismatch(h::Vector{Int}, m::Array{Float32})

An error when the multi-hot encoding does not have as many rows as the multi-hot parameters has columns.
"""
struct CyclopsMultihotDimensionMismatch <: CyclopsFunctionError 
    h::Vector{Int}
    m::Array{Float32}
end

Base.showerror(io::IO, e::CyclopsMultihotDimensionMismatch) = begin
    print(io,
        "CyclopsMultihotDimensionMismatch: Multi-hot encoding `h` and multi-hot parameters do not have fitting dimensions.\n",
        "Multi-hot encoding must have as many rows as the multi-hot parameters have columns.\n",
        "Multi-hot encoding = $(length(e.h)) ≠ $(size(e.m, 2)) = Multi-hot Parameters\n"
    )
end





####################################
######### Input Dimension Mismatch #
####################################
"""
    CyclopsInputDimensionMismatch(x::Vector{Float32}, m::Array{Float32})

An error when `x` and `m` do not have the same number of rows.
"""
struct CyclopsInputDimensionMismatch <: CyclopsFunctionError 
    x::Vector{Float32}
    m::Array{Float32}
end

Base.showerror(io::IO, e::CyclopsInputDimensionMismatch) = begin
    print(io, 
        "CyclopsInputDimensionMismatch: Input `x` and multi-hot parameters do not have the same number of rows.\n", 
        "Input = $(length(e.x)) ≠ $(size(e.m, 1)) = Multi-hot Parameters\n"
    )
end





#################################
######### Hypershpere NaN Error #
#################################
"""
    CyclopsHypersphereNaNError()

An error when any of the inputs to the hypersphere node are `NaN`.

# Examples
```julia-repl
julia> hsn(Float32.([1, NaN]))
ERROR: CyclopsHypersphereNaNError: `NaN` at [2].
[...]
```

# See also
[`CheckHSNdomain`](@ref), [`CyclopsHypersphereDivideError`](@ref), [`cyclops`](@ref)
"""
struct CyclopsHypersphereNaNError <: CyclopsFunctionError
    x::Array{Float32}
end

Base.showerror(io::IO, e::CyclopsHypersphereNaNError) = begin
    print(
        io, 
        "CyclopsHypersphereNaNError: `NaN` at ", 
        findall(isnan, e.x)
    )
end





####################################
######### Hypershpere Divide Error #
####################################
"""
    CyclopsHypersphereDivideError()

An error when all of the inputs to the hypersphere node (`hsn`) are `0`.

# Examples
```julia-repl
julia> hsn(Float32.([0, 0]))
ERROR: CyclopsHypersphereDivideError: All values passed to the hypershpere node are `0`.
[...]
```

# See also
[`CheckHSNdomain`](@ref), [`CyclopsHypersphereDomainError`](@ref), [`cyclops`](@ref)
"""
struct CyclopsHypersphereDivideError <: CyclopsFunctionError end

Base.showerror(io::IO, e::CyclopsHypersphereDivideError) = begin
    print(
        io, 
        "CyclopsHypersphereDivideError: All values passed to the hypershpere node are `0`."
    )
end 