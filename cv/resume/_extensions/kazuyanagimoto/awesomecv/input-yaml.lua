local function parse_yaml(content)
    local data = {}
    local order = {}  -- Track the order of keys
    local key = nil
    local item = {}
    local in_details = false

    for line in content:gmatch("[^\r\n]+") do
        local line_trimmed = line:gsub("^%s+", ""):gsub("%s+$", "") -- trim whitespace
        local indent_level = #(line:match("^%s*") or "")

        if line_trimmed == "" then
            -- Skip empty lines
        elseif indent_level == 0 and line_trimmed:match("^[%w_-]+:$") then
            if key and next(item) then
                data[key] = item
            end
            key = line_trimmed:gsub(":$", "")
            table.insert(order, key)  -- Track key order
            item = {}
            in_details = false
        elseif indent_level > 0 and line_trimmed:match("^title:%s*(.+)") then
            item.title = line_trimmed:match("^title:%s*(.+)")
        elseif indent_level > 0 and line_trimmed:match("^location:%s*(.+)") then
            item.location = line_trimmed:match("^location:%s*(.+)")
        elseif indent_level > 0 and line_trimmed:match("^date:%s*(.+)") then
            item.date = line_trimmed:match("^date:%s*(.+)")
        elseif indent_level > 0 and line_trimmed:match("^description:%s*(.+)") then
            item.description = line_trimmed:match("^description:%s*(.+)")
        elseif indent_level > 0 and line_trimmed:match("^details:%s*$") then
            item.details = {}
            in_details = true
        elseif in_details and line:match("^%s*-%s*(.+)") then
            local detail = line:match("^%s*-%s*(.+)")
            table.insert(item.details, detail)
        elseif in_details and indent_level > 0 and not line:match("^%s*-%s*") then
            in_details = false
        end
    end

    -- Add the last item
    if key and next(item) then
        data[key] = item
    end

    data._order = order  -- Store the order
    return data
end

local function construct_entry(data, entry_type)
    local typst_code = {}

    -- Convert table to array if it's a dictionary
    local entries = {}
    if data and type(data) == "table" then
        -- Check if we have an order list
        if data._order and type(data._order) == "table" then
            -- Use the stored order from parsing
            for _, k in ipairs(data._order) do
                if data[k] then
                    table.insert(entries, data[k])
                end
            end
        else
            -- Check if it's a dictionary (has string keys)
            local is_dict = false
            for k, v in pairs(data) do
                if type(k) == "string" and k ~= "_order" then
                    is_dict = true
                    break
                end
            end

            if is_dict then
                -- Convert dictionary values to array
                for k, v in pairs(data) do
                    if k ~= "_order" then
                        table.insert(entries, v)
                    end
                end
            else
                entries = data
            end
        end
    end

    -- Determine if this is a publication (only has title field)
    local is_publication = entry_type == "publication"

    for _, item in ipairs(entries) do
        local entry_parts = {}

        if is_publication then
            -- Use publication-entry for publications
            table.insert(entry_parts, "#publication-entry(")
            if item.title then
                -- Convert **text** to #strong[text] for Typst
                local typst_title = tostring(item.title):gsub("%*%*(.-)%*%*", "#strong[%1]")
                table.insert(entry_parts, '  title: [' .. typst_title .. '],')
            else
                table.insert(entry_parts, '  title: none,')
            end
            table.insert(entry_parts, ")")
        else
            -- Use resume-entry for other sections
            table.insert(entry_parts, "#resume-entry(")

            -- Add title
            if item.title then
                table.insert(entry_parts, '  title: [' .. tostring(item.title).. '],')
            else
                table.insert(entry_parts, '  title: none,')
            end

            -- Add location
            if item.location then
                table.insert(entry_parts, '  location: [' .. tostring(item.location).. '],')
            else
                table.insert(entry_parts, '  location: none,')
            end

            -- Add date
            if item.date then
                table.insert(entry_parts, '  date: [' .. tostring(item.date).. '],')
            else
                table.insert(entry_parts, '  date: none,')
            end

            -- Add description
            if item.description then
                table.insert(entry_parts, '  description: [' .. tostring(item.description).. '],')
            else
                table.insert(entry_parts, '  description: none,')
            end

            table.insert(entry_parts, ")")

            -- Add details if present
            if item.details and type(item.details) == "table" then
                table.insert(entry_parts, "#resume-item[")
                if #item.details > 0 then
                    -- Array
                    for _, detail in ipairs(item.details) do
                        table.insert(entry_parts, "  - " .. tostring(detail))
                    end
                else
                    -- Dictionary
                    for _, detail in pairs(item.details) do
                        table.insert(entry_parts, "  - " .. tostring(detail))
                    end
                end
                table.insert(entry_parts, "]")
            end
        end

        table.insert(typst_code, table.concat(entry_parts, "\n"))
    end

    return table.concat(typst_code, "\n\n")
end

function yaml(args)
    local file_path = args[1]
    if not file_path then
        error("yaml shortcode requires a file path argument")
    end

    -- Read YAML file
    local file = io.open(file_path, "r")
    if not file then
        error("Could not open file: " .. file_path)
    end
    local text_yaml = file:read("*all")
    file:close()

    -- Determine entry type from filename
    local entry_type = "normal"
    if file_path:match("publication") then
        entry_type = "publication"
    end

    -- Convert YAML to Typst
    local data = parse_yaml(text_yaml)
    local code_typst = construct_entry(data, entry_type)
    return pandoc.RawInline('typst', code_typst)
end