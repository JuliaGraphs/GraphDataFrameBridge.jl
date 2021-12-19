module GraphDataFrameBridge
using Graphs
using MetaGraphs
using DataFrames
export MetaGraph, MetaDiGraph

import MetaGraphs.MetaGraph
import MetaGraphs.MetaDiGraph


function MetaGraph(
    df::DataFrame,
    origin::Symbol,
    destination::Symbol;
    weight::Symbol = Symbol(),
    edge_attributes::Union{Vector{Symbol},Symbol} = Vector{Symbol}(),
    vertex_attributes::DataFrame = DataFrame(),
    vertex_id_col::Symbol = Symbol())

    """
        MetaGraph(df, origin, destination)
        MetaGraph(df, origin, destination,
                  weight, edge_attributes,
                  vertex_attributes, vertex_id_col)

    Creates a MetaGraph from a DataFrame and stores node names as properties.

    `df` is DataFrame formatted as an edgelist
    `origin` is column symbol for origin of each edge
    `destination` is column symbol for destination of each edge

    Will create a MetaGraph with a `name` property that stores node labels
    used in `origin` and `destination`. `name` is also set as an index property
    using `set_indexing_prop!`.

    Note if `df` contains duplicated edge entries, the last record will
    overwrite previous entries.

    Optional keyword arguments:

    `weight` is column symbol to be used to set weight property.
    `edge_attributes` is a `Symbol` of `Vector{Symbol}` of columns whose values
    will be added as edge properties.
    `vertex_attributes` is a DataFrame containing additional information on vertices.
    `vertex_id_col` is a symbol referring to the column in `vertex_attributes`
    that contains the names of vertices as used in `df``. If it is not specified,
    the first column will be used.
    """

    metagraph_from_dataframe(MetaGraph, df, origin, destination, weight, edge_attributes, vertex_attributes, vertex_id_col)

end


function MetaDiGraph(
    df::DataFrame,
    origin::Symbol,
    destination::Symbol;
    weight::Symbol = Symbol(),
    edge_attributes::Union{Vector{Symbol},Symbol} = Vector{Symbol}(),
    vertex_attributes::DataFrame = DataFrame(),
    vertex_id_col::Symbol = Symbol())

    """
        MetaDiGraph(df, origin, destination)
        MetaDiGraph(df, origin, destination,
                    weight, edge_attributes,
                    vertex_attributes, vertex_id_col)

    Creates a MetaDiGraph from a DataFrame and stores node names as properties.

    `df` is DataFrame formatted as an edgelist
    `origin` is column symbol for origin of each edge
    `destination` is column symbol for destination of each edge

    Will create a MetaDiGraph with a `name` property that stores node labels
    used in `origin` and `destination`.

    Note if `df` contains duplicated edge entries, the last record will
    overwrite previous entries.

    Optional keyword arguments:

    `weight` is column symbol to be used to set weight property.
    `edge_attributes` is a `Symbol` of `Vector{Symbol}` of columns whose values
    will be added as edge properties.
    `vertex_attributes` is a DataFrame containing additional information on vertices.
    `vertex_id_col` is a symbol referring to the column in `vertex_attributes`
    that contains the names of vertices as used in `df``. If it is not specified,
    the first column will be used.
    """

    metagraph_from_dataframe(MetaDiGraph, df, origin, destination, weight, edge_attributes, vertex_attributes, vertex_id_col)

end


function metagraph_from_dataframe(graph_type,
    df::DataFrame,
    origin::Symbol,
    destination::Symbol,
    weight::Symbol = Symbol(),
    edge_attributes::Union{Vector{Symbol},Symbol} = Vector{Symbol}(),
    vertex_attributes::DataFrame = DataFrame(),
    vertex_id_col::Symbol = Symbol())

    # Map node names to vertex IDs
    nodes = sort!(unique!([df[:, origin]; df[:, destination]]))
    vertex_names = DataFrame(name = nodes, vertex_id = eachindex(nodes))

    # Merge in to original
    for c in [origin, destination]
        temp = rename(vertex_names, :vertex_id => Symbol(c, :_id))
        df = innerjoin(df, temp; on = c => :name)
    end

    # Merge additional attributes to names
    if vertex_attributes != DataFrame()
        idsym = vertex_id_col == Symbol() ? first(propertynames(vertex_attributes)) : vertex_id_col
        vertex_names = leftjoin(vertex_names, vertex_attributes, on = :name => idsym)
    end

    # Create Graph
    mg = graph_type(nrow(vertex_names))
    for r in eachrow(df)
        add_edge!(mg, r[Symbol(origin, :_id)], r[Symbol(destination, :_id)])
    end

    # Set vertex names and attributes
    attr_names = propertynames(vertex_names[!, Not(:vertex_id)])
    for r in eachrow(vertex_names)
        set_props!(mg, r[:vertex_id], Dict([a => r[a] for a in attr_names]))
    end

    # Set edge attributes
    if typeof(edge_attributes) == Symbol
        edge_attributes = Vector{Symbol}([edge_attributes])
    end

    origin_id = Symbol(origin, :_id)
    destination_id = Symbol(destination, :_id)

    for e in edge_attributes
        for r in eachrow(df)
            set_prop!(mg, Edge(r[origin_id], r[destination_id]), e, r[e])
        end
    end

    # Weight
    if weight != Symbol()
        for r in eachrow(df)
            set_prop!(mg, Edge(r[origin_id], r[destination_id]), :weight, r[weight])
        end
    end

    # Set name as index (Issue #9)
    set_indexing_prop!(mg, :name)

    return mg
end

end # module
