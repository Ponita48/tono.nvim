local M = {}

function M.setup()
    -- user command
    vim.api.nvim_create_user_command("TonoFiles",
        function()
            require("tono.generator").generate_from_files()
            print(debug.getinfo(1).source)
        end,
        {}
    )
end

return M
