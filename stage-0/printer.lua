local utils = require "stage-0/utils"

local function serialize(node, out, ind)
  ind = ind or ''
  out = out or {}
  if type(node) == 'table' and node.type then
    out[#out + 1] = ("%s {\n"):format(node.type)
    for k, v in pairs(node) do
      if k ~= 'type' then
        out[#out + 1] = ("%s%s = "):format(ind .. '  ', k)
        serialize(v, out, ind .. '  ')
        out[#out + 1] = "\n"
      end
    end
    out[#out + 1] = ("%s}"):format(ind)
  elseif utils.issymbol(node) then
    out[#out + 1] = utils.symbolname(node)
  elseif type(node) == 'table' then
    out[#out + 1] = "{\n"
    for _, v in ipairs(node) do
      out[#out + 1] = ("%s"):format(ind .. '  ')
      serialize(v, out, ind .. '  ')
      out[#out + 1] = "\n"
    end
    out[#out + 1] = ("%s}\n"):format(ind)
  else
    out[#out + 1] = tostring(node)
  end
  return out
end

return function(ast) return table.concat(serialize(ast)) end
