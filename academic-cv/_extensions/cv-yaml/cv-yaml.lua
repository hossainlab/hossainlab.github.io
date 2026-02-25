local function unquote(s)
  if not s then return s end
  return s:gsub('^"(.*)"$', '%1'):gsub("^'(.*)'$", '%1')
end

local function parse_yaml(content)
  local data = {}
  local order = {}
  local key = nil
  local item = {}
  local in_details = false

  for line in content:gmatch("[^\r\n]+") do
    local line_trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
    local indent_level = #(line:match("^%s*") or "")

    if line_trimmed == "" then
      -- skip
    elseif indent_level == 0 and line_trimmed:match("^[%w_-]+:$") then
      if key and next(item) then
        data[key] = item
      end
      key = line_trimmed:gsub(":$", "")
      table.insert(order, key)
      item = {}
      in_details = false
    elseif indent_level > 0 and line_trimmed:match("^title:%s*(.+)") then
      item.title = unquote(line_trimmed:match("^title:%s*(.+)"))
    elseif indent_level > 0 and line_trimmed:match("^location:%s*(.+)") then
      item.location = unquote(line_trimmed:match("^location:%s*(.+)"))
    elseif indent_level > 0 and line_trimmed:match("^date:%s*(.+)") then
      item.date = unquote(line_trimmed:match("^date:%s*(.+)"))
    elseif indent_level > 0 and line_trimmed:match("^description:%s*(.+)") then
      item.description = unquote(line_trimmed:match("^description:%s*(.+)"))
    elseif indent_level > 0 and line_trimmed:match("^details:%s*$") then
      item.details = {}
      in_details = true
    elseif in_details and line:match("^%s*-%s*(.+)") then
      local detail = line:match("^%s*-%s*(.+)")
      detail = unquote(detail)
      table.insert(item.details, detail)
    elseif in_details and indent_level > 0 and not line:match("^%s*-%s*") then
      in_details = false
    end
  end

  if key and next(item) then
    data[key] = item
  end

  data._order = order
  return data
end

local function get_entries(data)
  local entries = {}
  if data._order then
    for _, k in ipairs(data._order) do
      if data[k] then
        table.insert(entries, data[k])
      end
    end
  end
  return entries
end

-- Convert **text** to <strong>text</strong>
local function md_bold(text)
  return text:gsub("%*%*(.-)%*%*", "<strong>%1</strong>")
end

-- Convert [text](url) to <a href="url">text</a>
local function md_links(text)
  return text:gsub("%[(.-)%]%((.-)%)", '<a href="%2">%1</a>')
end

local function process_md(text)
  return md_links(md_bold(text))
end

local function render_entry(entries)
  local blocks = {}
  for _, item in ipairs(entries) do
    local parts = {}
    -- Title line with date
    local title_line = "**" .. (item.title or "") .. "**"
    if item.date then
      title_line = title_line .. " [*" .. item.date .. "*]{.cvdate}"
    end
    if item.description then
      title_line = title_line .. " <br> " .. item.description
    end
    if item.location then
      title_line = title_line .. " [*" .. item.location .. "*]{.cvloc}"
    end
    table.insert(parts, title_line)
    table.insert(parts, "")

    if item.details and #item.details > 0 then
      for _, detail in ipairs(item.details) do
        table.insert(parts, "-   " .. detail)
      end
      table.insert(parts, "")
    end

    table.insert(blocks, table.concat(parts, "\n"))
  end
  return table.concat(blocks, "\n")
end

local function render_skills(entries)
  local rows = {}
  table.insert(rows, "<table>")
  table.insert(rows, '  <colgroup>')
  table.insert(rows, '    <col style="width: 220px; margin: 0; padding: 0;">')
  table.insert(rows, '    <col style="width: auto; margin: 0; padding: 0;">')
  table.insert(rows, '  </colgroup>')
  for _, item in ipairs(entries) do
    table.insert(rows, "  <tr>")
    table.insert(rows, '    <td style="color: black;"><strong>' .. (item.title or "") .. '</strong>&nbsp;&nbsp;&nbsp;&nbsp;</td>')
    table.insert(rows, '    <td>' .. (item.description or "") .. '</td>')
    table.insert(rows, "  </tr>")
  end
  table.insert(rows, "</table>")
  return table.concat(rows, "\n")
end

local function render_simple(entries)
  local items = {}
  for i, item in ipairs(entries) do
    local line = i .. ". **" .. (item.title or "") .. "**."
    if item.description then
      line = line .. " *Institution:* " .. item.description
    end
    table.insert(items, line)
  end
  return table.concat(items, "\n")
end

local function render_talks(entries)
  local items = {}
  for i, item in ipairs(entries) do
    local line = i .. ". **" .. (item.title or "") .. "**"
    if item.date then
      line = line .. " (" .. item.date .. ")."
    end
    if item.description then
      line = line .. " " .. item.description .. "."
    end
    table.insert(items, line)
  end
  return table.concat(items, "\n")
end

local function render_mentoring(entries)
  local blocks = {}
  for _, item in ipairs(entries) do
    local parts = {}
    local title_line = "**" .. (item.title or "") .. "**"
    if item.date then
      title_line = title_line .. " (" .. item.date .. ")"
    end
    table.insert(parts, title_line)
    table.insert(parts, "")
    if item.details and #item.details > 0 then
      for _, detail in ipairs(item.details) do
        table.insert(parts, "- " .. detail)
      end
    end
    table.insert(blocks, table.concat(parts, "\n"))
  end
  return table.concat(blocks, "\n\n")
end

local function render_media(entries)
  local items = {}
  for i, item in ipairs(entries) do
    local title = item.title or ""
    -- title already contains markdown link syntax
    local line = i .. ". **" .. title .. "**."
    if item.description then
      line = line .. " " .. item.description .. "."
    end
    table.insert(items, line)
  end
  return table.concat(items, "\n")
end

-- Shortcode handler
function cv_yaml(args, kwargs)
  local file_path = args[1]
  if not file_path then
    error("cv-yaml shortcode requires a file path argument")
  end

  local render_type = "entry"
  if kwargs and kwargs["type"] then
    render_type = pandoc.utils.stringify(kwargs["type"])
  end

  local file = io.open(file_path, "r")
  if not file then
    error("Could not open file: " .. file_path)
  end
  local content = file:read("*all")
  file:close()

  local data = parse_yaml(content)
  local entries = get_entries(data)

  local result
  if render_type == "skills" then
    result = render_skills(entries)
  elseif render_type == "simple" then
    result = render_simple(entries)
  elseif render_type == "talks" then
    result = render_talks(entries)
  elseif render_type == "mentoring" then
    result = render_mentoring(entries)
  elseif render_type == "media" then
    result = render_media(entries)
  else
    result = render_entry(entries)
  end

  return pandoc.read(result, "markdown").blocks
end

return {
  ["cv-yaml"] = cv_yaml
}
