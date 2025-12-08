function watch(
    typst_file;
    typst_args = "",
    evaluation_file = default_output_file(typst_file),
    watch_path = typst_file,
)
    @assert isfile(typst_file) "`$typst_file` does not exist."
    @assert ispath(watch_path) "`$watch_path` does not exist."

    Pkg.activate(mktempdir(prefix = "jlyfish-eval"))

    jlyfish_state = JlyfishState(;
        evaluation_file,
        typst_file,
        typst_args = split(typst_args),
    )

    while true
        @info Dates.format(Dates.now(), "HH:MM:SS")

        try
            execute!(jlyfish_state)
        catch e
            if e isa StopRunning
                break
            elseif e isa WaitForChange
            else
                throw(e)
            end
        end

        @info "Waiting for input to change..."
        try
            BetterFileWatching.watch_file(watch_path)
        catch e
            if e isa InterruptException
                break
            else
                throw(e)
            end
        end
    end

    @info "Stopping Jlyfish. Bye!"
end

const APP_WATCH_HELP = styled"""
{(foreground=$julia_blue_hex):$APP_NAME watch help}
    Prints this help message.

Positional:

{(foreground=$julia_blue_hex):$APP_NAME watch path/to/file.typ}
    The {(foreground=$julia_blue_hex):file.typ} is expected to use the jlyfish package in the Typst universe.
    Sets up a watcher for changes to {(foreground=$julia_blue_hex):file.typ}.
    Upon detecting changes:
    1. Evaluates the Julia code in {(foreground=$julia_blue_hex):file.typ}.
    2. Updates {(foreground=$julia_blue_hex):file.typ} with the Julia code results.

Keywords (any order):

{(foreground=$julia_blue_hex):$APP_NAME watch path/to/file.typ watch=any/path}
    Sets up a watcher for {(foreground=$julia_blue_hex):any/path}.
    {(foreground=$julia_blue_hex):any/path} can be a directory or a file.
    Defaults to {(foreground=$julia_blue_hex):path/to/file.typ}

{(foreground=$julia_blue_hex):$APP_NAME watch path/to/file.typ eval=path/to/eval.json}
    Specify the {(foreground=$julia_blue_hex):path/to/eval.json} that stores the evaluated Julia code.
    Defaults to {(foreground=$julia_blue_hex):path/to/file$eval_ext}

Others:

{(foreground=$julia_blue_hex):$APP_NAME watch path/to/file.typ any other args}
    Passes {(foreground=$julia_blue_hex):any other args} to the {(foreground=$julia_blue_hex):typst} CLI.
"""

const APP_WATCH_FULL_OPTION_NAMES = Dict(
    "args" => :typst_args,
    "eval" => :evaluation_file,
    "watch" => :watch_path,
)

function app_watch(args)
    if isempty(args)
        """
        Requires a typst file, e.g.
        jlyfish watch path/to/file.typ
        
        Run `jlyfish watch help` for more info.
        """

        return
    end

    if first(args) == "help"
        print(APP_WATCH_HELP)
        return
    end

    string(
        "Cannot `CTRL + C` out of the `jlyfish` app during watch.",
        " Needs further investigation."
    ) |> error

    typst_file = popfirst!(args)

    options = Dict{String, String}()
    for option in filter(!=("args"), APP_WATCH_FULL_OPTION_NAMES |> keys)
        haskey(options, option) && continue

        index = findfirst(
            occursin("^$option" |> Regex),
            args
        )

        isnothing(index) && continue

        options[option] = match(
            "$option=(\\S+)" |> Regex,
            popfirst!(args)
        ).captures |> first
    end
    options["args"] = join(args, " ")

    options_kw = NamedTuple(
        APP_WATCH_FULL_OPTION_NAMES[key] => value
        for (key, value) in options
    )

    watch(typst_file; options_kw...)
end


