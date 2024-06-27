@kwdef struct FormattedResult
    mime::MIME
    failed::Bool
    data::Any
end


function find_best_representation(result, preferred_mimes, failed)
    mimes = MIME.([
        "text/typst",
        "image/svg+xml",
        "image/png",
        "image/jpg",
        "text/plain",
    ])
    preference(m) = something(
        findfirst(==(string(m)), preferred_mimes),
        length(preferred_mimes) + 1
    )
    sort!(mimes, by = preference)

    for mime in mimes
        (@invokelatest showable(mime, result)) || continue

        iob = IOBuffer()
        @invokelatest show(iob, mime, result)
        bytes = take!(iob)
        return FormattedResult(;
            mime,
            data = startswith(string(mime), "text/") ? String(bytes) : bytes,
            failed,
        )
    end

    # no MIME worked
    FormattedResult(
        mime = MIME"text/plain"(),
        data = "!! Result could not be displayed !!",
        failed = true
    )
    
end

function is_allowed_type(T)
    valtype(::Type{Dict{String, V}}) where V = V
    primitives = [
        String, Integer, Bool, Char, Float64, Float32, Nothing
    ]
    if any(T .<: primitives)
        return true
    elseif T <: Vector
        return is_allowed_type(eltype(T))
    elseif T <: Dict{String}
        return is_allowed_type(valtype(T))
    else
        return false
    end
end

function truncate_code(code, n)
    chars = Vector{Char}(code)
    if length(chars) <= n
        code
    else
        join(chars[1:n - 3]) * "..."
    end
end


function default_cbor_file(typst_file)
    @assert endswith(typst_file, ".typ") "given Typst file does not end with .typ"
    base, _suffix = splitext(typst_file)
    base * "-juyst.cbor"
end

