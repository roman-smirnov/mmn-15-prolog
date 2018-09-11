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