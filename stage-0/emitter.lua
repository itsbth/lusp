local utils = require "stage-0/utils"
local nodes = {}

local function emit(ast)
  if not nodes[ast.type] then
    error(("don't know how to emit code for %s"):format(ast.type))
  end
  return nodes[ast.type](ast)
end

function nodes:identifier()
  return self.name
end

function nodes:literal()
  return ('%q'):format(self.value)
end

function nodes:assignment()
  return ("%s = %s"):format(emit(self.lhs), emit(self.rhs))
end

function nodes:binop()
  return ("(%s %s %s)"):format(emit(self.lhs), self.op, emit(self.rhs))
end

function nodes:call()
  return ("%s(%s)"):format(
    emit(self.fun),
    table.concat(
      utils.map(emit, self.args),
      ", "
    )
  )
end

nodes["function"] = function(self)
  return ("function %s(%s) %s end"):format(
    self.name or '',
    table.concat(self.args, ', '),
    table.concat(utils.map(emit, self.body), ' ')
  )
end

nodes["if"] = function(self)
  return ("if %s then %s else %s end"):format(
    emit(self.cond),
    table.concat(utils.map(emit, self.iftrue)),
    table.concat(utils.map(emit, self.iffalse))
  )
end

nodes["local"] = function(self)
  return ("local %s"):format(
    table.concat(self.vars, ", ")
  )
end

return emit
