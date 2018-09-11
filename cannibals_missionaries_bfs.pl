:- include('cannibals_missionaries_constraints.pl').

/* generate all valid extensions of a path by a single state */
extend([Node|Path], NewPaths):-
	findall([NewNode, Node|Path],
	(successor(Node, NewNode), \+member(NewNode, [Node|Path])),
	NewPaths).

/* recusrive depth-first graph search call */
breadth_first([Path|Paths], Sol):-
    % generate extension paths
	extend(Path, NewPaths),
	append(Paths, NewPaths, Paths1),
	breadth_first(Paths1, Sol).

/* goal found - terminal tail call */
breadth_first([[Node|Path]|_], [Node | Path]) :-
    goal(Node).

/* initiate bfs graph search for path from start node to goal node */
breadth_first(Path) :-
	start(Start),
    breadth_first([[Start]], Path).

