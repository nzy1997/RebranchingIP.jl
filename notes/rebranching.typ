#show link: set text(blue)
#import "@preview/cetz:0.2.2": canvas, draw, tree

#align(center, text(size: 18pt)[Rebranching integer programming\
#text(12pt, [_Jin-Guo Liu_ and _Zhong-Yi Ni_])
])

= Description

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
  content((H/2 + W/2, -W - 0.5), [$x_1 > ceil(tilde(x)_1)$])
  content((-W/2-H/2, -W - 0.5), [$x_1 < floor(tilde(x)_1)$])
  content((-W - 1.0, +W/2 + H/2), [$x_2 > ceil(tilde(x)_2)$])
  content((-W - 1.0, -W/2 - H/2), [$x_2 < floor(tilde(x)_2)$])

  // x1 > 1
  rect((H, -W), (W, W), fill: green.transparentize(60%), stroke: none)
  rect((-H, -W), (-W, W), fill: green.transparentize(60%), stroke: none)
  rect((-W, H), (W, W), fill: red.transparentize(60%), stroke: none)
  rect((-W, -H), (W, -W), fill: red.transparentize(60%), stroke: none)
}),
caption: [The branching on two variables divide the search space into 4 zones. Each zone corresponds to adding different constraints to the reduce the search space. Variables with "tilde" are solutions to the relaxed linear programming problem.])

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
  content((H/2 + W/2, -W - 0.5), [$x_1 > ceil(tilde(x)_1)$])
  content((-W/2-H/2, -W - 0.5), [$x_1 < floor(tilde(x)_1)$])
  content((-W - 1.0, +W/2 + H/2), [$x_2 > ceil(tilde(x)_2)$])
  content((-W - 1.0, -W/2 - H/2), [$x_2 < floor(tilde(x)_2)$])

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
cases(x_1 < floor(tilde(x)_1), x_1 > ceil(tilde(x)_1) "and" x_2 > ceil(tilde(x)_2))
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
    content("x1", [$tilde(x)_1$])
    content("a", [$tilde(x)_2$])
    content("b", [$tilde(x)'_2$])
    content((rel: (-0.6, 0.9), to: "a"), [$x_1 < floor(tilde(x)_1)$])
    content((rel: (0.6, 0.9), to: "b"), [$x_1 > ceil(tilde(x)_1)$])
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