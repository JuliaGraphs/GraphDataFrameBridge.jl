# DataFrameGraphs.jl

Tools for interoperability between DataFrame objects and LightGraphs and MetaGraphs objects.

## Examples:

```
using DataFrameGraphs
df = DataFrame(Dict("start" => ["a", "b", "a", "d"],
                    "finish" => ["b", "c", "e", "e"],
                    "weights" => 1:4,
                    "extras" => 5:8))

# Simple undirected MetaGraph
mg = metagraph_from_dataframe(df, :start, :finish, MetaGraph)

# Simple directed MetaDiGraph
mdg = metagraph_from_dataframe(df, :start, :finish, MetaDiGraph)

# MetaGraph with `weight` attribute set and
# `:extras` values stored as attributes.
mgw = metagraph_from_dataframe(df, :start, :finish, MetaGraph,
                               weight=:weights,
                               edge_attributes=:extras)


```
