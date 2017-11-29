local function map(fn, li)
  local o = {}
  for idx, v in ipairs(li) do
    o[idx] = fn(v)
  end
  return o
end

local function reduce1(fn, li)
  local acc
  for _, v in ipairs(li) do
    -- not the cleanest solution
    if not acc then
      acc = v
    else
      acc = fn(acc, v)
    end
  end
  return acc
end

local function split(head, ...)
  return head, { ... }
end

local function symbol(name)
  return { sym = name }
end

local function issymbol(it)
  return type(it) == 'table' and it.sym
end

local function symbolname(it)
  return it.sym
end

return {
  map = map,
  reduce1 = reduce1,
  split = split,

  -- more specialized
  symbol = symbol,
  issymbol = issymbol,
  symbolname = symbolname
}
