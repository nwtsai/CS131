let accept_all string = Some string

(* A simple English grammar that explores the syntax of the English language. *)
type eng_nonterminals =
	| Sentence | NP | VP | PP | Noun | Pronoun | Verb | Preposition | Determiner

let eng_grammar =
(Sentence,
	function
		| Sentence -> [[N NP; N VP]]
		| NP -> [[N Pronoun]; [N Determiner; N Noun]]
		| VP -> [[N Verb; N NP; N PP];[N Verb; N NP]; [N Verb; N PP]; [N Verb]]
		| PP -> [[N Preposition; N NP]]
		| Noun -> [[T "cat"]; [T "dog"]; [T "mouse"]]
		| Pronoun -> [[T "i"]; [T "he"]]
		| Verb -> [[T "is"]; [T "run"]; [T "eat"]; [T "bark"]; [T "meow"]; [T "jump"]; [T "like"]]
		| Preposition -> [[T "from"]; [T "to"]; [T "on"]; [T "near"]]
		| Determiner -> [[T "a"]; [T "an"]; [T "the"]; [T "these"]; [T "this"]; [T "that"]])

let make_matcher_test = make_matcher eng_grammar accept_all ["the"; "dog"; "is"; "a"; "cat"; "near"; "a"; "mouse"; "meow"] = Some ["meow"]

(*
Parse tree of the matcher test:
                   Sentence
           /                     \
         NP                       VP    
         / \                /     |                         \
        /   \           Verb      NP                         PP 
       /     \          /       /.   \                    /      \                        
      /       \        /       /.     \.          Preposition     NP
     /         \      /       /                     |            /       \ 
Determiner   Noun    /    Determiner Noun           |        Determiner    Noun   
 /             \.   /          /        \           |          |          /
"the"       "dog"  "is"        "a"      "cat"     "near"      "a"      "mouse"  "meow"
*)

let english_sentence = ["the"; "dog"; "is"; "a"; "cat"; "near"; "a"; "mouse"]

let make_parser_test =
	match make_parser eng_grammar english_sentence with
		| Some tree -> parse_tree_leaves tree = english_sentence
		| _ -> false
