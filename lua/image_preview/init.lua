local M = {}

M.config = {
		mappings = {
				PreviewImage = {
						{"n"},
						"<leader>p"
				}
		},
		Options = {
				useFeh = false
		}
}
-- local function GetFileName(url)
--   return url:match("^.+/(.+)$")
-- end

local function GetFileExtension(url)
    return url:match("^.+(%..+)$")
end

local function GetTerm()
    if os.getenv('KITTY_PID') ~= nil then
        return 'kitty'
    elseif os.getenv('WEZTERM_PANE') ~= nil then
        return 'wezterm'
		end
		return nil
end

function M.IsImage(url)
    local extension = GetFileExtension(url)

    if extension == '.bmp' then
        return true
    elseif extension == '.jpg' or extension == '.jpeg' then
        return true
    elseif extension == '.png' then
        return true
    elseif extension == '.gif' then
        return true
    end

    return false
end

function M.PreviewImage(absolutePath)
    local term = GetTerm()

    if M.IsImage(absolutePath) then
        local command = ""

        if term == 'wezterm' then
            if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
                command = "silent !wezterm cli split-pane -- powershell wezterm imgcat "
                    .. "'" .. absolutePath .. "'"
                    .. " ; pause"
            else
                command = "silent !wezterm cli split-pane -- bash -c 'wezterm imgcat \"" .. absolutePath .. "\" ; read'"
            end
        elseif term == 'kitty' then
            if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
                print('Kitty not supported on windows')
            else
                command = 'silent !kitten @ launch --type=window kitten icat --hold "' .. absolutePath .. '"'
            end
        elseif M.config.Options.useFeh then
						-- fallback of feh for non-supported terminals @ Neo Sahadeo
						command = 'silent !feh '.. absolutePath
				else
            print('No support for this terminal.')
        end

        vim.api.nvim_command(command)
    else
        print("No preview for file " .. absolutePath)
    end
end

function M.PreviewImageNvimTree()
    local use, imported = pcall(require, "nvim-tree.lib")
    if use then
        local absolutePath = imported.get_node_at_cursor().absolute_path
        M.PreviewImage(absolutePath)
				return 0
		end
		return 1
end

function M.PreviewImageOil()
    local use, imported = pcall(require, "oil")
    if use then
        local entry = imported.get_cursor_entry()

        if (entry['type'] == 'file') then
            local dir = imported.get_current_dir()
            local fileName = entry['name']
            local fullName = dir .. fileName

            M.PreviewImage(fullName)
						return 0
        end
		end
		return 1
end

function M.setup(user_config)
		-- Added support for custom keybinds @ Neo Sahadeo
		-- Currently there is only 1 keybinds so this works
		-- for now
		local preview_keybind = nil
		M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
		for action, mapping in pairs(M.config.mappings) do
				if action == "PreviewImage" then
						preview_keybind = {
							modes = mapping[1],
							keybind = mapping[2]
						}
				end
		end

		-- Added abstraction to autocommands @ Neo Sahadeo
		local file_explorer_plugins = {
				-- {
				-- 		name = "neo-tree",
				-- 		function_name = "PreviewImage",
				-- 		pattern = "NeoTree"
				-- },
				{
						name = "nvim-tree",
						function_name = "PreviewImageNvimTree",
						pattern = "NvimTree"
				},
				{
						name = "oil",
						function_name = "PreviewImageOil",
						pattern = "oil"
				},
		}
		local functionToRun = nil
		local pattern = nil

		for _, plugin in ipairs(file_explorer_plugins) do
				local hasPlugin, _ = pcall(require, plugin.name)
				if hasPlugin then
						functionToRun = plugin.function_name
						pattern = plugin.pattern
						break
				end
		end

		-- Explicit nil check
		if functionToRun == nil or pattern == nil or preview_keybind == nil then
				print("An internal error occured")
				return 1
		end

		vim.api.nvim_create_autocmd("FileType", {
				pattern = pattern,
				callback = function()
						vim.keymap.set(preview_keybind.modes,
						preview_keybind.keybind,
						function ()
							local image_preview = require('image_preview')
							return image_preview[functionToRun]()
						end,
						{ noremap = true, silent = true })
				end,
		})
end

return M
