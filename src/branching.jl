function branching(ip::IP,k::Int)
    if ip.lower_bound == ip.upper_bound
        return ip.upper_bound,ip.upper_bound_vec,1
    end
    int_pos = isapprox.(ip.lower_bound_vec,round.(ip.lower_bound_vec),atol = 1e-3)

    count_int = sum(int_pos)
    if count_int == length(ip.x)
        return ip.lower_bound,ip.lower_bound_vec,1
    end
    if count_int >= length(ip.x) - k
        optimize!(ip.model)
        return objective_value(ip.model),value.(ip.x),1
    end
    branching_var = findall(i-> !i, int_pos)[1:k]
    tbl = ip_branching_table(ip, branching_var)
    if isempty(tbl.table)
        return ip.upper_bound,ip.upper_bound_vec,1
    end
    res = ip_optimal_branching_rule(tbl, OptimalBranchingCore.IPSolver())
    obj_val_upper = ip.upper_bound
    upper_bound_vec = ip.upper_bound_vec
    count_branch = 0
    for cl in res.optimal_rule.clauses
        model,x_new  = ip.model,ip.x
        constraint_list = []
        for j in 1:length(branching_var)
            if readbit(cl.mask,j) == 1
                if readbit(cl.val,j) == 1
                    push!(constraint_list, @constraint(model, x_new[branching_var[j]] <= floor(ip.lower_bound_vec[branching_var[j]])))
                else
                    push!(constraint_list, @constraint(model, x_new[branching_var[j]] >= ceil(ip.lower_bound_vec[branching_var[j]])))
                end
            end
        end
        undo = relax_integrality(model)
        optimize!(model)
        x_value = value.(x_new)
        obj_val_lower = objective_value(model)
        undo()
        ip_new = IP(model,x_new,obj_val_lower,x_value,obj_val_upper,upper_bound_vec)
        val, vec,s = branching(ip_new,k)
        if val < obj_val_upper
            obj_val_upper = val
            upper_bound_vec = vec
        end
        delete.(model, constraint_list)
        count_branch += s
    end
    return obj_val_upper, upper_bound_vec,count_branch
end 