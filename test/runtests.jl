using RebranchingIP
using Test

@testset "RebranchingIP.jl" begin
    # Write your tests here.
end


using ProblemReductions
using JuMP
using SCIP
using ProblemReductions.Graphs

function get_model!(model,graph)
    problem = MaximalIS(graph)
    cons = constraints(problem)
    nsc = ProblemReductions.num_variables(problem)
    maxN = maximum([length(c.variables) for c in cons])
    combs = [ProblemReductions.combinations(2,i) for i in 1:maxN]

    objs = objectives(problem)

    # IP by JuMP
   
    JuMP.set_silent(model)

    JuMP.@variable(model, 0 <= x[i = 1:nsc] <= 1)


    for con in cons
        f_vec = findall(!,con.specification)
        num_vars = length(con.variables)
        for f in f_vec
            JuMP.@constraint(model, sum(j-> iszero(combs[num_vars][f][j]) ? (1 - x[con.variables[j]]) : x[con.variables[j]], 1:num_vars) <= num_vars -1)
        end
    end

    if isempty(objs)
        JuMP.@objective(model,  Min, 0)
    else
        obj_sum = sum(objs) do obj
            (1-x[obj.variables[1]])*obj.specification[1] + x[obj.variables[1]]*obj.specification[2]
        end
        JuMP.@objective(model,  Max, obj_sum)
    end
    # @constraint(model,x[1] == 1)
    # JuMP.optimize!(model)
    # value.(x)
    # objective_value(model)
    return model
end
model = JuMP.Model(SCIP.Optimizer)
get_model!(model,smallgraph(:petersen))

@constraint(model,x[1] == 1)

JuMP.optimize!(model)
value.(x)
objective_value(model)