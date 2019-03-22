; #lang racket

; Define a symbol that represents the unicode lambda character
(define lambda_sym
	(string->symbol "\u03BB")
)

; Converts an arbitrary number of arguments into a list
(define (ret . x)
	x
)

; Sticks ! in between two bound variables
(define (bind x y)
	(string->symbol
		(string-append
			(symbol->string x)
			"!"
			(symbol->string y)
		)
	)
)

; Finds bindings of x and y
(define (lambda-arg-binder xy xlist ylist x y)
	(cond
		; If x and y are not lists and are single argument and not equal
		[(and (not (list? x)) (not (list? y)) (not (equal? x y)))
			(list (cons (bind x y) xy) (cons x xlist) (cons y ylist))
		]
		; If either x is not a list or y is not a list
		[(or (not (list? x)) (not (list? y)))
			(list xy xlist ylist)
		]
		; Return bindings when lists are empty
		[(and (equal? x '()) (equal? y '()) )
			(list xy xlist ylist)
		]
		; If the first variables in x and y are not equal, create the binding
		[(not (equal? (car x) (car y)))
			(lambda-arg-binder
				(cons (bind (car x) (car y)) xy)
				(cons (car x) xlist)
				(cons (car y) ylist)
				(cdr x)
				(cdr y)
			)
		]
		; Recursive call on the rest of x and y
		[else
			(lambda-arg-binder
				xy
				xlist
				ylist
				(cdr x)
				(cdr y)
			)
		]
	)
)

; Initializer function for the lambda argument binder
(define (lambda-arg-binder-init x y)
	(lambda-arg-binder '() '() '() x y)
)

; Finds the index of an element
(define (idx index lst v)
	(if
		(equal? v (car lst))
		index
		(idx (+ index 1) (cdr lst) v)
	)
)

; Replaces joint symbols in expression
(define (parse-replace expression should-swap to-swap)
	(cond
		; Base case of empty list
		[(equal? expression '())
			'()
		]
		; If we encounter a lambda, just skip this expression and return
		[(or
			(equal? (car expression) 'lambda)
			(equal? (car expression) lambda_sym))
			expression
		]
		; Recursively call this function on the first item if it is a list
		[(list? (car expression))
			(cons
				(parse-replace (car expression) should-swap to-swap)
				(parse-replace (cdr expression) should-swap to-swap)
			)
		]
		; If the current item is not a list and we should swap it
		[(member (car expression) should-swap)
			; Find the item at this index and cons it to a recursive call
			(cons
				(list-ref to-swap (idx 0 should-swap (car expression)))
				(parse-replace (cdr expression) should-swap to-swap)
			)
		]
		; If the current item should not be swapped, just recurse
		[else
			(cons
				(car expression)
				(parse-replace
					(cdr expression)
					should-swap
					to-swap
				)
			)
		]
	)
)

; Compares two expressions and returns the lambda swapped bounded difference
; expression
(define (expr-compare x y)
	(cond
		; If x and y are recursively equivalent, simply return one of them
		[(equal? x y)
			x
		]
		; If x and y are boolean values, return % or (not %)
		[(and (boolean? x) (boolean? y))
			(if x '% '(not %))
		]
		; If x and y are both not lists
		[(not (and (list? x) (list? y)))
			(ret 'if '% x y)
		]
		; If x and y are lists of different lengths
		[(not (eqv? (length x) (length y)))
			(ret 'if '% x y)
		]
		; If both lists are length 0
		[(= (length x) 0)
			(ret 'if '% x y)
		]
		; If only the head of x or head of y is if
		[(or
			(and (eqv? (car x) 'if) (not (eqv? (car y) 'if)))
			(and (eqv? (car y) 'if) (not (eqv? (car x) 'if))))
			(ret 'if '% x y)
		]
		; If quote starts in any of the expressions
		[(or (eqv? (car x) 'quote) (eqv? (car y) 'quote))
			(ret 'if '% x y)
		]
		; If some form of lambda is detected in the beginning of both lists
		[(and
			(or (eqv? (car x) 'lambda) (eqv? (car x) lambda_sym))
			(or (eqv? (car y) 'lambda) (eqv? (car y) lambda_sym)))
			(cond
				; If both lambdas take a single argument not given in a list
				[(and
					(not (list? (cadr x)))
					(not (list? (cadr y))))
					(let ((new-expr
						(lambda-arg-binder-init
							(cadr x)
							(cadr y)
						)))
						; Check if we should cons the lambda symbol or 'lambda
						(if
							(or
								(and
									(eqv? (car x) 'lambda)
									(eqv? (car y) lambda_sym)
								)
								(and
									(eqv? (car x) lambda_sym)
									(eqv? (car y) 'lambda)
								)
								(and
									(eqv? (car x) lambda_sym)
									(eqv? (car y) lambda_sym)
								)
							)
							(cons
								lambda_sym
								(expr-compare
									(parse-replace
				 						(cdr x)
				 						(cadr new-expr)
				 						(car new-expr)
				 					) 
				 					(parse-replace
				 						(cdr y)
				 						(caddr new-expr)
				 						(car new-expr)
				 					)
								)
							)
							(cons
								'lambda
								(expr-compare
									(parse-replace
				 						(cdr x)
				 						(cadr new-expr)
				 						(car new-expr)
				 					) 
				 					(parse-replace
				 						(cdr y)
				 						(caddr new-expr)
				 						(car new-expr)
				 					)
								)
							)
						)
					)
				]
				; At this point, one lambda must have an argument list. If only
				; one of them is a list, just return
				[(or (not (list? (cadr x))) (not (list? (cadr y))))
					(ret 'if '% x y)
				]
				; At this point, both lambdas must take arguments in list form.
				; If the lenths of the argument lists do not agree, just return
				[(not (eqv? (length (cadr x)) (length (cadr y))))
					(ret 'if '% x y)
				]
				; At this point, we know both lambdas must take list arguments
				; that have the same length, so make a recursive call
				[else
					; Bind the lambda replacer expression to new-expr
					(let ((new-expr
						(lambda-arg-binder-init
							(cadr x)
							(cadr y)
						)))
						; Check if we should cons the lambda symbol or 'lambda
				 		(if
							(or
								(and
									(eqv? (car x) 'lambda)
									(eqv? (car y) lambda_sym)
								)
								(and
									(eqv? (car x) lambda_sym)
									(eqv? (car y) 'lambda)
								)
								(and
									(eqv? (car x) lambda_sym)
									(eqv? (car y) lambda_sym)
								)
							)
							; Recursively call and cons the lambda symbol
					 		(cons
					 			lambda_sym
					 			(expr-compare
				 					(parse-replace
				 						(cdr x)
				 						(cadr new-expr)
				 						(car new-expr)
				 					) 
				 					(parse-replace
				 						(cdr y)
				 						(caddr new-expr)
				 						(car new-expr)
				 					)
				 				)
				 			)
				 			; Else cons with the 'lambda keyword
				 			(cons
					 			'lambda
					 			(expr-compare
				 					(parse-replace
				 						(cdr x)
				 						(cadr new-expr)
				 						(car new-expr)
				 					) 
				 					(parse-replace
				 						(cdr y)
				 						(caddr new-expr)
				 						(car new-expr)
				 					)
				 				)
				 			)
					 	)
			 		)
				]
			)
		]
		; At this point, there is a possibility that only one head is some form
		; of lambda, but both cannot be some form of lambda. If only one of the
		; heads is some form of lambda, just return
		[(or
			(eqv? (car x) 'lambda)
			(eqv? (car x) lambda_sym)
			(eqv? (car y) 'lambda)
			(eqv? (car y) lambda_sym))
			(ret 'if '% x y)
		]
		; Otherwise, recursively call this function if no special case matches
		[else
			(cons
				(expr-compare (car x) (car y))
				(expr-compare (cdr x) (cdr y))
			)
		]
	)
)

; Returns true if the evaluation is as expected when setting a respective %
(define (test-expr-compare x y)
	(let ((test (expr-compare x y)))
		(and
			(equal?
				(eval (cons 'let (cons '((% #t)) (cons test '() ))))
				(eval x)
			)
			(equal?
				(eval (cons 'let (cons '((% #f)) (cons test '() ))))
				(eval y)
			)
		)
	)
)

; A test case for the x expression that covers all of the specifications
(define test-expr-x
	`((lambda (w x y z)
		(if 
			(eqv? ((,lambda_sym (o p) (+ o p)) w x) y)
			(if
				(and
					(equal?
						(list (quote w) (quote x))
						(cons (quote w) (cons (quote x) '()))
					)
					z
				)
				w
				x
			)
			(+ w (+ x y))
		)
	) 1 2 3 #t)
)

; A test case for the y expression that covers all of the specifications
(define test-expr-y
	`((,lambda_sym (a b c d)
		(if 
			(eqv? ((lambda (m n) (+ n m)) a b) c)
			(if
				(and
					(equal?
						(list (quote a) (quote b))
						(cons (quote a) (cons (quote b) '()))
					)
					d
				)
				a
				b
			)
			(+ a (+ b c))
		)
	) 1 2 4 #f)
)
