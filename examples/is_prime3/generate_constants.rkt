#lang racket
(define (BuildInputList)
    (let* ([inp (current-input-port)]
           [ln (read-line inp)])
      (if (eof-object? ln)
          (list)
          (cons (string->symbol ln) (BuildInputList)))))

(define (GenerateConstants input-list)
    (let ([param (cdr input-list)])
      (PrintConstants param)))

(define (PrintConstants param)
    (match param
      [(list name type) (displayln (list 'declare-const name type))]
      [(cons name1 (cons type1 rest-of-params))
       (begin
         (displayln (list 'declare-const name1 type1))
         (PrintConstants rest-of-params))]))

(GenerateConstants (BuildInputList))

