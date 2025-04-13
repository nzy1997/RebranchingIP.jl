using RebranchingIP
using Test

@testset "RebranchingIP.jl" begin
    # Write your tests here.
end


using ProblemReductions
using JuMP
using SCIP
using ProblemReductions.Graphs


model,x = get_model!(smallgraph(:petersen))
# @constraint(model,x[1] == 1)
[set_integer(x[i]) for i in 1:length(x)]
model_test = copy(model)
JuMP.optimize!(model_test)
value.(x)
objective_value(model)