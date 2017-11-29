local END = {}

local function try(code, map, idx)
  for k, v in pairs(map) do
    local s, e = code:find(k, idx)
    if s then
      print(
        ("found %q via %s at %d"):format(code:sub(s, e), k, idx)
      )
      return e + 1, v, code:sub(s, e)
    end
  end
  error(("no patterns matching '%s'[...] at %d"):format(code:sub(idx, idx + 2), idx))
end

local function run(code, map, idx)
  local out = {}
  local fn, val, ma
  repeat
    idx, fn, ma = try(code, map, idx)
    if fn and fn ~= END then
      idx, val = fn(ma, code, idx)
      if val then
        out[#out + 1] = val
      end
    end
  until not fn or fn == END
  return idx, out
end

local T = {
  ignore = function(_, _, idx) return idx end,
  transform = function(tr) return function(val, _, idx) return idx, tr(val) end end,
  ident = function(val) return val end
}

local program, comment, string_

comment = {
  ["^\n"] = END,
  ["^[^\n]+"] = T.ignore,
}

string_ = {
  ["^[^\\\"]+"] = T.transform(T.ident),
  ["^\\\""] = T.transform(function() return '"' end),
  ["^\""] = END
}

program = {
  ["^%("] = function(_, code, idx)
    return run(code, program, idx)
  end,
  ["^;"] = function(_, code, idx)
    idx, _ = run(code, comment, idx)
    return idx
  end,
  ["^\""] = function(_, code, idx)
    local str
    idx, str = run(code, string_, idx)
    return idx, table.concat(str)
  end,
  ["^-?[0-9.]+"] = T.transform(tonumber),
  ["^[a-z+%-*/<>=!]+"] = T.transform(function(ident) return { sym = ident } end),
  ["^[ \n]+"] = T.ignore,
  ["^%)"] = END,
  ["^$"] = END,
}
local function parse(code)
  local _, ret = run(code, program, 1)
  return ret
end

return parse
