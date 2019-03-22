(* 1 *)
let rec subset a b =
	match a with
	| h::t -> List.mem h b && subset t b
	| [] -> true;;

(* 2 *)
let equal_sets a b =
	subset a b && subset b a;;

(* 3 *)
let set_union a b =
	a @ b;;

(* 4 *)
let rec set_intersection a b =
	match a with
	| h::t ->
		if List.mem h b
		then h::set_intersection t b
		else set_intersection t b
	| [] -> [];;

(* 5 *)
let rec set_diff a b =
	match a with
	| h::t ->
		if List.mem h b
		then set_diff t b
		else h::set_diff t b
	| [] -> [];;

(* 6 *)
let rec computed_fixed_point eq f x =
	if eq x (f x)
	then x
	else computed_fixed_point eq f (f x);;

(* 7 *)
type ('nonterminal, 'terminal) symbol =
	| N of 'nonterminal
	| T of 'terminal;;

let rec is_nonterminal x =
	match x with
	| N h::t -> h::is_nonterminal t
	| T _::t -> is_nonterminal t
	| [] -> [];;

let rec is_reachable n r =
	n::(match r with
		| h::t ->
			(match h with
 			| x,y ->
	 			if x = n
	 			then is_nonterminal y @ is_reachable n t
				else is_reachable n t)
		| [] -> []);;

let rec concat_reachable l r =
	l @ (match l with
		| h::t -> is_reachable h r @ concat_reachable t r
		| [] -> []);;

let rec filter_reachable g = 
	fst g,
	List.filter
		(fun (x, y) -> List.mem
			x
			(computed_fixed_point
				equal_sets
				(fun x -> (concat_reachable x (snd g)))
				[fst g]
			)
		)
		(snd g);;
