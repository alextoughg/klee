#lang racket
(define (SMTCond l)
  (match l
    [(list pc result) (list 'ite pc result -1)]
    [(cons pc1 (cons result1 l)) (list 'ite pc1
                                             result1
                                             (SMTCond l))]))

;(displayln (SMTCond (list '(and (x > 0) (y > 0)) '(+ x y))))
;(displayln (SMTCond (list '(and (x > 0) (y > 0)) '(+ x y) '(or (x < 5) (= y 3)) '(* x 2) '(< x y) 6)))

(define (SMTCondFunction f)
  (let ([finp (open-input-file f)]
        [last-line ""])
    (define (BuildInputList)
      (let* ([inp (current-input-port)]
             [ln (read-line inp)])
        (if (eof-object? ln)
            (list)
            (cons (string->symbol ln) (BuildInputList)))))
    (define (BuildPathAndConditionList f)
      (let* ([ln (read-line finp)])
        (if (eof-object? ln)
            (list last-line)
             (match ln
               [(regexp #rx"^\\(assert") (cons ln (BuildPathAndConditionList f))]
               [s (begin
                    (set! last-line s)
                    (BuildPathAndConditionList f))]))))
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
    (append (FunctionSignature (BuildInputList)) (list (Body (BuildPathAndConditionList f))))))

;(displayln (SMTCondFunction (list 'Int 'x 'Int) (list '(and (x > 0) (y > 0)) '(+ x y))))
;(displayln (SMTCondFunction (list 'Int 'x 'Int 'y 'Int) (list '(and (x > 0) (y > 0)) '(+ x y) '(or (x < 5) (= y 3)) '(* x 2) '(< x y) 6)))

;(displayln (SMTCondFunction (list '(and (x > 0) (y > 0)) '(+ x y))))
;(displayln (SMTCondFunction (list '(and (x > 0) (y > 0)) '(+ x y) '(or (x < 5) (= y 3)) '(* x 2) '(< x y) 6)))

(displayln (SMTCondFunction "6.smt"))

#|(set-logic QF_AUFBV )
(declare-fun x () (Array (_ BitVec 32) (_ BitVec 8) ) )
(assert (let ( (?B1 (concat  (select  x (_ bv3 32) ) (concat  (select  x (_ bv2 32) ) (concat  (select  x (_ bv1 32) ) (select  x (_ bv0 32) ) ) ) ) ) ) (and  (and  (and  (=  false (=  (_ bv4 32) ?B1 ) ) (bvslt  ?B1 (_ bv4 32) ) ) (=  false (=  (_ bv2 32) ?B1 ) ) ) (=  false (bvslt  ?B1 (_ bv2 32) ) ) ) ) )
(check-sat)
(exit)
(_ bv1 32)|#

#|
(define-fun smtcond ((x Int)) Int
  (ite (assert (let ( (?B1 (concat  (select  x (_ bv3 32) ) (concat  (select  x (_ bv2 32) ) (concat  (select  x (_ bv1 32) ) (select  x (_ bv0 32) ) ) ) ) ) ) (and  (and  (and  (=  false (=  (_ bv4 32) ?B1 ) ) (bvslt  ?B1 (_ bv4 32) ) ) (=  false (=  (_ bv2 32) ?B1 ) ) ) (=  false (bvslt  ?B1 (_ bv2 32) ) ) ) ) )
       (_ bv1 32)
       -1))
|#