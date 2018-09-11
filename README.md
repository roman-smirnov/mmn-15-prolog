# MMN 15 - Prolog

## Question 1 - Missionaries and Cannibals

### Demo

![Screen Shot 2018-09-09 at 3.37.23](mmn_15_prolog.assets/Screen Shot 2018-09-09 at 3.37.23.png)

![Screen Shot 2018-09-09 at 3.38.16](mmn_15_prolog.assets/Screen Shot 2018-09-09 at 3.38.16.png)



### State Space

The state space consists of all valid problem states, together with all valid transition between them. For this assignment, we represent the state space as a graph, defined a follows:  

1. The set of nodes encodes all possible valid variable assignments (positions of cannibals, missionaries, boat).
2. The set of edges encodes all possible valid transitions between these (i.e moving the boat with individuals between banks).

### Problem Definition

1. We define a state as a 3-tuple of the form `(CL, ML, B)` where

   CL := number of cannibals at left river bank.

   ML := number of missionaries at left river bank.

   B :=  a binary indicator: assigned 0 if boat on left bank, 1 if boat on right bank. 

   _Note:_ since there are 3 elements of each type (excluding boat), we can deduce the number of individuals at the right bank ($CR = 3-CL$, $MR = 3-ML$), so there's no need to hold an extra state variable. 

2. The start state is all individuals and boat located at the left bank: `(3,3,0)`. 

3. The goal state is all individuals and boat located at the right bank: `(0,0,1)`.

4. The successor (transition) function is defined thusly:

   a. the boat state bit is flipped.

   b. at most 2, and at least 1 individual transfered.

   c. individuals transfered in congruence with boat state change.

   d. successor state stand under problem state constraints.

5. The state constraints are the following:

   a. CL,ML are integers between 0 and 3. B is a binary integer.

   b. no more missionaries than cannibals on each bank. 

   c. boat can't be left alone at a river bank.

#### Illustration

First two level of state space graph. 

```python
[3, 3, 0]
	│
    ├── [3, 1, 1]
    │		└── [3, 2, 0]
    |
    └── [2, 2, 1]
			└── [3, 2, 0]		
```

_Note:_ `[3,2,0]` is an alias, not a duplicate node. 



### Prolog Implementation

The program is seperated into 3 files:

1. `constraints.pl` - problem definition, constraints. 
2. `dfs.pl` - depth first search implementation.
3. `bfs.pl` - breadth first search implementation.

Code inlined below for convenience.

#### `constraints.pl`

```
/* search graph root node */
start([3, 3, 0]).

/* search graph terminal node */
goal([0, 0, 1]).

/* enforces state constraints */
valid_state(CL, ML, B) :-
% check values are integers in range
(CL is 0 ; CL is 1 ; CL is 2 ; CL is 3),
(ML is 0 ; ML is 1 ; ML is 2 ; ML is 3),
(B is 0 ; B is 1),
% check cannibals not converted
(CL is 0 ; CL >= ML),
(CL is 3 ; CL =< ML),
% check boat not autonomous
\+ (B is 0, 0 is CL + ML),
\+ (B is 1, 6 is CL + ML).

/* enforces transition rules/constraints */
valid_trans(CL, CLs, ML, MLs, B, Bs) :-
% just one
(CLs is CL, MLs is ML + 1, B is 1, Bs is 0) ;
(CLs is CL, MLs is ML - 1, B is 0, Bs is 1) ;
(CLs is CL + 1, MLs is ML, B is 1, Bs is 0) ;
(CLs is CL - 1, MLs is ML, B is 0, Bs is 1) ;
% two of same
(CLs is CL, MLs is ML + 2, B is 1, Bs is 0) ;
(CLs is CL, MLs is ML - 2, B is 0, Bs is 1) ;
(CLs is CL + 2, MLs is ML, B is 1, Bs is 0) ;
(CLs is CL - 2, MLs is ML, B is 0, Bs is 1) ;
% one of each
(CLs is CL + 1, MLs is ML + 1, B is 1, Bs is 0) ;
(CLs is CL - 1, MLs is ML - 1, B is 0, Bs is 1).

/* generates all state space successors which hold under constraints */
successor([CL, ML, B],[CLs, MLs, Bs]) :-
    % state constraints
    valid_state(CLs, MLs, Bs),
    % transition rules
    valid_trans(CL, CLs, ML, MLs, B, Bs).
```

#### `dfs.pl`

```
:- include('cannibals_missionaries_constraints.pl').

/* recrusive depth-first search call */
depth_first(Path, Node, Sol) :-
    successor(Node, Node1),
    \+ member(Node1,Path),
    depth_first([Node|Path], Node1, Sol).

/* goal found - terminal tail call */
depth_first(Path, Node, [Node| Path]):-
    goal(Node).

/* initiate dfs graph search for path from start node to goal node */
depth_first(Path) :-
    start(Node),
    depth_first([], Node , Path).
```

```
% query
?- depth_first(Path).
```

#### `bfs.pl`

```
:- include('cannibals_missionaries_constraints.pl').

/* recrusive depth-first search call */
depth_first(Path, Node, Sol) :-
    successor(Node, Node1),
    \+ member(Node1,Path),
    depth_first([Node|Path], Node1, Sol).

/* goal found - terminal tail call */
depth_first(Path, Node, [Node| Path]):-
    goal(Node).

/* initiate dfs graph search for path from start node to goal node */
depth_first(Path) :-
    start(Node),
    depth_first([], Node , Path).
```

```
% query
?- breadth_first(Path).
```



## Question 2 - Map Coloring

### Q2.a

Non-zero weights can cause heuristics search algorithms to favor some paths or avoid others. Coloring preferences are neither defined or implied by the Map Coloring Problem, nor does search distance (:= sum of path weights) has relevancy. Moreover, heuristic contradicting behavior might emerge. Therefore, weights should remain zero assigned to avoid resultant unwanted behavior.

### Q2.b

Let's analyze the following heuristics:

1. _Maximum Degree heuristic (MD)_ - prefer higher degree nodes. 

   Reduces search space by assignment of nodes with most constraints first.

2. _Minimum Remaining Values heuristic (MRV)_ - prefer nodes  with least possible assignments remaining.

   Reduces search space by assignment of nodes such that to cause maximal search space contraction.

MRV eliminates more possiblities from the search space at each step due to pruning entire branches early. MD imposes more constraints for further checks in subsequent steps, it's less likely to facilitate assignment space contraction since a greater constraint count doesn't necessarily imply a shallower search graph.

### Q2.c

A Best-First type algorithm will first check variables with a better heuristic evaluation. Best-First algorithms are often implemented by way of a max-heap holding the frontier nodes. However, regardless of data structure, the next node to be checked must always have the lowest evaluation `evaluation(vertex, path) =  path_cost(path) + heuristic_estimate(vertex)`. 

#### Max Degree Heuristic Example

```
[brackot-r]
 └─ [brackot-r, mungolia-w]
  └─ [brackot-r, mungolia-w, conswana-g]
   └─ [brackot-r, mungolia-w, conswana-g, predico-y]
    └─ [brackot-r, mungolia-w, conswana-g, predico-y, kalkuli-g]
	 └─ [brackot-r, mungolia-w, conswana-g, predico-y, kalkuli-g, hackiland-g]
```

where the heuristic evaluations are `{brackot:5, mungolia:5, conswana:4, predico:4, kalkuli:3, hackiland:3}`. 
