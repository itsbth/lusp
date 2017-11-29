local AST = require "stage-0/ast"
local serialize = require "stage-0/printer"
local parse = require "stage-0/parser"
local transform = require "stage-0/transform"
local emit = require "stage-0/emitter"
local utils = require "stage-0/utils"

local source = [[
(function add (a b)
          (return (+ a b 3)))

(print (add 3 4))
(function call (fn) (fn))
(call (function () (print "hello world")))
(print (/ 1 2 3))
(if true
  (print "yay")
  (print "nay"))
(local val)
(set val 32)
(local fac)
(set fac (function (n)
  (if (< n 1)
    (return 1)
    (return (* n (fac (- n 1)))))))
(print (fac 5))
(print "escaped \" quote")
(print -32.5)
]]


local sexp = parse(source)
print(serialize(sexp))
local ast = transform(sexp)
print(serialize(ast))
local code = table.concat(utils.map(emit, ast), " ")
print(code)
local fn, err = load(code)
if not fn then
  error(err)
end
fn()
