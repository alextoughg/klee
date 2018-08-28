#lang racket
(define (SMTCondFunction)
  #| Input list for FunctionSignature |#
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
	  [`(bvsub ,a ,b) (list '- (Transform-helper a) (Transform-helper b))]
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
  #| Input: (funcname ret-type (param1 type 1) (param2 type2) ... (paran typen))|#
  (define (FunctionSignature input-list)
    (let
        ([funcname (car input-list)]
         [ret_type (car (cdr input-list))]
         [param (cdr (cdr input-list))])
      (list 'define-fun funcname (ParamTypeList param) ret_type)))
  (define (Body l)
    (match l
      [`(,pc ,result) (list 'ite pc result -1)]
      [(cons pc1 (cons result1 l)) (list 'ite pc1
                                         result1
                                         (Body l))]))
  (define (PutLetsOutside l)
    (match l
      [`(ite (let ,binding ,cond) ,then-stmt ,else-stmt) (list 'let binding (list 'ite cond then-stmt (PutLetsOutside else-stmt)))]
      [`(ite ,c ,then-stmt ,else-stmt) (list 'ite c (PutLetsOutside then-stmt) (PutLetsOutside else-stmt))]
      [l l]))
  (displayln
   (append (FunctionSignature (BuildInputList)) (list
                                                (PutLetsOutside
                                                 (Body
                                                  (map Transform
                                                       (apply append (map
                                                                      BuildPathAndConditionList
                                                                      (SMTFileList)))))))))
)

(SMTCondFunction)
