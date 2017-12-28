module DataFrameGraphs
using LightGraphs
using MetaGraphs
using JLD2
using DataFrames

export metagraph_from_dataframe

function metagraph_from_dataframe(
    df::DataFrame,
    origin::Symbol,
    destination::Symbol,
    graph_type::Union{Type{MetaDiGraph}, Type{MetaGraph}}=MetaGraph;
    weight::Symbol=Symbol(),
    edge_attributes::Union{Vector{Symbol}, Symbol}=Vector{Symbol}())

    """
        metagraph_from_dataframe(df, origin, destination, graph_type)
        metagraph_from_dataframe(df, origin, destination, graph_type,
                                 weight, edge_addributes)

    Creates a MetaGraph from a DataFrame and stores node names as properties.

    `df` is DataFrame formatted as an edgelist
    `origin` is column symbol for origin of each edge
    `destination` is column symbol for destination of each edge
    `graph_type` is either `MetaGraph` or `MetaDiGraph`

    Will create a MetaGraph with a `name` property that stores node labels
    used in `origin` and `destination`.

    Optional keyword arguments:

    `weight` is column symbol to be used to set weight property.
    `edge_attributes` is a `Symbol` of `Vector{Symbol}` of columns whose values
    will be added as edge properties.
    """

    # Map node names to vertex IDs
    nodes = [df[origin]; df[destination]]
    nodes = unique(nodes)
    sort!(nodes)

    vertex_names = DataFrame(Dict(:name => nodes))
    vertex_names[:vertex_id] = 1:nrow(vertex_names)

    # Merge in to original
    for c in [origin, destination]
        temp = rename(vertex_names, :vertex_id => Symbol(c, :_id), :name => c)
        df = join(df, temp, on=c)
    end

    # Create Graph
    mg = graph_type(nrow(vertex_names))
    for r in eachrow(df)
        add_edge!(mg, r[Symbol(origin, :_id)], r[Symbol(destination, :_id)])
    end

    # Set vertex names
    for r in eachrow(vertex_names)
        set_prop!(mg, r[:vertex_id], :name, r[:name])
    end


    # Set edge attributes
    if typeof(edge_attributes) == Symbol
        edge_attributes = Vector{Symbol}([edge_attributes])
    end

    origin_id = Symbol(start, :_id)
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

    return mg
end

end # module
