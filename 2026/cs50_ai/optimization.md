# Optimization
## Local Search
* Hill Climbing
    current = initial state of problem
    repeat:
        neighbor = best valued neighbor of current
        if neighbor not better than current:
        return current
        current = neighbor
* Hill Climbing Variants
    * Steepest-ascent: choose the highest-valued neighbor. This is the standard variation that we discussed above.
    * Stochastic: choose randomly from higher-valued neighbors. Doing this, we choose to go to any direction that improves over our value. This makes sense if, for example, the highest-valued neighbor leads to a local maximum while another neighbor leads to a global maximum.
    * First-choice: choose the first higher-valued neighbor.
Random-restart: conduct hill climbing multiple times. Each time, start from a random state. Compare the maxima from every trial, and choose the highest amongst those.
    * Local Beam Search: chooses the k highest-valued neighbors. This is unlike most local search algorithms in that it uses multiple nodes for the search, and not just one.
## Simulated Annealing
function Simulated-Annealing(problem, max):
    current = initial state of problem
    for t = 1 to max:
        T = Temperature(t)
        neighbor = random neighbor of current
        ΔE = how much better neighbor is than current
        if ΔE > 0:
            current = neighbor
        with probability e^(ΔE/T) set current = neighbor
    return current

## Linear Programming
## Constraint Satisfaction
* Node Consistency
* Arc Consistency

function Revise(csp, X, Y):
    revised = false
    for x in X.domain:
        if no y in Y.domain satisfies constraint for (X,Y):
            delete x from X.domain
            revised = true
    return revised

function AC-3(csp):
    queue = all arcs in csp
    while queue non-empty:
        (X, Y) = Dequeue(queue)
        if Revise(csp, X, Y):
            if size of X.domain == 0:
                return false
            for each Z in X.neighbors - {Y}:
                Enqueue(queue, (Z,X))
    return true

## Backtracking Search
function Backtrack(assignment, csp):
    if assignment complete:
        return assignment
    var = Select-Unassigned-Var(assignment, csp)
    for value in Domain-Values(var, assignment, csp):
        if value consistent with assignment:
            add {var = value} to assignment
            result = Backtrack(assignment, csp)
            if result ≠ failure:
                    return result
            remove {var = value} from assignment
    return failure


### Inference
function Backtrack(assignment, csp):
    if assignment complete:
        return assignment
    var = Select-Unassigned-Var(assignment, csp)
    for value in Domain-Values(var, assignment, csp):
        if value consistent with assignment:
            add {var = value} to assignment
            inferences = Inference(assignment, csp)
            if inferences ≠ failure:
                add inferences to assignment
            result = Backtrack(assignment, csp)
        if result ≠ failure:
            return result
        remove {var = value} and inferences from assignment
    return failure
