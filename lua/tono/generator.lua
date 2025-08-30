local M = {}

local function call_command(json, template, package_name, out_dir)
    -- Create a temp file to ensures the data is always a file since the
    -- script accepts a file instead of plain text
    -- local tmpfile = vim.fn.tempname()
    -- local f = io.open(tmpfile, 'w')
    -- if f == nil then return end

    -- f:write(json)
    -- f:close()

    local plugin_dir = debug.getinfo(1).source
    plugin_dir = string.sub(plugin_dir, 1)
    plugin_dir = string.match(plugin_dir, "@(.+)/%a+.%a+")

    local cmd = {
        plugin_dir .. '/venv/bin/python',
        plugin_dir .. '/' .. 'tono.py',
        vim.fn.fnameescape(json),
        vim.fn.fnameescape(package_name),
        "--template=" .. vim.fn.fnameescape(template),
        "--saveTo=" .. vim.fn.fnameescape(out_dir),
    }

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        stderr_buffered = true,

        on_stdout = function(_, data)
            for _, line in ipairs(data) do
                if line ~= "" then print("OUT: " .. line) end
            end
        end,

        on_stderr = function(_, data)
            for _, line in ipairs(data) do
                if line ~= "" then print("ERR: " .. line) end
            end
        end,
    })
end

local function input_package_name(json, template, out_dir)
    vim.ui.input({ prompt = "Input your package name: " }, function(input)
        if input == nil then return end

        call_command(json, template, input, out_dir)
    end)
end

local function select_destination_dir(json, template)
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local config_values = require("telescope.config").values

    pickers.new({}, {
        prompt_title = "Select Destination Directory",
        finder = finders.new_oneshot_job({ "find", ".", "-type", "d" }, {}),
        sorter = config_values.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)

                local selection = action_state.get_selected_entry()[1]
                if not selection then return end

                input_package_name(json, template, selection)
            end)

            return true
        end,
    }):find()
end

local function select_template(json)
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local config_values = require("telescope.config").values

    local template_dir = debug.getinfo(1).source
    template_dir = string.sub(template_dir, 1)
    template_dir = string.match(template_dir, "@(.+)/%a+.%a+")
    template_dir = template_dir .. '/templates'

    pickers.new({}, {
        prompt_title = "Select Template to Use",
        finder = finders.new_oneshot_job(
            { "sh", "-c", string.format("find %s -type f -name '*.j2' | awk -F/ '{print $NF}'", template_dir) }, {}),
        sorter = config_values.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()[1]
                if not selection then return end
                actions.close(prompt_bufnr)

                select_destination_dir(json, selection)
            end)

            return true
        end,
    }):find()
end

--@diagnostic disable-next-line
local function select_json_file()
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local config_values = require("telescope.config").values

    pickers.new({}, {
        prompt_title = "Select JSON to Convert",
        finder = finders.new_oneshot_job({ "find", ".", "-type", "f", "-name", "*.json" }, {}),
        sorter = config_values.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)

                local selection = action_state.get_selected_entry()[1]
                if not selection then return end

                select_template(selection)

                -- local file = io.open(selection, 'r')
                -- if not file then
                --     return true
                -- end

                -- local content = file:read("*a")
                -- file:close()
            end)

            return true
        end,
    }):find()
end

local function select_current_buffer()
    local path = vim.api.nvim.buf.get_name(0)
    local file = io.open(path, "r")
    if not file then
        return
    end
    local content = file:read("*a")
    file:close()

    select_destination_dir(content)
end

function M.generate_from_files()
    select_json_file()
end

function M.generate_from_buffer()
    select_current_buffer()
end

function M.generate_from_selected()
end

return M
