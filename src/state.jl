@kwdef struct PkgState
    add_pkgs::Vector{Pkg.PackageSpec} = Pkg.PackageSpec[]
    dev_pkgs::Vector{Pkg.PackageSpec} = Pkg.PackageSpec[]
end

function Base.:(==)(p::PkgState, q::PkgState)
    # necessary because `hash` behaves unexpectedly with `PackageSpec`
    function vec_set_eq(a, b)
        # use `reshape` instead of `transpose` because it is not recursive
        eq = b .== reshape(a, 1, :)
        all(any(eq, dims = 1)) && all(any(eq, dims = 2))
    end

    vec_set_eq(p.add_pkgs, q.add_pkgs) && vec_set_eq(p.dev_pkgs, q.dev_pkgs)
end

@kwdef struct CodeCell
    code::String
    id::String
    display::Bool
    recompute::Bool
    preferredmimes::Vector{String}
end

@kwdef struct Evaluation
    result::FormattedResult
    stdout::String
    logs::Vector{Log}
    code::String
end


mutable struct JlyfishState
    typst_file::String
    typst_args::Vector{String}
    previous_query_str::String
    pkg::PkgState
    prev_pkg::PkgState
    code_cells::Vector{CodeCell}
    stdout_file::String
    logger::JlyfishLogger
    eval_module::Module
    evaluation_file::String
    evaluations::Dict{String, Evaluation}

    function JlyfishState(;
        evaluation_file::String,
        typst_file::String,
        typst_args::Vector{<: AbstractString}
    )
        if isfile(evaluation_file)
            json = read(evaluation_file, String)
            evaluations = JSON3.read(json, Dict{String, Evaluation})
        else
            evaluations = Dict{String, Evaluation}()
        end

        new(
            typst_file,
            typst_args,
            "",
            PkgState(),
            PkgState(),
            CodeCell[],
            tempname(),
            JlyfishLogger(),
            Module(gensym("JlyfishEval")),
            evaluation_file,
            evaluations,
        )
    end
end
