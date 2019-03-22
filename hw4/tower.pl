/* -----------------------------------------------------------------------------
	HOMEWORK 4: TOWERS SOLVER
------------------------------------------------------------------------------*/

% sublist_length(L, N) is true if each sublist of L has length Len
sublist_length([], _).
sublist_length([H | T], Len) :-
	length(H, Len),
	sublist_length(T, Len).

% transpose(A, B) is true if the matrix A transposed is exactly the matrix B
transpose([[] | _], []).
transpose(A, [H | T]) :-
	transpose_column(A, H, AT),
	transpose(AT, T).
transpose_column([], [], []).
transpose_column([[H | T] | AT], [H | HT], [T | TT]) :-
	transpose_column(AT, HT, TT).

% fd_domain_helper(N, T) is true if the calls to fd_domain are true from 1 to N
fd_domain_helper(_, []).
fd_domain_helper(N, [H | T]) :-
	fd_domain(H, 1, N),
	fd_domain_helper(N, T).

% reverse_row(A, B) is true if B is every list in A reversed
reverse_row([], []).
reverse_row([H | T], [HR | TR]) :-
	reverse(H, HR),
	reverse_row(T, TR).

% validate_row(Row, Count) is true if the list Row has exactly Count visible
% buildings looking from left to right
validate_row([H | T], Count) :-
	validate_row(T, H, 1, Count).
validate_row([], _, Count, Count).
validate_row([H | T], Max, Current, Count) :-
	H < Max,
	validate_row(T, Max, Current, Count).
validate_row([H | T], Max, Current, Count) :-
	H > Max,
	NewCurrent is Current + 1,
	validate_row(T, H, NewCurrent, Count).

% validate_rows(T, C) is true if the left side of the tower T has exactly C
% visible buildings in each row
validate_rows([], []).
validate_rows([Row | Rows], [Count | Counts]) :-
	validate_row(Row, Count),
	validate_rows(Rows, Counts).

% validate_visibilities(T, TT, Top, Bottom, Left, Right) is true if each edge
% has the correct corresponding visible building count
validate_visibilities(T, TT, Top, Bottom, Left, Right) :-
	reverse_row(T, TR),
	reverse_row(TT, TTR),
	validate_rows(TT, Top),
	validate_rows(TTR, Bottom),
	validate_rows(T, Left),
	validate_rows(TR, Right).

% tower(N, T, C) is true if an NxN tower matrix T has edge visibilities of C
tower(N, T, C) :-
	length(T, N),
	sublist_length(T, N),
	transpose(T, TT),
	maplist(fd_domain_helper(N), T),
	maplist(fd_domain_helper(N), TT),
	maplist(fd_all_different, T),
	maplist(fd_all_different, TT),
	maplist(fd_labeling, T),
	C = counts(Top, Bottom, Left, Right),
	length(Top, N),
	length(Bottom, N),
	length(Left, N),
	length(Right, N),
	validate_visibilities(T, TT, Top, Bottom, Left, Right).

/* ---------------------------------------------------------------------------*/

% unique(A, B) is true if A and B have different values
unique(A, B) :-
	A \== B.

% unique_rows(L, T) is true if each row of T has elements that are different
% from those of L
unique_rows(_, []).
unique_rows(L, [H | T]) :-
	maplist(unique, L, H),
	unique_rows(L, T).

% custom_labeling(History, T, L) is true if a permutation created has unique
% elements from those seen so far while building up a History list. Finally, it
% unifies L with a permutation that is consistent with all the constraints.
custom_labeling(_, [], _).
custom_labeling(History, [H | T], L) :-
	permutation(H, L),
	unique_rows(H, History),
	append(History, [H], UpdatedHistory),
	custom_labeling(UpdatedHistory, T, L).
custom_labeling(T, L) :-
	custom_labeling([], T, L).

% plain_tower(N, T, C) is true if an NxN tower matrix T has edge visibilities of
% C. This solution does not utilize the GNU Prolog finite domain solver.
plain_tower(N, T, C) :-
	length(T, N),
	sublist_length(T, N),
	transpose(T, TT),
	findall(V, between(1, N, V), L),
	custom_labeling(T, L),
	custom_labeling(TT, L),
	C = counts(Top, Bottom, Left, Right),
	length(Top, N),
	length(Bottom, N),
	length(Left, N),
	length(Right, N),
	validate_visibilities(T, TT, Top, Bottom, Left, Right).

/* ---------------------------------------------------------------------------*/

% tower_time(Time) measures the CPU time it takes for tower to solve a 4x4
% problem
tower_time(Time) :-
	statistics(cpu_time, [_ | _]),
	tower(5, T, counts(
		[2,2,4,2,1],
		[2,3,2,1,5],
		[3,1,2,3,2],
		[1,2,3,3,2])),
	statistics(cpu_time, [_ | SinceLast]),
	Time is SinceLast.

% plain_tower_time(Time) measures the CPU time it takes for plain_tower to solve
% the same 4x4 problem
plain_tower_time(Time) :-
	statistics(cpu_time, [_ | _]),
	plain_tower(5, T, counts(
		[2,2,4,2,1],
		[2,3,2,1,5],
		[3,1,2,3,2],
		[1,2,3,3,2])),
	statistics(cpu_time,[_ | SinceLast]),
	Time is SinceLast.

% speedup calculates the floating point ratio of the two solutions' CPU times
speedup(Ratio) :-
	plain_tower_time(PTT),
	tower_time(TT),
	Ratio is PTT / TT.

/* ---------------------------------------------------------------------------*/

% ambiguous(N, C, T1, T2) is true if there exist two distinct NxN towers T1 and
% T2 that are compatible with the same count variable C.
ambiguous(N, C, T1, T2) :-
	tower(N, T1, C),
	tower(N, T2, C),
	T1 \= T2.
