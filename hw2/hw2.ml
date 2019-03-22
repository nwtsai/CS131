(* Types *)
type ('nonterminal, 'terminal) symbol =
	| N of 'nonterminal
	| T of 'terminal

type ('nonterminal, 'terminal) parse_tree =
	| Node of 'nonterminal * ('nonterminal, 'terminal) parse_tree list
	| Leaf of 'terminal

(* 1 *)
let convert_grammar gram1 =
	let rec get_terminals gram nt = match gram with
		| (a,b)::t -> 
			if a = nt
			then b::(get_terminals t nt)
			else get_terminals t nt
		| [] -> [] in
	match gram1 with
		| (a,b) -> (a, get_terminals b)

(* 2 *)
let parse_tree_leaves tree =
	let rec parse_tree_helper tree acc =
		let rec parse_children ch acc =
			match ch with
				| first_ch::other_ch ->
					parse_tree_helper first_ch acc @ parse_children other_ch acc
				| [] -> acc in
		match tree with
			| Leaf l -> l::acc
			| Node (_, ch) -> parse_children ch acc in
	parse_tree_helper tree []

(* 3 *)
let make_matcher gram accept frag = 
	let rec m1 start rules accept frag = function
		| [] -> None
		| first_rule::other_rules ->
			let try_first_rule = m2 rules first_rule accept frag in
			match try_first_rule with
				| None -> m1 start rules accept frag other_rules
				| something -> something
	and m2 rules rule accept frag = match rule with
		| [] -> accept frag
		| _ -> match frag with
			| [] -> None
			| first_frag::other_frags -> match rule with 
				| [] -> None
				| (N first_nt)::other_syms1 -> m1 first_nt rules
					(m2 rules other_syms1 accept) frag (rules first_nt)
				| (T first_t)::other_syms2 ->
					if first_frag = first_t 
					then m2 rules other_syms2 accept other_frags
					else None in
	m1 (fst gram) (snd gram) accept frag ((snd gram) (fst gram))

(* 4 *)
let rec make_parser gram frag =
	let accept_all_trees frag acc = match frag with
		| _::_ -> None
		| x -> Some (x, acc) in
	let rec m1 start rules accept frag acc = function
		| [] -> None
		| first_rule::other_rules ->
			let try_first_rule = m2
				rules first_rule accept frag ((start, first_rule)::acc) in
			match try_first_rule with
				| None -> m1 start rules accept frag acc other_rules
				| something -> something
	and m2 rules rule accept frag acc = match rule with
		| [] -> accept frag acc
		| _ -> match frag with
			| [] -> None
			| first_frag::other_frags -> match rule with 
				| [] -> None
				| (N first_nt)::other_syms1 -> m1 first_nt rules
					(m2 rules other_syms1 accept) frag acc (rules first_nt)
				| (T first_t)::other_syms2 ->
					if first_frag = first_t 
					then m2 rules other_syms2 accept other_frags acc
					else None in
	let rec mp1 rules = match rules with
		| [] ->
			let tree = mp2 rules [] in
			Node (fst (List.hd rules), fst tree), snd tree
		| h::t ->
			let tree = mp2 t (snd h) in
			Node (fst h, fst tree), snd tree
	and mp2 rules = function
		| [] -> [], rules
		| h::t -> match h with
			| N _ ->
				let tree = mp1 rules in
				let other_trees = mp2 (snd tree) t in
				(fst tree)::(fst other_trees), snd other_trees
			| T terminal ->
				let tree = mp2 rules t in
	 			(Leaf terminal)::(fst tree), snd tree in
	let flattened_tree = m1 (fst gram) (snd gram)
		accept_all_trees frag [] ((snd gram) (fst gram)) in
	match flattened_tree with
		| Some (_, rules) ->
			let reversed_rules = List.rev rules in
			let tree_root = fst (mp1 reversed_rules) in
			Some tree_root
		| _ -> None
