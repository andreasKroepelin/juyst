const APP_HELP = styled"""
{(foreground=$julia_blue_hex):$APP_NAME help}
    Prints this help message.

{(foreground=$julia_blue_hex):$APP_NAME version}
    Prints the version of this application.

{(foreground=$julia_blue_hex):$APP_NAME watch path/to/file.typ options...}
    Runs a watcher for the specified Typst file.
    Run {(foreground=$julia_blue_hex):$APP_NAME watch help} for more details.
"""

"""
Constructed at https://patorjk.com/software/taag/.

TODO: Resemble logo.
"""
const LOGO_ART = styled"""
{(foreground=$julia_blue_hex):       dP dP          .8888b oo          dP
       88 88          88   "             88
       88 88 dP    dP 88aaa  dP .d8888b. 88d888b.
       88 88 88    88 88     88 Y8ooooo. 88'  `88
88.  .d8P 88 88.  .88 88     88       88 88    88
 `Y8888'  dP `8888P88 dP     dP `88888P' dP    dP
                  .88
              d8888P}
"""

function (@main)(args)
    if isempty(args)
        println(LOGO_ART)
        println(styled"Run {(foreground=$julia_blue_hex):jlyfish help} for usage.")
        return
    end

    command = popfirst!(args)

    if command == "help"
        print(APP_HELP)

    elseif command == "version"
        println(PKG_VERSION)

    elseif command == "watch"
        app_watch(args)

    # elseif command == "compile"
    #     app_compile(args)

    else
        styled"""
        Unrecognised command: {(foreground=$julia_blue_hex):$command}.
        Run {(foreground=$julia_blue_hex):$APP_NAME help} for a list of commands.
        """ |> print
    end
end
