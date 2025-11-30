"""
    ⊙(x::AbstractVector{T}, y::AbstractVector{T}) where T <: AbstractFloat
    ⊙(x::T, y::AbstractVector{T}) where T <: AbstractFloat
    ⊙(x::AbstractVector{T}, y::T) where T <: AbstractFloat
    ⊙(x, y)
    x ⊙ y

Returns the element-wise product.

See also [`⊖`](@ref), [`⊘`](@ref), [`⊗`](@ref), [`⊕`](@ref), [`⩕`](@ref)
"""
function ⊙(x::AbstractVector{T}, y::AbstractVector{T}) where T <: AbstractFloat
    return x .* y
end

"""
    ⊗(x::AbstractMatrix{Tx}, y::AbstractVector{Ty}) where {Tx <: AbstractFloat, Ty <: Real}
    ⊗(x, y)
    x ⊗ y

Returns the matrix product.

See also [`⊖`](@ref), [`⊘`](@ref), [`⊙`](@ref), [`⊕`](@ref), [`⩕`](@ref)
"""
function ⊗(x::AbstractMatrix{Tx}, y::AbstractVector{Ty}) where {Tx <: AbstractFloat, Ty <: Real}
    return x * y
end

"""
    ⊕(x::Union{Number, AbstractArray{T}}, y::Union{Number, AbstractArray{T}})
    ⊕(x, y)
    x ⊕ y

Returns the element-wise sum.

See also [`⊖`](@ref), [`⊘`](@ref), [`⊙`](@ref), [`⊗`](@ref), [`⩕`](@ref)
"""
function ⊕(x::AbstractVector{T}, y::AbstractVector{T}) where T <: AbstractFloat
    return x .+ y
end

function ⊕(x::Tx, y::AbstractVector{Ty}) where {Tx <: Real, Ty <: AbstractFloat}
    return x .+ y
end

"""
    ⊖(x::Union{Number, AbstractArray{T}}, y::Union{Number, AbstractArray{T}})
    ⊖(x, y)
    x ⊖ y

Returns the element-wise difference.

See also [`⊕`](@ref), [`⊘`](@ref), [`⊙`](@ref), [`⊗`](@ref), [`⩕`](@ref)
"""
function ⊖(x::AbstractVector{T}, y::AbstractVector{T}) where T <: AbstractFloat
    return x .- y
end

"""
    ⊘(x::AbstractVector{T}, y::AbstractVector{T})
    ⊘(x::T, y::AbstractVector{T})
    ⊘(x::AbstractVector{T}, y::T)
    ⊘(x, y)
    x ⊘ y

Returns the element-wise quotient.

See also [`⊕`](@ref), [`⊖`](@ref), [`⊙`](@ref), [`⊗`](@ref), [`⩕`](@ref)
"""
function ⊘(x::AbstractVector{T}, y::AbstractVector{T}) where T <: AbstractFloat
    return x ./ y
end

function ⊘(x::AbstractVector{T}, y::T) where T <: AbstractFloat
    return x ./ y
end

"""
    ⩕(x::AbstractArray{T}, y::Number)
    ⩕(x, y)
    x ⩕ y

Returns the element-wise power.

See also [`⊕`](@ref), [`⊖`](@ref), [`⊙`](@ref), [`⊗`](@ref), [`⊘`](@ref)
"""
function ⩕(x::AbstractVector{Tx}, y::Ty) where {Tx <: AbstractFloat, Ty <: Integer}
    return x .^ y
end