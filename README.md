# GraphDataFrameBridge.jl

Tools for interoperability between DataFrame objects and LightGraphs and MetaGraphs objects.

## Examples:

```julia
julia> using DataFrames
julia> using GraphDataFrameBridge

julia> df = DataFrame(Dict("start" => ["a", "b", "a", "d"],
                           "finish" => ["b", "c", "e", "e"],
                           "weights" => 1:4,
                           "extras" => 5:8))

# Simple undirected MetaGraph
julia> mg = MetaGraph(df, :start, :finish)
{5, 4} undirected Int64 metagraph with Float64 weights defined by :weight (default weight 1.0)

julia> props(mg, 1)
Dict Symbol → Any with 1 entries
  :name → "a"

# Simple directed MetaDiGraph
julia> mdg = MetaDiGraph(df, :start, :finish)
{5, 4} directed Int64 metagraph with Float64 weights defined by :weight (default weight 1.0)

# MetaGraph with `weight` attribute set and
# `:extras` values stored as attributes.
julia> mgw = MetaGraph(df, :start, :finish,
                       weight=:weights,
                       edge_attributes=:extras)
{5, 4} undirected Int64 metagraph with Float64 weights defined by :weight (default weight 1.0)

julia> props(mgw, 1, 2)
Dict Symbol → Any with 2 entries
  :extras → 5
  :weight → 1
```

## Updating Release:

Note to self: update version in `Project.toml`, then comment on commit `@JuliaRegistrator register`