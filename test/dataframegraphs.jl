importall DataFrameGraphs

@testset "DataFrameGraphs" begin

    # Test data from constructor
    df = DataFrame(Dict("start" => ["a", "b", "a", "d"],
                        "finish" => ["b", "c", "e", "e"],
                        "weights" => 1:4,
                        "extras" => 5:8))

    @inferred(metagraph_from_dataframe(df, :start, :finish, MetaGraph))
    mg = metagraph_from_dataframe(df, :start, :finish, MetaGraph)
    @test get_prop(mg, 1, :name) == "a"
    @test get_prop(mg, 2, :name) == "b"

    @test neighbors(mg, 1)[1] == 2
    @test length(neighbors(mg, 1)) == 2

    @test neighbors(mg, 2)[1] == 1
    @test neighbors(mg, 2)[2] == 3
    @test get_prop(mg, 3, :name) == "c"
    @test length(neighbors(mg, 2)) == 2

    @inferred(metagraph_from_dataframe(df, :start, :finish, MetaDiGraph))
    mg = metagraph_from_dataframe(df, :start, :finish, MetaDiGraph)
    @test neighbors(mg, 2)[1] == 3
    @test length(neighbors(mg, 2)) == 1


    @inferred (metagraph_from_dataframe(df, :start, :finish, MetaGraph,
                                            weight=:weights,
                                            edge_attributes=:extras))
    mg = metagraph_from_dataframe(df, :start, :finish, MetaGraph,
                                            weight=:weights,
                                            edge_attributes=:extras)
    @test length(neighbors(mg, 2)) == 2
    @test get_prop(mg, Edge(1, 2), :weight) == 1
    @test get_prop(mg, Edge(4, 5), :weight) == 4
    @test get_prop(mg, Edge(4, 5), :extras) == 8
end

