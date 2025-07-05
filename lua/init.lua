local characters = require('blockstring.characters')

local blk = {
  characters = characters,
}

function blk.get_visual_selection()
  local vstart = vim.fn.getpos("'<")
  local vend = vim.fn.getpos("'>")

  local n_lines = math.abs(vend[2] - vstart[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, vstart[2] - 1, vend[2], false)
  lines[1] = string.sub(lines[1], vend[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, vend[3] - vstart[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, vend[3])
  end
  return lines
end

function blk.block_string_multiline(in_string)
  local final_table = {}

  if type(in_string) == "table" then
    for _,str in pairs(in_string) do
      local inner_table = blk.block_string_multiline(str)
      for _,entry in pairs(inner_table) do
        table.insert(final_table, entry)
      end
    end
    return final_table
  end

  for i=1,11 do
    local str = ""
    for c in in_string:gmatch"." do
      local chr = string.byte(c,1)-31
      if chr >= 0 then
        str = str .. blk.characters[chr][i]
      end
    end
    table.insert(final_table, str)
  end

  return final_table
end

function blk.block_string(in_string)
  local final_string = ""

  for i=1,11 do
    for c in in_string:gmatch"." do
      local chr = string.byte(c,1)-31
      if chr >= 0 then
        final_string = final_string .. blk.characters[chr][i]
      end
    end
    final_string = final_string .. "\n"
  end

  return final_string
end

function blk.block_string_v()
  lines = blk.get_visual_selection()
  local ret = blk.block_string_multiline(lines)
  return vim.fn.appendbufline(vim.fn.bufname(), vim.fn.line('.'), ret)
end

return blk
