let my_subset_test0 = subset [1;2;3] [1;2;3]
let my_subset_test1 = subset [1;2;3] [1;2;3;4]
let my_subset_test2 = not (subset [1;2;3] [])

let my_equal_sets_test0 = equal_sets [] []
let my_equal_sets_test1 = equal_sets [1;2;3] [3;2;1]
let my_equal_sets_test2 = not (equal_sets [] [1;2;3])

let my_set_union_test0 = equal_sets (set_union [1;2] [2;3]) [1;2;3]
let my_set_union_test1 = equal_sets (set_union [1;2;3] []) [3;2;1]
let my_set_union_test2 = equal_sets (set_union [1;2;3] [1;2;3;4]) [1;2;3;4]

let my_set_intersection_test0 = equal_sets (set_intersection [1;2] [2;3]) [2]
let my_set_intersection_test1 = equal_sets (set_intersection [1;2;3] []) []
let my_set_intersection_test2 = equal_sets (set_intersection [1;2;3] [1;2;3;4]) [1;2;3]

let my_set_diff_test0 = equal_sets (set_diff [1;2] [2;3]) [1]
let my_set_diff_test1 = equal_sets (set_diff [1;1;1;1;1;1] [1]) []
let my_set_diff_test2 = equal_sets (set_diff [1;2;3;4] [2;4]) [1;3]

let my_computed_fixed_point_test0 = computed_fixed_point (=) (fun x -> x / 2) 9999 = 0
let my_computed_fixed_point_test1 = computed_fixed_point (=) (fun x -> 4 * x * (1 - x)) 0 = 0
let my_computed_fixed_point_test2 = computed_fixed_point (=) (fun x -> 4. *. x *. (1. -. x)) 0.75 = 0.75

(* A grammar that implements multiplication precedence with the constants a,b,c as terminals *)
type mult_nonterminals =
	Mulexp | Exp | Const
let mult_rules =
	[Mulexp, [T"("; N Exp; T")"];
	Mulexp, [N Const];
	Exp, [N Mulexp];
	Exp, [N Exp; T"+"; N Exp];
	Mulexp, [N Mulexp; T"*"; N Mulexp];
	Const, [T"a"];
	Const, [T"b"];
	Const, [T"c"]]
let mult_grammar = Exp, mult_rules
let my_filter_reachable_test0 = filter_reachable mult_grammar = mult_grammar
let my_filter_reachable_test1 = filter_reachable (Mulexp, mult_rules) = (Mulexp, mult_rules)
let my_filter_reachable_test2 = filter_reachable (Mulexp, List.tl mult_rules) =
	(Mulexp,
	 [Mulexp, [N Const];
	  Mulexp, [N Mulexp; T "*"; N Mulexp];
      Const, [T "a"];
      Const, [T "b"];
      Const, [T "c"]])
let my_filter_reachable_test3 = filter_reachable (Mulexp, List.tl (List.tl mult_rules)) =
	(Mulexp,
	 [Mulexp, [N Mulexp; T "*"; N Mulexp]])
let my_filter_reachable_test4 = filter_reachable (Exp, mult_rules) = (Exp, mult_rules)
let my_filter_reachable_test5 = filter_reachable (Exp, List.tl mult_rules) = (Exp, List.tl mult_rules)
let my_filter_reachable_test6 = filter_reachable (Exp, List.tl (List.tl mult_rules)) =
	(Exp,
	 [Exp, [N Mulexp];
	  Exp, [N Exp; T "+"; N Exp];
      Mulexp, [N Mulexp; T "*"; N Mulexp]])
let my_filter_reachable_test7 = filter_reachable (Exp, List.tl (List.tl (List.tl mult_rules))) =
	(Exp,
	 [Exp, [N Exp; T "+"; N Exp]])
