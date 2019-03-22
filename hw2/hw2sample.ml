type awksub_nonterminals =
  | Expr | Term | Lvalue | Incrop | Binop | Num

let awksub_rules =
  [Expr, [N Term; N Binop; N Expr];
  Expr, [N Term];
  Term, [N Num];
  Term, [N Lvalue];
  Term, [N Incrop; N Lvalue];
  Term, [N Lvalue; N Incrop];
  Term, [T"("; N Expr; T")"];
  Lvalue, [T"$"; N Expr];
  Incrop, [T"++"];
  Incrop, [T"--"];
  Binop, [T"+"];
  Binop, [T"-"];
  Num, [T"0"];
  Num, [T"1"];
  Num, [T"2"];
  Num, [T"3"];
  Num, [T"4"];
  Num, [T"5"];
  Num, [T"6"];
  Num, [T"7"];
  Num, [T"8"];
  Num, [T"9"]];;

let awkish_grammar =
  (Expr,
   function
     | Expr ->
         [[N Term; N Binop; N Expr];
          [N Term]]
     | Term ->
   [[N Num];
    [N Lvalue];
    [N Incrop; N Lvalue];
    [N Lvalue; N Incrop];
    [T"("; N Expr; T")"]]
     | Lvalue ->
   [[T"$"; N Expr]]
     | Incrop ->
   [[T"++"];
    [T"--"]]
     | Binop ->
   [[T"+"];
    [T"-"]]
     | Num ->
   [[T"0"]; [T"1"]; [T"2"]; [T"3"]; [T"4"];
    [T"5"]; [T"6"]; [T"7"]; [T"8"]; [T"9"]]);;

let converted_grammar = convert_grammar (Expr, awksub_rules);;
let convert_grammar_test0 = (snd awkish_grammar) Expr = (snd converted_grammar) Expr;;
let convert_grammar_test1 = (snd awkish_grammar) Term = (snd converted_grammar) Term;;
let convert_grammar_test2 = (snd awkish_grammar) Lvalue = (snd converted_grammar) Lvalue;;
let convert_grammar_test3 = (snd awkish_grammar) Incrop = (snd converted_grammar) Incrop;;
let convert_grammar_test4 = (snd awkish_grammar) Binop = (snd converted_grammar) Binop;;
let convert_grammar_test5 = (snd awkish_grammar) Num = (snd converted_grammar) Num;;

let accept_all string = Some string
let accept_empty_suffix = function
   | _::_ -> None
   | x -> Some x

(* An example grammar for a small subset of Awk.
   This grammar is not the same as Homework 1; it is
   instead the same as the grammar under
   "Theoretical background" above.  *)

type awksub_nonterminals =
  | Expr | Term | Lvalue | Incrop | Binop | Num

let awkish_grammar =
  (Expr,
   function
     | Expr ->
         [[N Term; N Binop; N Expr];
          [N Term]]
     | Term ->
	 [[N Num];
	  [N Lvalue];
	  [N Incrop; N Lvalue];
	  [N Lvalue; N Incrop];
	  [T"("; N Expr; T")"]]
     | Lvalue ->
	 [[T"$"; N Expr]]
     | Incrop ->
	 [[T"++"];
	  [T"--"]]
     | Binop ->
	 [[T"+"];
	  [T"-"]]
     | Num ->
	 [[T"0"]; [T"1"]; [T"2"]; [T"3"]; [T"4"];
	  [T"5"]; [T"6"]; [T"7"]; [T"8"]; [T"9"]])

let test0 =
  ((make_matcher awkish_grammar accept_all ["ouch"]) = None)

let test1 =
  ((make_matcher awkish_grammar accept_all ["9"])
   = Some [])

let test2 =
  ((make_matcher awkish_grammar accept_all ["9"; "+"; "$"; "1"; "+"])
   = Some ["+"])

let test3 =
  ((make_matcher awkish_grammar accept_empty_suffix ["9"; "+"; "$"; "1"; "+"])
   = None)

(* This one might take a bit longer.... *)
let test4 =
 ((make_matcher awkish_grammar accept_all
     ["("; "$"; "8"; ")"; "-"; "$"; "++"; "$"; "--"; "$"; "9"; "+";
      "("; "$"; "++"; "$"; "2"; "+"; "("; "8"; ")"; "-"; "9"; ")";
      "-"; "("; "$"; "$"; "$"; "$"; "$"; "++"; "$"; "$"; "5"; "++";
      "++"; "--"; ")"; "-"; "++"; "$"; "$"; "("; "$"; "8"; "++"; ")";
      "++"; "+"; "0"])
  = Some [])

let test5 =
  (parse_tree_leaves (Node ("+", [Leaf 3; Node ("*", [Leaf 4; Leaf 5])]))
   = [3; 4; 5])

let nathan_test0 =
  (parse_tree_leaves
    (Node (
        "+",
        [
          Leaf 3;
          Node (
            "*",
            [
              Leaf 4;
              Leaf 5;
              Node (
                "/",
                [
                  Leaf 7;
                  Node (
                    "-",
                    [
                      Leaf 8
                    ]
                  );
                  Leaf 9
                ]
              )
            ]
          )
        ]
    ))
   = [3; 4; 5; 7; 8; 9])

let nathan_test1 =
  (parse_tree_leaves
    (Node (Expr,
     [Node (Term,
      [Node (Lvalue,
             [Leaf "$";
        Node (Expr,
              [Node (Term,
               [Node (Num,
                [Leaf "1"])])])]);
       Node (Incrop, [Leaf "++"])]);
      Node (Binop,
      [Leaf "-"]);
                  Node (Expr,
            [Node (Term,
             [Node (Num,
                    [Leaf "2"])])])])))
  = ["$"; "1"; "++"; "-"; "2"]

let small_awk_frag = ["$"; "1"; "++"; "-"; "2"]

let tree_test0 = make_parser awkish_grammar small_awk_frag
let tree_test1 = make_parser awkish_grammar ["3"; "+"; "4"]

let test6 =
  ((make_parser awkish_grammar small_awk_frag)
   = Some (Node (Expr,
     [Node (Term,
      [Node (Lvalue,
             [Leaf "$";
        Node (Expr,
              [Node (Term,
               [Node (Num,
                [Leaf "1"])])])]);
       Node (Incrop, [Leaf "++"])]);
      Node (Binop,
      [Leaf "-"]);
                  Node (Expr,
            [Node (Term,
             [Node (Num,
                    [Leaf "2"])])])])))

let test7 =
  match make_parser awkish_grammar small_awk_frag with
    | Some tree -> parse_tree_leaves tree = small_awk_frag
    | _ -> false
