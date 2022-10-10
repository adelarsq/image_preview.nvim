
local M = {}

-- local function GetFileName(url)
--   return url:match("^.+/(.+)$")
-- end

local function GetFileExtension(url)
  return url:match("^.+(%..+)$")
end

local function IsImage(url)
    local extension = GetFileExtension(url)

    if extension == '.bmp' then
        return true
    elseif extension == '.jpg' or extension == '.jpeg' then
        return true
    elseif extension == '.png' then
        return true
    end

    return false
end


function M.PreviewImage()
    local use, imported = pcall(require, "nvim-tree.lib")
    if use then
        local absolutePath = imported.get_node_at_cursor().absolute_path

        if IsImage(absolutePath) then
            local command = ""

            if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
                command = "silent !wezterm cli split-pane -- powershell wezterm imgcat "
                command = command .. absolutePath
                command = command .. " ; pause"
            else
                command = "silent !wezterm cli split-pane -- bash -c 'wezterm imgcat "
                command = command .. absolutePath
                command = command .. " ; read'"
            end

            vim.api.nvim_command(command)
        else
            print("No preview for file "..absolutePath)
        end
    else
        return ''
    end
end

function M.setup()

    local command = "au Filetype NvimTree nmap <buffer> <silent> <leader>p :lua require('image_preview').PreviewImage()<cr>"
    vim.api.nvim_command(command)

end

return M

