#lang racket
(define (SMTCond l)
  (match l
    [(list pc result) (list 'ite pc result -1)]
    [(cons pc1 (cons result1 l)) (list 'ite pc1
                                             result1
                                             (SMTCond l))]))

;(displayln (SMTCond (list '(and (x > 0) (y > 0)) '(+ x y))))
;(displayln (SMTCond (list '(and (x > 0) (y > 0)) '(+ x y) '(or (x < 5) (= y 3)) '(* x 2) '(< x y) 6)))

(define (SMTCondFunction l)
  (define (FunctionSignature l)
    (list 'define-fun 'smtcond 'some-list-of-tuples 'Int))
  (define (Body l)
    (match l
    [(list pc result) (list 'ite pc result -1)]
    [(cons pc1 (cons result1 l)) (list 'ite pc1
                                             result1
                                             (Body l))]))
  (append (FunctionSignature l) (list (Body l))))

(displayln (SMTCondFunction (list '(and (x > 0) (y > 0)) '(+ x y))))
(displayln (SMTCondFunction (list '(and (x > 0) (y > 0)) '(+ x y) '(or (x < 5) (= y 3)) '(* x 2) '(< x y) 6)))
