#lang racket

(regexp-match* #rx"" (car (vector->list (current-command-line-arguments))))
