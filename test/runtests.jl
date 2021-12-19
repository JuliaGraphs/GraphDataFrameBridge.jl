using Graphs
using MetaGraphs
using DataFrames
using GraphDataFrameBridge
using Test

import Graphs.SimpleGraphs: SimpleGraph, SimpleDiGraph
testdir = dirname(@__FILE__)

testgraphs(g) = [g, SimpleGraph{UInt8}(g), SimpleGraph{Int16}(g)]
testdigraphs(g) = [g, SimpleDiGraph{UInt8}(g), SimpleDiGraph{Int16}(g)]

tests = [
    "graphdataframebridge"
]

@testset "GraphDataFrameBridge" begin
    for t in tests
        tp = joinpath(testdir, "$(t).jl")
        include(tp)
    end
end
