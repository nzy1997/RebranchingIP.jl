#show link: set text(blue)
#import "@preview/cetz:0.2.2": canvas, draw, tree

#let mixmode_tree() = {
  import draw: *
  set-origin((4, 0.35))
  let DY = 1.3
  let DY2 = 0.7
  let DY3 = 0.5
  let DX1 = 2.5
  let DX2 = 1.2
  let DX3 = 0.7
  let DX4 = 0.3
  let DX5 = 0.15
  let root = (0, DY)
  let left = (-DX1, 0)
  let right = (DX1, 0)
  let left_left = (-DX1 - DX2, -DY)
  let left_right = (-DX1 + DX2, -DY)
  let right_left = (DX1 - DX2, -DY)
  let right_right = (DX1 + DX2, -DY)

  let left_left_left = (-DX1 - DX2 - DX3, -2*DY)
  let left_left_right = (-DX1 - DX2 + DX3, -2*DY)
  let left_right_left = (-DX1 + DX2 - DX3, -2*DY)
  let left_right_right = (-DX1 + DX2 + DX3, -2*DY)
  let right_left_left = (DX1 - DX2 - DX3, -2*DY)
  let right_left_right = (DX1 - DX2 + DX3, -2*DY)
  let right_right_left = (DX1 + DX2 - DX3, -2*DY)
  let right_right_right = (DX1 + DX2 + DX3, -2*DY)

  // rect((-DX1 - DX2 - DX3 - DX4 - DX5 - 0.5, -2 * DY + 0.2), (DX1 + DX2 + DX3 + DX4 + DX5 + 0.5, -2*DY - DY2 - DY3 - 0.2), fill: blue.transparentize(50%), radius: 3pt, stroke: (dash: "dashed"))
  let ymid = -2*DY + 0.5

  for (a, b) in ((root, left), (root, right), (left, left_left), (left, left_right), (right, right_left), (right, right_right), (left_left, left_left_left), (left_left, left_left_right), (left_right, left_right_left), (left_right, left_right_right), (right_left, right_left_left), (right_left, right_left_right), (right_right, right_right_left), (right_right, right_right_right)){
    line(a, b)
    circle(a, radius:0.1, fill: red.lighten(30%))
  }

  for (l, t) in ((left_left_left, [$W_1$]), (left_left_right, [$B_(12)$]), (left_right_left, [$W_2$]), (left_right_right, [$B_(23)$]), (right_left_left, [$W_3$]), (right_left_right, [$B_(34)$]), (right_right_left, [$W_4$]), (right_right_right, [$B_(41)$])){
    let a = (rel: (-DX4, -DY2), to: l)
    let b = (rel: (DX4, -DY2), to: l)
    line(l, a)
    line(l, b)
    line(a, (rel: (-DX5, -DY3), to: a))
    line(a, (rel: (DX5, -DY3), to: a))
    line(b, (rel: (-DX5, -DY3), to: b))
    line(b, (rel: (DX5, -DY3), to: b))
    circle(l, radius:0.1, fill: red.lighten(30%))
    circle(a, radius:0.1, fill: red.lighten(30%))
    circle(b, radius:0.1, fill: red.lighten(30%))
  }
  content((0.0, 1.7), text(16pt)[$t ~ gamma^(rho)$])
  content((4, 0.5), text(16pt)[$t_2 ~ gamma^(rho-Delta rho_2)$])
  content((-4, 0.5), text(16pt)[$t_1 ~ gamma^(rho-Delta rho_1)$])
}



#align(center, text(size: 18pt)[Rebranching integer programming\
#text(12pt, [_Jin-Guo Liu_ and _Zhong-Yi Ni_])
])

= Description
== Overview
1. Select a set of $k$ variables to branch on: $caron(x)_1, caron(x)_2, ..., caron(x)_k in.not ZZ$.
2. Explore the $2^k$ derived subproblems, each associated with a bit string: $b_1, b_2, ..., b_k in {0, 1}$, representing adding $k$ constraints:
  $
 cases(x_i <= floor(caron(x)_i) quad "if" quad b_i = 0, x_i >= ceil(caron(x)_i) quad "if" quad b_i = 1), quad i = 1, 2, ..., k.
$
  Each subproblem gives a lower bound and upper bound of the objective value. The subproblems with upper bound lower than the current best lower bound, as well as the subproblems with infeasible constraints, can be pruned. The bit strings associated with the surviving subproblems are stored in a table, called the *branching table*. For example, a valid $k=5$ branching table (for $b_1, b_2, b_3, b_4, b_5$) is shown below:
  #enum(numbering: "R1:",
    [00001],
    [00101],
    [01010],
    [11100]
  )
  In this example, the solution space is highly sparse, only 5 out of $2^5=32$ subproblems are promising.
3. Rebranching: derive 3 branches (or nodes) from the branching table.
  - $not b_1 and not b_2 and not b_4 and b_5$, meaning $x_1 <= floor(caron(x)_1), x_2 <= floor(caron(x)_2), x_4 <= floor(caron(x)_4), x_5 >= ceil(caron(x)_5)$.
  - $not b_1 and b_2 and not b_3 and b_4 and not b_5$
  - $b_1 and b_2 and b_3 and not b_4 and not b_5$

  The first branch covers the case R1 and R2, the second branch covers the case R3, the third branch covers the case R4. We claim deviding the solution space into these 3 cases is optimal in the framework of branching @Fomin2013.

== Branching framework

This section answers why deriving the 3 branches in step 3 is optimal in terms of reducing the number of branches (or nodes) in the search tree. It is very counter-intuitive because, naively, analyzing each of the 4 cases separately fully utilizes the sparsity of the solution space. So why bother? One amazing fact is that, case by case analysis is far from optimal in the framework of branching. By rebranching the solution space, we can achieve an exponential reduction in the number of branches. And this is verified in our rebranching experiment:
https://github.com/nzy1997/RebranchingIP.jl/issues/2

A crucial hypothesis in the branching framework is the exponential time complexity: the time to solve the target problem is $gamma^rho$, where $gamma$ is a constant and $rho$ is a measure of problem size (e.g. number of variables) @Fomin2013.
It tries to devide and conquer a large problem into smaller subproblems, with an objective to reduce the branching factor $gamma$.

#figure(canvas(length: 0.8cm, {
  mixmode_tree()
}))

#align(left, box(stroke: black, inset: 10pt)[Let $Delta rho_i$ be the size reduction in the $i$-th branch.
Then the _branching factor_ is given by
$
gamma^rho = sum_i gamma^(rho - Delta rho_i) arrow.double.r 1 = sum_i gamma^(- Delta rho_i)
$])

The less branches we have, the smaller the branching factor $gamma$ is. The larger the size reduction $Delta rho_i$, the smaller the branching factor $gamma$ is.
So, we aim to reduce the number of branches, and to maximize the size reduction $Delta rho_i$.
Interestingly, the optimal way to branch is achieved by the algorithm designed in @Gao2024.

== Multi-variable branching for integer programming
We use the optimal branching technique @Gao2024 to speed up the integer programming problem@Achterberg2009b.

Integer programming is a searching problem.
It searches exponentially large solution space for finding the one with the largest objective value.
The basic idea of rebranch is to devide the solution space into multiple zones, each zone should have a smaller search space.

#figure(canvas({
  import draw: *
  let W = 3
  let H = 0.7
  line((-W, H), (W, H))
  line((-W, -H), (W, -H))
  line((H, W), (H, -W))
  line((-H, W), (-H, -W))
  content((-2, -2), "Zone 3")
  content((2, -2), "Zone 4")
  content((2, 2), "Zone 1")
  content((-2, 2), "Zone 2")
  content((H/2 + W/2, -W - 0.5), [$x_1 > ceil(caron(x)_1)$])
  content((-W/2-H/2, -W - 0.5), [$x_1 < floor(caron(x)_1)$])
  content((-W - 1.0, +W/2 + H/2), [$x_2 > ceil(caron(x)_2)$])
  content((-W - 1.0, -W/2 - H/2), [$x_2 < floor(caron(x)_2)$])

  // x1 > 1
  rect((H, -W), (W, W), fill: green.transparentize(60%), stroke: none)
  rect((-H, -W), (-W, W), fill: green.transparentize(60%), stroke: none)
  rect((-W, H), (W, W), fill: red.transparentize(60%), stroke: none)
  rect((-W, -H), (W, -W), fill: red.transparentize(60%), stroke: none)
}),
caption: [The branching on two variables divide the search space into 4 zones. Each zone corresponds to adding different constraints to the reduce the search space. Variables with "caron" are solutions to the relaxed linear programming problem.])

When branching over $k$ variables, we can divide the search space into $2^k$ zones.
Each zone has $k$ extra constraints compared to the previous zone.
These constraints reduces the search space by a certain factor.
In our discussion, we assume each constraint halves the search space, and reduces the problem size by $1$.
So, the *measure* here is the number of constraints to be added to reach the optimal solution.

Through *bounding*, we can reduce the search space.
For example, the following shaded zone is ruled out by the bounding.

#let pat = pattern(size: (20pt, 20pt))[
  #place(line(start: (0%, 100%), end: (100%, 0%)))
]
#figure(canvas({
  import draw: *
  let W = 3
  let H = 0.7
  line((-W, H), (W, H))
  line((-W, -H), (W, -H))
  line((H, W), (H, -W))
  line((-H, W), (-H, -W))
  content((H/2 + W/2, -W - 0.5), [$x_1 > ceil(caron(x)_1)$])
  content((-W/2-H/2, -W - 0.5), [$x_1 < floor(caron(x)_1)$])
  content((-W - 1.0, +W/2 + H/2), [$x_2 > ceil(caron(x)_2)$])
  content((-W - 1.0, -W/2 - H/2), [$x_2 < floor(caron(x)_2)$])

  // x1 > 1
  rect((H, -W), (W, W), fill: green.transparentize(60%), stroke: none)
  rect((-H, -W), (-W, W), fill: green.transparentize(60%), stroke: none)
  rect((-W, H), (W, W), fill: red.transparentize(60%), stroke: none)
  rect((-W, -H), (W, -W), fill: red.transparentize(60%), stroke: none)

  rect((H, -H), (W, -W), fill: pat, stroke: none)
})
)

The *rebranching* is a technique to reduce the tree size by reorganizing the search tree. In this case,
the rebranching produces two branches instead of three in the original tree:
$
cases(x_1 < floor(caron(x)_1), x_1 > ceil(caron(x)_1) "and" x_2 > ceil(caron(x)_2))
$
The expected time complexity is determined by $1 = gamma^(-2) + gamma^(-1)$, which is $gamma approx 1.618$.
This is smaller than the $1.73$ given by the original branching: $1 = 3gamma^(-2)$.

== Deciding which subset of variables to branch

We introduce a *score function* for each variable, which is determined by some heuristic.
First pick a variable $x_1$ with the highest score, which produces two branches.

#figure(canvas({
    import draw: *
    let DX1 = 1.0
    let DY1 = 1.0
    circle((0, 0), radius: 0.3, name: "x1")
    circle((-DX1, -DY1), radius: 0.3, name: "a")
    circle((DX1, -DY1), radius: 0.3, name: "b")
    content("x1", [$caron(x)_1$])
    content("a", [$caron(x)_2$])
    content("b", [$caron(x)'_2$])
    content((rel: (-0.6, 0.9), to: "a"), [$x_1 < floor(caron(x)_1)$])
    content((rel: (0.6, 0.9), to: "b"), [$x_1 > ceil(caron(x)_1)$])
    rect((-2 * DX1, -DY1 - 0.5), (2 * DX1, -DY1 + 0.5), stroke: (dash: "dashed"))
    line("x1", "a")
    line("x1", "b")
    content((0, -2), [$x_2$: the variable with the highest average score])
}))

On each branch, we evaluate the score of the remaining variables.
$x_2$ is chosen to be the variable with the highest score averaged over the two branches.

Each branch is associated with a *upper bound* and *lower bound* of the objective value (to be maximized).
If the upper bound of one branch is infeasible, or its upper bound is lower than the lower bound of another branch,
we can prune the branch. The upper bound is computed with the linear programming relaxation, while the lower bound is a bit tricky.
For simplicity, we can round the variables to the nearest integer, and compute the objective value.

#bibliography("refs.bib")