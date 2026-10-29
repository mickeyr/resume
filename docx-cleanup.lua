-- pandoc filter for `make resume-ats.docx`.
-- pandoc cannot evaluate the \ifdefempty / \ifblank guards in resume-ats.tex, so it
-- always takes the non-empty branch: an empty contact field leaves a blank line or a
-- bare "github.com/" prefix, and an empty list leaves an empty list and a heading
-- with nothing under it. This removes exactly those leftovers; a fully filled
-- shared/content.tex produces nothing for it to remove.

local bare_prefixes = { ["github.com/"] = true, ["linkedin.com/in/"] = true }

-- Rebuild a paragraph from its LineBreak-separated lines, keeping only lines with
-- real content.
local function drop_empty_lines(para)
  local kept, line = pandoc.List(), pandoc.List()
  local function flush()
    local text = pandoc.utils.stringify(line):gsub("^%s+", ""):gsub("%s+$", "")
    if text ~= "" and not bare_prefixes[text] then
      if #kept > 0 then kept:insert(pandoc.LineBreak()) end
      kept:extend(line)
    end
    line = pandoc.List()
  end
  for _, inline in ipairs(para.content) do
    if inline.t == "LineBreak" then flush() else line:insert(inline) end
  end
  flush()
  if #kept == 0 then return {} end
  para.content = kept
  return para
end

local function drop_if_empty(block)
  if #block.content == 0 then return {} end
end

-- A heading followed by a heading of the same or a higher level (or by nothing) has
-- an empty section under it. A lower-level heading (a job under Experience) is content.
local function drop_empty_sections(doc)
  local blocks = doc.blocks
  for i = #blocks, 1, -1 do
    local b, nxt = blocks[i], blocks[i + 1]
    if b.t == "Header" and (nxt == nil or (nxt.t == "Header" and nxt.level <= b.level)) then
      blocks:remove(i)
    end
  end
  return doc
end

return {
  { Para = drop_empty_lines, Plain = drop_empty_lines },
  { BulletList = drop_if_empty, Div = drop_if_empty },
  { Pandoc = drop_empty_sections },
}
