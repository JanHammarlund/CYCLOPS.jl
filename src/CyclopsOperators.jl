"""
    ⊙(x::Union{Number, AbstractArray{<:Number}}, y::Union{Number, AbstractArray{<:Number}})
    ⊙(x::Number, y::Union{Number,AbstractArray{<:Number}})
    ⊙(x::AbstractArray{<:Number}, y::Number)
    ⊙(x, y)
    x ⊙ y

Returns the element-wise product.

See also [`⊖`](@ref), [`⊗`](@ref), [`⊘`](@ref), [`⩕`](@ref)

# Examples
```julia-repl
julia> ⊙(3, 4)
12

julia> 3 ⊙ 4
12

julia [0, 1] ⊙ [3, 6]
2-element Vector{Int64}:
    0
    6
```

# Errors
- If `x` or `y` has only one column, throws a `DimensionMismatch` when `x` and `y` 
    don't have the same number of rows.
- If `x` and `y` both have more than one column, throws a `DimensionMismatch` when 
    `x` and `y` don't have the same dimensions.

```julia-repl
julia> [0, 1] ⊙ [3, 6, 5]
ERROR: DimensionMismatch: x and y don't have matching number of rows.
x has 2 and y has 3.
[...]
```

See also [`⊖`](@ref), [`⊘`](@ref), [`⊗`](@ref), [`⊕`](@ref), [`⩕`](@ref)
"""
function ⊙(x::Number, y::AbstractArray{<:Number})::Array{Float32}
    return x * y
end

function ⊙(x::AbstractArray{<:Number}, y::Number)::Array{Float32}
    return x * y
end

function ⊙(x::AbstractArray{<:Number}, y::AbstractArray{<:Number})::Array{Float32}
    if (size(x, 2) == 1) || (size(y, 2) == 1)
        size(x, 1) == size(y, 1) || throw(DimensionMismatch("x and y don't have the same number of rows.\nx has $(size(x, 1)) and y has $(size(y, 1))."))
    else
        size(x) == size(y) || throw(DimensionMismatch("x and y don't have matching dimensions.\nx has $(size(x)) and y has $(size(y))."))
    end
    return x .* y
end

"""
    ⊗(x::AbstractArray{<:Number}, y::Union{Number, AbstractArray{<:Number}})
    ⊗(x, y)
    x ⊗ y

Returns the matrix product.

# Examples

    A ⊗ B

where `A` is a `p × q` matrix, `B` is a `q × r` matrix, and the result is `p × r` matrix.

```julia-repl
julia> Random.seed!(1234); ⊗(rand(Float32, 5,3), [1, 0, 1])
5-element Vector{Float32}:
    1.0497425
    0.720232
    0.5075845
    1.5021757
    0.8831669

julia> Random.seed!(1234); rand(Float32, 5,3) ⊗ [1, 0, 1]
5-element Vector{Float32}:
    1.0497425
    0.720232
    0.5075845
    1.5021757
    0.8831669
```

# Errors
Throws a `DimensionMismatch` when `x` and `y` have incompatible dimensions. `x` must have as many
columns as `y` has rows.

```julia-repl
julia> Random.seed!(1234); rand(Float32, 5,3) ⊗ [1, 0]
ERROR: DimensionMismatch: x and y don't have compatible dimensions. y must have a many rows as x has columns.
x has 3 columns and y has 5 rows.
[...]
```

See also [`⊖`](@ref), [`⊘`](@ref), [`⊙`](@ref), [`⊕`](@ref), [`⩕`](@ref)
"""
function ⊗(x::AbstractArray{<:Number}, y::Union{Number, AbstractArray{<:Number}})::Array{Float32}
    size(x, 2) == size(y, 1) || throw(DimensionMismatch("x and y don't have compatible dimensions. y must have a many rows as x has columns.\nx has $(size(x, 2)) columns and y has $(size(y, 1)) rows."))
    return x * y
end

"""
    ⊕(x::Union{Number, AbstractArray{<:Number}}, y::Union{Number, AbstractArray{<:Number}})
    ⊕(x, y)
    x ⊕ y

Returns the element-wise sum.

# Errors
- If `x` or `y` has only one column, throws a `DimensionMismatch` when `x` and `y` 
    don't have the same number of rows.
- If `x` and `y` both have more than one column, throws a `DimensionMismatch` when 
    `x` and `y` don't have the same dimensions.

# Examples
```julia-repl
julia> 5 ⊕ 5
10

julia> 5 ⊕ [3, 4]
2-element Vector{Int64}:
    8
    9

julia> [4, 2] ⊕ [6, 8]
2-element Vector{Int64}:
    10
    10

julia> [4, 2] ⊕ [6 8; 2 4]
2×2 Matrix{Int64}:
    10  12
    4   6
```

See also [`⊖`](@ref), [`⊘`](@ref), [`⊙`](@ref), [`⊗`](@ref), [`⩕`](@ref)
"""
function ⊕(x::AbstractArray{<:Number}, y::AbstractArray{<:Number})
    if (size(x, 2) == 1) || (size(y, 2) == 1)
        size(x, 1) == size(y, 1) || throw(DimensionMismatch("x and y don't have the same number of rows.\nx has $(size(x, 1)) and y has $(size(y, 1))."))
    else
        size(x) == size(y) || throw(DimensionMismatch("x and y don't have matching dimensions.\nx has $(size(x)) and y has $(size(y))."))
    end
    return x .+ y
end

function ⊕(x::Number, y::AbstractArray{<:Number})
    return x .+ y
end

function ⊕(x::AbstractArray{<:Number}, y::Number)
    return x .+ y
end

"""
    ⊖(x::Union{Number, AbstractArray{<:Number}}, y::Union{Number, AbstractArray{<:Number}})
    ⊖(x, y)
    x ⊖ y

Returns the element-wise difference.

# Errors
- If `x` or `y` has only one column, throws a `DimensionMismatch` when `x` and `y` 
    don't have the same number of rows.
- If `x` and `y` both have more than one column, throws a `DimensionMismatch` when 
    `x` and `y` don't have the same dimensions.

# Examples
```julia-repl
julia> 5 ⊖ 4
1

julia> [5, 2] ⊖ 3
2-element Vector{Int64}:
    2
    -1

julia> [5, 2] ⊖ [-4, 2]
2-element Vector{Int64}:
    9
    0

julia> [5, 2] ⊖ [-4 2; 9 -13]
2×2 Matrix{Int64}:
    9   3
    -7  15
```

See also [`⊕`](@ref), [`⊘`](@ref), [`⊙`](@ref), [`⊗`](@ref), [`⩕`](@ref)
"""
function ⊖(x::AbstractArray{<:Number}, y::AbstractArray{<:Number})
    if (size(x, 2) == 1) || (size(y, 2) == 1)
        size(x, 1) == size(y, 1) || throw(DimensionMismatch("x and y don't have the same number of rows.\nx has $(size(x, 1)) and y has $(size(y, 1))."))
    else
        size(x) == size(y) || throw(DimensionMismatch("x and y don't have matching dimensions.\nx has $(size(x)) and y has $(size(y))."))
    end
    return x .- y
end

function ⊖(x::Number, y::AbstractArray{<:Number})
    return x .- y
end

function ⊖(x::AbstractArray{<:Number}, y::Number)
    return x .- y
end

"""
    ⊘(x::Union{Number, AbstractArray{<:Number}}, y::Union{Number, AbstractArray{<:Number}})
    ⊘(x, y)
    x ⊘ y

Returns the element-wise quotient.

# Errors
- If `x` or `y` has only one column, throws a `DimensionMismatch` when `x` and `y` 
    don't have the same number of rows.
- If `x` and `y` both have more than one column, throws a `DimensionMismatch` when 
    `x` and `y` don't have the same dimensions.

# Examples
```julia-repl
julia> 3 ⊘ 4
0.75

julia> [3, 4] ⊘ [3, 2]
2-element Vector{Float64}:
    1.0
    2.0
```

See also [`⊕`](@ref), [`⊖`](@ref), [`⊙`](@ref), [`⊗`](@ref), [`⩕`](@ref)
"""
function ⊘(x::AbstractArray{<:Number}, y::AbstractArray{<:Number})
    if (size(x, 2) == 1) || (size(y, 2) == 1)
        size(x, 1) == size(y, 1) || throw(DimensionMismatch("x and y don't have the same number of rows.\nx has $(size(x, 1)) and y has $(size(y, 1))."))
    else
        size(x) == size(y) || throw(DimensionMismatch("x and y don't have matching dimensions.\nx has $(size(x)) and y has $(size(y))."))
    end
    return x ./ y
end

function ⊘(x::Number, y::AbstractArray{<:Number})
    return x ./ y
end

function ⊘(x::AbstractArray{<:Number}, y::Number)
    return x ./ y
end

"""
    ⩕(x::AbstractArray{<:Number}, y::Number)
    ⩕(x, y)
    x ⩕ y

Returns the element-wise power.

# Examples
```julia-repl
julia> [1, 2] ⩕ 2
2-element Vector{Int64}:
    1
    4
```

See also [`⊕`](@ref), [`⊖`](@ref), [`⊙`](@ref), [`⊗`](@ref), [`⊘`](@ref)
"""
function ⩕(x::AbstractArray{<:Number}, y::Number)
    return x .^ y
end