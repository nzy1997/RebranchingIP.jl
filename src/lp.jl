function get_model(graph)
    problem = MaximalIS(graph)
    cons = constraints(problem)
    nsc = ProblemReductions.num_variables(problem)
    maxN = maximum([length(c.variables) for c in cons])
    combs = [ProblemReductions.combinations(2,i) for i in 1:maxN]

    objs = objectives(problem)

    # IP by JuMP
    model = JuMP.Model(SCIP.Optimizer)
    JuMP.set_silent(model)

    x = JuMP.@variable(model, 0 <= x[i = 1:nsc] <= 1,Int)
    # x = MOI.add_variables(model, nsc)

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
        JuMP.@objective(model,  Min, -obj_sum)
    end
    # JuMP.optimize!(model)
    # value.(x)
    # objective_value(model)
    return model,x
end

struct IP{MT,VT} <: AbstractProblem
    model::MT
    x::Vector{VT}
    lower_bound::Float64
    lower_bound_vec::Vector{Float64}
    upper_bound::Float64
    upper_bound_vec::Vector{Float64}
end

function get_IP(graph)
    model,x = get_model(graph)

    copy_model,x_new  = copy_JuMP_model(model)
    set_objective_sense(copy_model, FEASIBILITY_SENSE)
    optimize!(copy_model)

    f = objective_function(model)
    point = Dict([x[i] => value(x_new[i]) for i in 1:length(x)]);
    obj_val_upper = value(x -> point[x], f)

    undo = relax_integrality(model)
    optimize!(model)
    obj_val_lower = objective_value(model)
    x_value = value.(x)
    undo()

    return IP(model,x,obj_val_lower,x_value,obj_val_upper,value.(x_new))
end


function ip_branching_table(ip::IP,branching_var::Vector{Int})
    bit_length = length(branching_var)
    x = ip.x
    table = Vector{Vector{Int}}()
    # min_obj_val = ip.lower_bound
    model,x_new  = ip.model,ip.x
    undo = relax_integrality(model)
    for i in 1:2^bit_length
        constraint_list = []
        for j in 1:length(branching_var)
            if readbit(i,j) == 1
                push!(constraint_list, @constraint(model, x_new[branching_var[j]] <= floor(ip.lower_bound_vec[branching_var[j]])))
            else
                push!(constraint_list, @constraint(model, x_new[branching_var[j]] >= ceil(ip.lower_bound_vec[branching_var[j]])))
            end
        end
        optimize!(model)

        if !is_solved_and_feasible(model)
            delete.(model, constraint_list)
            continue
        end
        obj_val = objective_value(model)
        if obj_val > ip.upper_bound
            delete.(model, constraint_list)
            continue
        end
        push!(table, [i])
        delete.(model, constraint_list)
    end
    undo()
    return BranchingTable(bit_length,table)
end

struct NumberOfConstraints <: AbstractMeasure end

function OptimalBranchingCore.measure(ip::IP, ::NumberOfConstraints)
    return  - num_constraints(ip.model; count_variable_in_set_constraints = false)
end

function copy_JuMP_model(model)
    copy_model = copy(model)
    set_optimizer(copy_model, SCIP.Optimizer)
    JuMP.set_silent(copy_model)
    return copy_model, copy_model[:x]
end

function ip_optimal_branching_rule(table::BranchingTable, solver::AbstractSetCoverSolver)
    candidates = OptimalBranchingCore.candidate_clauses(table)
    size_reductions = [sum(i -> readbit(cl.mask,i),1:table.bit_length)  for cl in candidates]
    return minimize_γ(table, candidates, size_reductions, solver)
end

function solve_mis(graph,k::Int)
    ip = get_IP(graph)
    branching(ip,k)
end