local M = {}

M.defaults = {

}

function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})

    vim.api.nvim_create_user_command("TonoFiles",
        function()
            require("tono.generator").generate_from_files(M.options)
        end,
        {}
    )
end

return M
