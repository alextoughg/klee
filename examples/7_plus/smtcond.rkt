#lang racket
(define (SMTCond l)
  (match l
    [(list pc result) (list 'ite pc result -1)]
    [(cons pc1 (cons result1 l)) (list 'ite pc1
                                             result1
                                             (SMTCond l))]))

;(displayln (SMTCond (list '(and (x > 0) (y > 0)) '(+ x y))))
;(displayln (SMTCond (list '(and (x > 0) (y > 0)) '(+ x y) '(or (x < 5) (= y 3)) '(* x 2) '(< x y) 6)))

(define (SMTCondFunction)
  (define (BuildInputList)
    (let* ([inp (current-input-port)]
           [ln (read-line inp)])
      (if (eof-object? ln)
          (list)
          (cons (string->symbol ln) (BuildInputList)))))
  (define (SMTFileList)
    (define (smt-file? f)
      (match f
        [(regexp #rx"\\.smt2$") #t]
        [_ #f]))
    (filter smt-file? (map path->string (directory-list))))
  (define (BuildPathAndConditionList f)
    (let ([finp (open-input-file f)]
          [last-line ""])
      (define (BuildPathAndConditionListHelper)
        (let* ([ln (read-line finp)])
          (if (eof-object? ln)
              (list last-line)
              (match ln
                [(regexp #rx"^\\(assert") (cons ln (BuildPathAndConditionListHelper))]
                [s (begin
                     (set! last-line s)
                     (BuildPathAndConditionListHelper))]))))
      (BuildPathAndConditionListHelper)))
  ; e is a string that contains a parenthesized s-expression
  ; converts bit vector operations into operations using primitive types, i.e. Ints
  (define (Transform e)
    (let ([t (read (open-input-string e))])
      (define (Transform-helper s)
        (match s
          [`(_ ,b ,v) (string->number (car (regexp-match* #rx"^bv(.+)" #:match-select cadr (symbol->string b))))]
          [`(assert ,cond) (Transform-helper cond)]
          [`(concat (select ,x ,c) ,p2) x]
          [`(= ,a ,b) (list '= (Transform-helper a) (Transform-helper b))]
          [`(and ,a ,b) (list 'and (Transform-helper a) (Transform-helper b))]
          [`(bvule ,a ,b) (list '<= (Transform-helper a) (Transform-helper b))]
          [`(bvugt ,a ,b) (list '> (Transform-helper a) (Transform-helper b))]
          [`(bvuge ,a ,b) (list '>= (Transform-helper a) (Transform-helper b))]
          [`(bvslt ,a ,b) (list '< (Transform-helper a) (Transform-helper b))]
          [`(bvsle ,a ,b) (list '<= (Transform-helper a) (Transform-helper b))]
          [`(bvsgt ,a ,b) (list '> (Transform-helper a) (Transform-helper b))]
          [`(bvsge ,a ,b) (list '>= (Transform-helper a) (Transform-helper b))]
          [`(bvadd ,a ,b) (list '+ (Transform-helper a) (Transform-helper b))]
          [`(bvmul ,a ,b) (list '* (Transform-helper a) (Transform-helper b))]
          [`(bvudiv ,a ,b) (list 'div (Transform-helper a) (Transform-helper b))]
          [`(bvurem ,a ,b) (list 'mod (Transform-helper a) (Transform-helper b))]
          [`(bvnot ,a) (list 'not (Transform-helper a))]
          [`(bvand ,a ,b) (list 'and (Transform-helper a) (Transform-helper b))]
          [`(bvor ,a ,b) (list 'or (Transform-helper a))]
          [`(bvneg ,a) (list '- (Transform-helper a))]
          [`(let ((,helper-var ,value)) ,c) (list 'let (list (list helper-var (Transform-helper value))) (Transform-helper c))]
          [s s]))
      (Transform-helper t)))
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
      [`(,pc ,result) (list 'ite pc result -1)]
      [(cons pc1 (cons result1 l)) (list 'ite pc1
                                         result1
                                         (Body l))]))
  (define (PutLetsOutside l)
    (match l
      [`(ite (let ,binding ,cond) ,then-stmt ,else-stmt) (list 'let binding (list 'ite cond then-stmt (PutLetsOutside else-stmt)))]
      [_ l]))
  (append (FunctionSignature (BuildInputList)) (list
                                                (PutLetsOutside
                                                 (Body
                                                  (map Transform
                                                       (apply append (map
                                                                      BuildPathAndConditionList
                                                                      (SMTFileList))))))))
)

;(displayln (SMTCondFunction (list 'Int 'x 'Int) (list '(and (x > 0) (y > 0)) '(+ x y))))
;(displayln (SMTCondFunction (list 'Int 'x 'Int 'y 'Int) (list '(and (x > 0) (y > 0)) '(+ x y) '(or (x < 5) (= y 3)) '(* x 2) '(< x y) 6)))

;(displayln (SMTCondFunction (list '(and (x > 0) (y > 0)) '(+ x y))))
;(displayln (SMTCondFunction (list '(and (x > 0) (y > 0)) '(+ x y) '(or (x < 5) (= y 3)) '(* x 2) '(< x y) 6)))

(SMTCondFunction)

#|(set-logic QF_AUFBV )
(declare-fun x () (Array (_ BitVec 32) (_ BitVec 8) ) )
(assert (let ( (?B1 (concat  (select  x (_ bv3 32) ) (concat  (select  x (_ bv2 32) ) (concat  (select  x (_ bv1 32) ) (select  x (_ bv0 32) ) ) ) ) ) ) (and  (and  (and  (=  false (=  (_ bv4 32) ?B1 ) ) (bvslt  ?B1 (_ bv4 32) ) ) (=  false (=  (_ bv2 32) ?B1 ) ) ) (=  false (bvslt  ?B1 (_ bv2 32) ) ) ) ) )
(check-sat)
(exit)
(_ bv1 32)|#


#;(define-fun smtcond ((x Int)) Int
#;(ite (assert (let ( (?B1 (concat  (select  x (_ bv3 32) ) (concat  (select  x (_ bv2 32) ) (concat  (select  x (_ bv1 32) ) (select  x (_ bv0 32) ) ) ) ) ) ) (and  (and  (and  (=  false (=  (_ bv4 32) ?B1 ) ) (bvslt  ?B1 (_ bv4 32) ) ) (=  false (=  (_ bv2 32) ?B1 ) ) ) (=  false (bvslt  ?B1 (_ bv2 32) ) ) ) ) )
     (_ bv1 32)
     (ite (assert (=  (_ bv40 32) (concat  (select  x (_ bv3 32) ) (concat  (select  x (_ bv2 32) ) (concat  (select  x (_ bv1 32) ) (select  x (_ bv0 32) ) ) ) ) ) )
          (_ bv4 32)
          -1)))

#;(match (read (open-input-string "(p 6 32)"))
  [(list 'p x y) x]
  [_ 4])


#;(Transform "(_ bv4 32)")
#;(Transform "(assert (=  (_ bv40 32) (concat  (select  x (_ bv3 32) ) (concat  (select  x (_ bv2 32) ) (concat  (select  x (_ bv1 32) ) (select  x (_ bv0 32) ) ) ) ) ) )")

#;(eval '(_ bv40 32))



#|(set-logic QF_AUFBV )
(declare-fun x () (Array (_ BitVec 32) (_ BitVec 8) ) )
(assert
 (let
     ( (?B1 (concat  (select  x (_ bv3 32) ) (concat  (select  x (_ bv2 32) ) (concat  (select  x (_ bv1 32) ) (select  x (_ bv0 32) ) ) ) ) ) )
   (and  (and  (and  (=  false (=  (_ bv4 32) ?B1 ) ) (bvslt  ?B1 (_ bv4 32) ) ) (=  false (=  (_ bv2 32) ?B1 ) ) ) (=  false (bvslt  ?B1 (_ bv2 32) ) ) ) ) )
(check-sat)
(exit)
(_ bv1 32)|#

#;(define-fun smtcond ((x Int)) Int
  (ite (assert (let ((?B1 x)) (and (and (and (= false (= 4 ?B1)) (< ?B1 4)) (= false (= 2 ?B1))) (= false (< ?B1 2))))) 1 (ite (assert (= 4 x)) 4 -1)))