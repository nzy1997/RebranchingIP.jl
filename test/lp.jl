using RebranchingIP
 using Test
using ProblemReductions.Graphs
using RebranchingIP: get_model,get_IP,ip_branching_table,ip_optimal_branching_rule
using OptimalBranchingCore

@testset "getmodel" begin
    g = smallgraph(:petersen)
    model,x = get_model(g)

    # @constraint(model,x[1] == 1)
    JuMP.optimize!(model)
    @show value.(x)
    @show objective_value(model)

    @constraint(model,x[1] == 1)
    JuMP.optimize!(model)
    @show value.(x)
    @show objective_value(model)
end

@testset "branching_table" begin
    g = smallgraph(:petersen)
    ip = get_IP(g)
    tbl = branching_table(ip, [1,2])

    # ip_optimal_branching_rule(tbl, IPSolver())
    branching(ip, 1)
end

model = Model()

@variable(model, x)
is_valid(model, x)

model_copy = copy(model)

x_new = model[:x]
is_valid(model_copy, x_new)