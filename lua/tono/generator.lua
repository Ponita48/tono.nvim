local M = {}

local function call_command(json, template, out_dir)
    local command = "python3 json, template, out_dir"
end

local function input_package_name(json, template, out_dir)
    vim.ui.input({ prompt = "Input your package name: " }, function()
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
    template_dir = template_dir .. 'templates'

    pickers.new({}, {
        prompt_title = "Select Template to Use",
        finder = finders.new_oneshot_job({ "find", template_dir, "-type", "f", "-name", "*.j2"}, {}),
        -- finder = finders.new_table({template_dir}),
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


                local file = io.open(selection, 'r')
                if not file then
                    return true
                end

                local content = file:read("*a")
                file:close()

                select_destination_dir(content)
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
    select_template('asd')
end

function M.generate_from_buffer()
    select_current_buffer()
end

function M.generate_from_selected()
end

return M
