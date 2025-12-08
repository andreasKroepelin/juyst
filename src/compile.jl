function compile(
    typst_file;
    typst_query_args = "",
    typst_compile_args = "",
    evaluation_file = default_output_file(typst_file),
)
    Pkg.activate(mktempdir(prefix = "jlyfish-eval"))

    jlyfish_state = JlyfishState(;
        evaluation_file,
        typst_file,
        typst_args = split(typst_query_args),
    )

    try
        execute!(jlyfish_state)
    catch e
        if e isa StopRunning
            return
        elseif e isa WaitForChange
        else
            throw(e)
        end
    end

    compile_cmd = ```
        $(Typst_jll.typst())
        compile
        $(split(typst_compile_args))
        $(jlyfish_state.typst_file)
    ```
    @info "Compiling document..."
    try
        run(compile_cmd)
    catch e
        if e isa InterruptException
        elseif e isa ProcessFailedException
            @info "Typst compile failed."
        else
            throw(e)
        end
    end

    @info "Done."
end
