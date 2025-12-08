module TypstJlyfish

import Typst_jll
import JSON3
using Base64
import Pkg
import BetterFileWatching
import Dates
using Colors
using StyledStrings

struct SkipCodeCell end
struct StopRunning end
struct ContinueRunning end
struct WaitForChange end
const HowToProceed = Union{
    SkipCodeCell,
    StopRunning,
    ContinueRunning,
    WaitForChange,
}

include("preamble.jl")
include("output.jl")
include("logging.jl")
include("state.jl")
include("pkg.jl")
include("query.jl")
include("evaluation.jl")
include("watch.jl")
include("compile.jl")
include("app.jl")

end
