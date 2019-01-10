@testset "GraphDataFrameBridge" begin

    # Test data from constructor
    df = DataFrame(Dict("start" => ["a", "b", "a", "d"],
                        "finish" => ["b", "c", "e", "e"],
                        "weights" => 1:4,
                        "extras" => 5:8))

    @inferred(MetaGraph(df, :start, :finish))
    mg = MetaGraph(df, :start, :finish)
    @test get_prop(mg, 1, :name) == "a"
    @test get_prop(mg, 2, :name) == "b"

    @test neighbors(mg, 1)[1] == 2
    @test length(neighbors(mg, 1)) == 2

    @test neighbors(mg, 2)[1] == 1
    @test neighbors(mg, 2)[2] == 3
    @test get_prop(mg, 3, :name) == "c"
    @test length(neighbors(mg, 2)) == 2

    @inferred(MetaDiGraph(df, :start, :finish))
    mg = MetaDiGraph(df, :start, :finish)
    @test neighbors(mg, 2)[1] == 3
    @test length(neighbors(mg, 2)) == 1

    @inferred (MetaGraph(df, :start, :finish,
                         weight=:weights,
                         edge_attributes=:extras))
    mg = MetaGraph(df, :start, :finish,
                   weight=:weights,
                   edge_attributes=:extras)
    @test length(neighbors(mg, 2)) == 2
    @test get_prop(mg, Edge(1, 2), :weight) == 1
    @test get_prop(mg, Edge(4, 5), :weight) == 4
    @test get_prop(mg, Edge(4, 5), :extras) == 8


    # Test with different column names to ensure nothing name sensitive
    df2 = DataFrame(Dict("alice" => ["a", "b", "a", "d"],
                        "bob" => ["b", "c", "e", "e"],
                        "weightz" => 1:4,
                        "extraz" => 5:8))

    mg = MetaGraph(df2, :alice, :bob,
             weight=:weightz,
             edge_attributes=:extraz)
    @test length(neighbors(mg, 2)) == 2
    @test get_prop(mg, Edge(1, 2), :weight) == 1
    @test get_prop(mg, Edge(4, 5), :weight) == 4
    @test get_prop(mg, Edge(4, 5), :extraz) == 8

    # Test name column is indexed (Issue #9)
    @test mg["a", :name] == 1
    @test mg["b", :name] == 2
    
end
