-- require("starship"):setup()
require("full-border"):setup()
-- lsd
require("lsd-preview"):setup()
-- open multiple files with smart enter
require("smart-enter"):setup({
	open_multi = true,
})

-- custom shell history
require("custom-shell"):setup({
	history_path = "default",
	save_history = true,
})

require("restore"):setup({
	-- Set the position for confirm and overwrite dialogs.
	-- don't forget to set height: `h = xx`
	-- https://yazi-rs.github.io/docs/plugins/utils/#ya.input
	position = { "center", w = 70, h = 40 },

	-- Show confirm dialog before restore.
	-- NOTE: even if set this to false, overwrite dialog still pop up
	show_confirm = true,

	-- colors for confirm and overwrite dialogs
	theme = {
		title = "blue",
		header = "green",
		-- header color for overwrite dialog
		header_warning = "yellow",
		list_item = { odd = "blue", even = "blue" },
	},
})

require("copy-file-contents"):setup({
	append_char = "\n",
	notification = true,
})

-- require("fg"):setup({
-- 	default_action = "menu", -- nvim, jump
-- })

-- my linemode
function Linemode:size_mtime_btime()
	-- Get and format file size
	local size_val = self._file:size()
	local size = size_val and ya.readable_size(size_val) or "-"

	-- Format modification time (mtime)
	local mtime_val = math.floor(self._file.cha.mtime or 0)
	local mtime
	if mtime_val == 0 then
		mtime = ""
	elseif os.date("%Y", mtime_val) == os.date("%Y") then
		mtime = os.date("%b %d %H:%M", mtime_val)
	else
		mtime = os.date("%b %d  %Y", mtime_val)
	end

	-- Format birth time (btime)
	local btime_val = math.floor(self._file.cha.btime or 0)
	local btime
	if btime_val == 0 then
		btime = ""
	elseif os.date("%Y", btime_val) == os.date("%Y") then
		btime = os.date("%b %d %H:%M", btime_val)
	else
		btime = os.date("%b %d  %Y", btime_val)
	end

	-- Return a combined string with size, mtime, and btime
	return string.format("%s  Mod:%s  Made:%s", size, mtime, btime)
end

-- show link targets in status line
function Status:name()
	local h = self._current.hovered
	if not h then
		return ""
	end

	local linked = ""
	if h.link_to ~= nil then
		linked = " -> " .. tostring(h.link_to)
	end

	return " " .. h.name:gsub("\r", "?", 1) .. linked
end

-- lua lines
local catppuccin_theme = require("yatline-catppuccin"):setup("mocha") -- or "latte" | "frappe" | "macchiato"
-- local dracula_theme = require("yatline-dracula"):setup()
require("yatline"):setup({

	theme = catppuccin_theme,
	show_background = false,
	section_separator = { open = "", close = "" },
	part_separator = { open = "", close = "" },
	inverse_separator = { open = "", close = "" },
	header_line = {
		left = {
			section_a = {
				{ type = "coloreds", custom = true, name = { { " 󰇥 ", "#FFFF00" } } },
			},
			section_b = {
				{ type = "string", custom = false, name = "tab_path" },
			},
			section_c = {
				{ type = "string", custom = false, name = "tab_num_files" },
				{ type = "string", custom = false, name = "hovered_file_extension" },
				{ type = "coloreds", custom = false, name = "githead" },
			},
		},
		right = {
			section_a = {
				{ type = "line", custom = false, name = "tabs", params = { "right" } },
			},
			section_b = {},
			section_c = {},
		},
	},
	status_line = {
		left = {
			section_a = {
				{ type = "string", custom = false, name = "tab_mode" },
			},
			section_b = {
				{
					type = "string",
					custom = false,
					name = "hovered_name",
					params = { { trimed = false, show_symlink = true, max_length = 24, trim_length = 10 } },
				},
				{ type = "coloreds", custom = false, name = "created-time" },
			},
			section_c = {
				{ type = "string", custom = false, name = "hovered_size" },
				{ type = "coloreds", custom = false, name = "count" },
			},
		},
		right = {
			section_a = {
				{ type = "string", custom = false, name = "date", params = { "%R  / %A, %d %B %Y  " } },
			},
			section_b = {
				{ type = "string", custom = false, name = "cursor_position" },
				{ type = "string", custom = false, name = "cursor_percentage" },
			},
			section_c = {
				{ type = "coloreds", custom = false, name = "permissions" },
			},
		},
	},
	-- even more here
	-- https://github.com/imsi32/yatline.yazi/wiki/Components
})
require("yatline-created-time"):setup()
require("yatline-symlink"):setup()
-- require("githead"):setup({
--   symlink_color = "white"
-- }
require("yatline-githead"):setup({
	show_branch = true,
	branch_prefix = "on",
	branch_symbol = "󰘬",
	branch_borders = "()",

	commit_symbol = " ",

	show_behind_ahead = true,
	behind_symbol = " ",
	ahead_symbol = " ",

	show_stashes = true,
	stashes_symbol = " ",

	show_state = true,
	show_state_prefix = true,
	state_symbol = "󰀨 ",

	show_staged = true,
	staged_symbol = "󰏕 ",

	show_unstaged = true,
	unstaged_symbol = " ",

	show_untracked = true,
	untracked_symbol = "󰈉 ",
})

-- or for thene
-- -- git signs
-- -- ~/.config/yazi/init.lua
-- THEME.git = THEME.git or {}
-- THEME.git.untracked_sign = "󰈉 "
-- THEME.git.ignored_sign = " "
-- THEME.git.updated_sign = "󰚰 "
-- THEME.git.added_sign = " "
-- THEME.git.modified_sign = " "
-- THEME.git.deleted_sign = " "

-- require("git"):setup()

-- show user/group in status line

Status:children_add(function()
	local h = cx.active.current.hovered
	if h == nil or ya.target_family() ~= "unix" then
		return ""
	end

	return ui.Line({
		--TODO: change the color
		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
		":",
		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
		" ",
	})
end, 500, Status.RIGHT)
--[[
--[[manager.prepend_keymap]]
--on   = "p"
--run  = "plugin smart-paste"
--desc = "Paste into the hovered directory or CWD"
--
--[[manager.prepend_keymap]]
--on   = "t"
--run  = "plugin smart-tab"
--desc = "Create a tab and enter the hovered directory"
--
--[[manager.prepend_keymap]]
--on  = "y"
--run = [ 'shell -- for path in "$@"; do echo "file://$path"; done | wl-copy -t text/uri-list', "yank" ]
--]]
