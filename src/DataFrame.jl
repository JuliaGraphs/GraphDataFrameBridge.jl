import DataFrames.DataFrame

"""
    DataFrame(gr::T; type = :node) where T <:AbstractMetaGraph

Construct a DataFrame from a MetaGraph from either its node or edge properties.
`gr` is a MetaGraph.
`type` is a Symbol valued either :node or :edge such that the DataFrame is populated with node or edge
properties stored in `gr`.
"""
function DataFrame(gr::T; type = :node) where T <:AbstractMetaGraph
    fl, prps, en, nu = if type == :node
        :node => Int[], gr.vprops, vertices, nv
    elseif type == :edge
        :edge => Edge[], gr.eprops, edges, ne
      else
        error("specify :node or :edge")
    end

    dx = DataFrame(fl)

    x = unique(reduce(vcat, values(prps)))
    for y in x
        for (k, v) in y
            dx[!, k] = typeof(v)[] # may be a problem if type is not consistent in y?
            allowmissing!(dx, k)
        end
    end
    
    dx = similar(dx, nu(gr))

    for (i, e) in (enumerate∘en)(gr)
        dx[i, type] = e
        pr = props(gr, e)
        for (nme, val) in pr
            dx[i, nme] = val
        end
    end

    # remove missing when possible
    for v in Symbol.(names(dx))
        if !any(ismissing.(dx[!, v]))
            disallowmissing!(dx, v)
        end
    end
    return dx
end
