![logo](assets/logo.svg)

Juyst is a package for Julia and Typst that allows you to integrate Julia
computations in your Typst document.

> [!NOTE]
> Juyst works but is currently neither officially registered as a Julia or
> Typst package, nor is this readme complete.
> If you know your way around Julia and Typst you will find ways to try it out,
> I guess :)

You should use Juyst if you want to write a Typst document and have some of the
content automatically produced but want the source code for that within your
document source.
It fills a similar role as [PythonTeX](https://github.com/gpoore/pythontex)
does for Python and LaTeX.
Note that this is different from tools like [Quarto](https://quarto.org/) where
you write documents in Markdown, also integrate some Julia code, but then might
use Typst only as a backend to produce the final document.

# Getting started

Since Juyst builds a bridge between Julia and Typst, we also have to get two
things running.
First, install the Julia package `Juyst` from the general registry by executing
```julia-repl
julia> ]

(@v1.10) pkg> add Juyst
```
You only have to do this once.
(It is like installing and using the Pluto notebook system, if you are familiar
with that.)

When you want to use Juyst in a Typst document (say, `your-document.typ`),
add the following line at the top:
```typ
#import "@preview/juyst:0.1.0": *
```
Then, open a Julia REPL and run
```julia-repl
julia> import Juyst

julia> Juyst.watch("your-document.typ")
```

Juyst facilitates the communication between Julia and Typst via a JSON file.
By default, Juyst uses the name of your document and adds a `-juyst.json`, so
`your-document.typ` would become `your-document-juyst.json`.
This can be configured, of course.

To let Typst know of the computed data in the JSON file, add the following line
to your document:
```typ
#read-julia-output(json("your-document-juyst.json"))
```

You can then place some Julia code in your Typst source using the `#jl`
function:
```typ
What is the sum of the whole numbers from one to a hundred? #jl(`sum(1:100)`)
```

Head over to the [wiki](https://github.com/andreasKroepelin/juyst/wiki) to
learn more!

# Showcase

Just to show what is possible with Juyst:
