local AST = require "stage-0/ast"
local utils = require "stage-0/utils"

local special, expression = {}

local operator = function(op)
  return function(self)
    return utils.reduce1(
      function(a, b)
        return AST.binop {
          op = op,
          lhs = a,
          rhs = b
        }
      end,
      utils.map(expression, self)
    )
  end
end

function special:set()
  local to, val = table.unpack(self)

  return AST.assignment {
    lhs = expression(to),
    rhs = expression(val)
  }
end

special["local"] = function(self)
  return AST.local_ {
    vars = utils.map(utils.symbolname, self)
  }
end

special["function"] = function(self)
  local name
  if utils.issymbol(self[1]) then
    name, self = utils.split(table.unpack(self))
    name = utils.symbolname(name)
  end
  local args, body = utils.split(table.unpack(self))
  return AST.function_ {
    name = name,
    args = utils.map(utils.symbolname, args),
    body = utils.map(expression, body)
  }
end

special["if"] = function(self)
  local cond, tb, fb = table.unpack(self)
  return AST.if_ {
    cond = expression(cond),
    iftrue = { expression(tb) },
    iffalse = { expression(fb) }
  }
end

special["+"] = operator("+")
special["-"] = operator("-")
special["*"] = operator("*")
special["/"] = operator("/")
special[".."] = operator("..")
special["<"] = operator("<")
special[">"] = operator(">")
special["="] = operator("==")

function expression(node)
  if type(node) == 'table' and node.sym then
    return AST.identifier {
      name = node.sym
    }
  elseif type(node) == 'table' then
    local fn, rest = utils.split(table.unpack(node))
    local name = fn
    if utils.issymbol(name) then name = utils.symbolname(name) end
    if special[name] then
      return special[name](rest)
    end
    return AST.call {
      fun = expression(fn),
      args = utils.map(expression, rest)
    }
  end
  return AST.literal { value = node }
end
return function(sexp)
  return utils.map(expression, sexp)
end
