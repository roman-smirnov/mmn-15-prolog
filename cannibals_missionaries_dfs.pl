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

  

