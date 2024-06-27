import Logging

struct TypstLogger <: Logging.AbstractLogger
    logs::Vector

    TypstLogger() = new([])
end

reset!(logger::TypstLogger) = empty!(logger.logs)

function Logging.handle_message(
    logger::TypstLogger, 
    level, message, _module, group, id, file, line; kwargs...
)
    processed_kwargs = Dict(
        string(kwarg.first) => find_best_representation(kwarg.second, [], false)
        for kwarg in kwargs
    )
    push!(
        logger.logs,
        Dict(
            "level" => level.level, 
            "message" => message, 
            "attached" => processed_kwargs
        )
    )
end

Logging.shouldlog(::TypstLogger, level, _module, group, id) = level >= Logging.Info
Logging.min_enabled_level(::TypstLogger) = Logging.Info

