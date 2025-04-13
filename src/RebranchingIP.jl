module RebranchingIP

using JuMP
using OptimalBranchingCore
using OptimalBranchingCore.BitBasis
using OptimalBranchingCore: AbstractProblem
using ProblemReductions
using SCIP
using ProblemReductions.Graphs
include("lp.jl")
include("branching.jl")

export IP, branching

end
