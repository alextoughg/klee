#lang racket
(define (SMTCond l)
  (match l
    [(list pc result) (list 'ite pc result -1)]
    [(cons pc1 (cons result1 l)) (list 'ite pc1
                                             result1
                                             (SMTCond l))]))

;(displayln (SMTCond (list '(and (x > 0) (y > 0)) '(+ x y))))
;(displayln (SMTCond (list '(and (x > 0) (y > 0)) '(+ x y) '(or (x < 5) (= y 3)) '(* x 2) '(< x y) 6)))

(define (SMTCondFunction input-list l)
  (define (ParamTypeList param)
    (match param
      [(list name type) (list (list name type))]
      [(cons name1 (cons type1 rest-of-params))
       (cons (list name1 type1) (ParamTypeList rest-of-params))]))
  (define (FunctionSignature input-list)
    (let ([ret_type (car input-list)]
          [param (cdr input-list)])
     (list 'define-fun 'smtcond (ParamTypeList param) ret_type)))
  (define (Body l)
    (match l
    [(list pc result) (list 'ite pc result -1)]
    [(cons pc1 (cons result1 l)) (list 'ite pc1
                                             result1
                                             (Body l))]))
  (append (FunctionSignature input-list) (list (Body l))))

(displayln (SMTCondFunction (list 'Int 'x 'Int) (list '(and (x > 0) (y > 0)) '(+ x y))))
(displayln (SMTCondFunction (list 'Int 'x 'Int 'y 'Int) (list '(and (x > 0) (y > 0)) '(+ x y) '(or (x < 5) (= y 3)) '(* x 2) '(< x y) 6)))
