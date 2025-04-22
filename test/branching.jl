using RebranchingIP
using Test
using ProblemReductions
using ProblemReductions.Graphs
using RebranchingIP: get_model,get_IP,ip_branching_table,ip_optimal_branching_rule
using OptimalBranchingCore

@testset "get_model" begin
    g = smallgraph(:petersen)
    problem = MaximalIS(g)
    model = get_model(problem)
    @show model

end
@testset "solve_mis" begin
    g = smallgraph(:petersen)
    res, _ , branch_num  = solve_mis(g,3)
    @test res == -4

    g = random_regular_graph(30, 3; seed = 2134)
    res, _ , branch_num  = solve_mis(g,5)
    @show res, branch_num
    @test res == -13
end

@testset "branching_table" begin
    g = smallgraph(:petersen)
    ip = get_IP(g)
    tbl = branching_table(ip, [1,2])

    # ip_optimal_branching_rule(tbl, IPSolver())
    branching(ip, 1)
end