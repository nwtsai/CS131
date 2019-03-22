(* Types *)
type ('nonterminal, 'terminal) parse_tree =
	| Node of 'nonterminal * ('nonterminal, 'terminal) parse_tree list
	| Leaf of 'terminal

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

let english_sentence_tree = (
	Node (
		Sentence,
		[
			Node (
				NP,
				[
					Node (
						Determiner,
						[Leaf "the"]
					);
					Node (
						Noun,
						[Leaf "dog"]
					)
				]
			);
			Node (
				VP,
				[
					Node (
						Verb,
						[Leaf "is"]
					);
					Node (
						NP,
						[
							Node (
								Determiner,
								[Leaf "a"]
							);
							Node (
								Noun,
								[Leaf "cat"]
							);
						]
					);
					Node (
						PP,
						[
							Node (
								Preposition,
								[Leaf "near"]
							);
							Node (
								NP,
								[
									Node (
										Determiner,
										[Leaf "a"]
									);
									Node (
										Noun,
										[Leaf "mouse"]
									)
								]
							)
						]
					)
				]
			)
		]
	)
)

let english_sentence = ["the"; "dog"; "is"; "a"; "cat"; "near"; "a"; "mouse"]

let english_leaves = parse_tree_leaves english_sentence_tree = english_sentence
