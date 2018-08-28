#lang racket
(define (BuildInputList)
    (let* ([inp (current-input-port)]
           [ln (read-line inp)])
      (if (eof-object? ln)
          (list)
          (cons (string->symbol ln) (BuildInputList)))))

(define (GenerateAssert input-list)
    ; Skip one input parameter (return type - we don't need this) 
    (let ([name_summary_1 (car input-list)]
          [name_summary_2 (car (cdr input-list))]
          [param (cdr (cdr (cdr input-list)))])
      (PrintAssert name_summary_1 name_summary_2 param)
      (displayln (list 'check-sat))
      (displayln (list 'get-model))))

(define (PrintAssert name_summary_1 name_summary_2 param)
  (let ([param_name_list (ParamNamesOnly param)])
    (displayln
     (list 'assert (list '= 'false (list '= (cons name_summary_1 param_name_list)
                                        (cons name_summary_2 param_name_list)))))))

(define (ParamNamesOnly param)
    (match param
      [(list name _) (list name)]
      [(cons name1 (cons _ rest-of-params))
       (cons name1 (ParamNamesOnly rest-of-params))]))

(GenerateAssert (BuildInputList))
