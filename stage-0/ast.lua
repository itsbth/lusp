local function merge(a, b)
  for k, v in pairs(b) do
    a[k] = v
  end
  return a
end

local function node(type)
  return function(keys)
    return merge({ type = type }, keys)
  end
end

return {
  -- other
  identifier = node "identifier",
  -- expressions
  literal = node "literal",
  binop = node "binop",
  unop = node "unop",
  call = node "call",
  function_ = node "function",
  -- statements
  assignment = node "assignment",
  return_ = node "return",
  local_ = node "local",
  if_ = node "if"
}
