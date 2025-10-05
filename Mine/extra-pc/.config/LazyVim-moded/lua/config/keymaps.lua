--[[
-- NOTE: remeber this basic keymaps:
all caps bug/fix/fixme, todo, hack  

4x = delete 4 characters (4 can be any number)
4up/down = move 4 lines (4 can be any number)
4left/right = move 4 characters (4 can be any number)
c = cut highlighted text
gd = go to definition
gf = go to file
yap = copy all paragraph
yab = copy inside bracket (can be any bracket)
dap = delete all paragraph
dab = delete inside bracket (can be any bracket)
% = go to matching bracket

quit all is :qa

----------------------------------------------
OPEN KEYMAPS: 
km = open keymaps

my keymaps:
MOVMENT:
ctrl+arrows= move between windows
space+q = close current window
q = close current buffer
hs = split horizontally
vs = split vertically
tt = open terminal
js = jump to start of line
je = jump to end of line
jt = jump to top of function/class
jb = jump to bottom of function/class
nw = go to next word 
pw = go to previous word
tab = go to next buffer
shift+tab = go to previous buffer
space+t = open telescope
space+e = open tree-sitter
fw = find word in files
ft = find TODO in files
dq = exit to dashboard/homescreen
ctrl+u = toggle undotree
ctrl+ep = toggle error panel
cf = nvim config files
space+ft = open floating terminal
space scace = show all files in root directory
n = move to next search result
shift+n = move to previous search result

Resize & move windows(need to figure out how to move windows) :
ctrl+shift+arrows = resize windows
es = make split equal size


Other:
nb = new buffer/window
shift+c = copy highlighted
ctrl+p = Paste
windows+v = clipboard
ctrl+z = undo
ctrl+y = redo
dl = duplicate line
esc = no highlight and normal mode 
ctrl+p = LSP hover / like vscode ctrl+p that shows information
ctrl+h = highlight inside any bracket or pair and go inside
ctrl+d = delete inside any bracket or pair and go inside
ctrl+r = rename word you are in all files with prompt for yes or no (useful for renaming variables)
rw = replace word you are in
shift+up = move current line up
shift+down = move current line down
h = highlight
en = error next
ep = error previous
dc = delete line after cursor


debugger (not working yet):


-----------------------------------------------
for tree sitter:
a = newfile / directory
r = rename file / directory
? = help 

-----------------------------------------------
for undotree:
enter = go to selected change
? = help

--]]
--

-- Basic maps
vim.keymap.set("x", "<S-c>", '"+y', { noremap = true, silent = true, desc = "Copy selected text" })
vim.keymap.set("", "<C-v>", '"+p', { desc = "Paste text" })
vim.keymap.set("", "<C-Left>", "<C-w>h", { desc = "Move left to window/buffer" })
vim.keymap.set("", "<C-Right>", "<C-w>l", { desc = "Move right to window/buffer" })
vim.keymap.set("", "<C-Up>", "<C-w>k", { desc = "Move up to window/buffer" })
vim.keymap.set("", "<C-Down>", "<C-w>j", { desc = "Move down to window/buffer" })
vim.keymap.set("", "<Space>q", "<Cmd>q<CR>", { desc = "Close current window/buffer" })
vim.keymap.set("", "<C-z>", "<Cmd>u<CR>", { desc = "Undo" })
vim.keymap.set("", "<C-y>", "<Cmd>redo<CR>", { desc = "Redo" })

-- delete line after cursor
vim.keymap.set("n", "dc", "d$", { noremap = true, silent = true, desc = "Delete line after cursor" })

-- open new buffer
vim.keymap.set("n", "nb", "<Cmd>enew<CR>", { noremap = true, silent = true, desc = "New buffer" })

-- move between search results
vim.keymap.set("n", "n", "nzzzv", { noremap = true, silent = true, desc = "Move to next search result" })

-- move between search results previous
vim.keymap.set("n", "<S-n>", "Nzzzv", { noremap = true, silent = true, desc = "Move to previous search result" })

-- Duplicate current line
vim.keymap.set("n", "dl", "yyp", { noremap = true, silent = true, desc = "Duplicate current line" })

-- Undotree tougle
vim.keymap.set("n", "<C-u>", "<Cmd>UndotreeToggle<CR>", { noremap = true, silent = true, desc = "Undo tree" })

-- Esq to no selected
vim.keymap.set("n", "<Esc>", "<Cmd>noh<CR>", { noremap = true, silent = true, desc = "No highlight" })

-- Jump to end of the current line (j+e)
vim.keymap.set({ "n", "x" }, "je", "$", { noremap = true, silent = true, desc = "Jump to end of line" })

-- Jump to start of the current line (j+s)
vim.keymap.set({ "n", "x" }, "js", "^", { noremap = true, silent = true, desc = "Jump to start of line" })

-- Jump to top of current function or class (j+t)
vim.keymap.set({ "n", "x" }, "jt", "[[", { noremap = true, silent = true, desc = "Jump to top of function/class" })

-- Jump to bottom of current function or class (j+b)
vim.keymap.set({ "n", "x" }, "jb", "]]", { noremap = true, silent = true, desc = "Jump to bottom of function/class" })
-- LSP Hover keymap
vim.keymap.set(
  { "n", "v", "i", "x" },
  "<C-P>",
  ":lua vim.lsp.buf.hover()<CR>",
  { noremap = true, silent = true, expr = false, desc = "LSP Hover" }
)

-- Remap vi to <C-h> to highlight and go inside
vim.keymap.set({ "n", "x" }, "<C-h>", "vi", { noremap = true, silent = true, desc = "Remap vi to h" })

-- Remap ci to <C-d> to delete and go inside
vim.keymap.set({ "n", "x" }, "<C-d>", "ci", { noremap = true, silent = true, desc = "Remap di to <C-d>" })

-- rename word you are in
vim.keymap.set("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gcI<Left><Left><Left>]])

-- Replace current word
vim.keymap.set("n", "rw", "ciw", { noremap = true, silent = true, desc = "Replace current word" })

-- Go to next word
vim.keymap.set("n", "nw", "w", { noremap = true, silent = true, desc = "Go to next word" })

-- Go to previous word
vim.keymap.set("n", "pw", "b", { noremap = true, silent = true, desc = "Go to previous word" })

-- Resize buffer left
vim.keymap.set(
  "n",
  "<C-S-Left>",
  ":vertical resize -3<CR>",
  { noremap = true, silent = true, desc = "Resize buffer left" }
)

-- Resize buffer right
vim.keymap.set(
  "n",
  "<C-S-Right>",
  ":vertical resize +3<CR>",
  { noremap = true, silent = true, desc = "Resize buffer right" }
)

-- Resize buffer up
vim.keymap.set("n", "<C-S-Up>", ":resize +3<CR>", { noremap = true, silent = true, desc = "Resize buffer up" })

-- Resize buffer down
vim.keymap.set("n", "<C-S-Down>", ":resize -3<CR>", { noremap = true, silent = true, desc = "Resize buffer down" })

-- Split buffer vertically
vim.keymap.set("n", "vs", ":vsplit<CR>", { noremap = true, silent = true, desc = "Split buffer vertically" })

-- Split buffer horizontally
vim.keymap.set("n", "hs", ":split<CR>", { noremap = true, silent = true, desc = "Split buffer horizontally" })

-- Open terminal in current buffer
vim.keymap.set("n", "tt", ":terminal<CR>", { noremap = true, silent = true, desc = "Open terminal in current buffer" })

-- Make Split equal size
vim.keymap.set("n", "es", "<C-w>=", { noremap = true, silent = true, desc = "Make split equal size" })

-- Move current line up/down in normal mode with super key + arrow up/down
vim.keymap.set("n", "<S-Up>", ":<C-u>move .-2<CR>", { noremap = true, silent = true, desc = "Move current line up" })
vim.keymap.set(
  "n",
  "<S-Down>",
  ":<C-u>move .+1<CR>",
  { noremap = true, silent = true, desc = "Move current line down" }
)
vim.keymap.set("x", "<S-Up>", ":move '<-2<CR>gv", { noremap = true, silent = true, desc = "Move highlighted lines up" })
vim.keymap.set(
  "x",
  "<S-Down>",
  ":move '>+1<CR>gv",
  { noremap = true, silent = true, desc = "Move highlighted lines down" }
)

-- Highlight
vim.keymap.set("n", "h", "v", { noremap = true, silent = true, desc = "Enter visual mode" })

-- Move to next buffer
vim.keymap.set("", "<Tab>", ":bnext<CR>", { noremap = true, silent = true, desc = "Move to next buffer" })

-- Move to previous buffer
vim.keymap.set("", "<S-Tab>", ":bprev<CR>", { noremap = true, silent = true, desc = "Move to previous buffer" })

-- Close current buffer
vim.keymap.set("", "q", ":bdelete<CR>", { noremap = true, silent = true, desc = "Close current buffer" })

-- Telscope Find Word in files
vim.keymap.set(
  "n",
  "fw",
  "<Cmd>Telescope grep_string<CR>",
  { noremap = true, silent = true, desc = "Find word in files" }
)

-- Telescope Find TODO in files
vim.keymap.set("n", "ft", "<Cmd>TodoTelescope<CR>", { noremap = true, silent = true, desc = "Find TODO in files" })

-- Exit to dashboard
vim.keymap.set("n", "dq", "<Cmd>Dashboard<CR>", { noremap = true, silent = true, desc = "Exit to dashboard" })

-- Error panel
vim.keymap.set("n", "<C-e>p", "<Cmd>TroubleToggle<CR>", { noremap = true, silent = true, desc = "Error panel" })

-- go to next error

vim.keymap.set("n", "en", function()
  require("trouble").next({ skip_groups = true, jump = true })
end, { desc = "Go to next error" })

-- go to previous error

vim.keymap.set("n", "ep", function()
  require("trouble").previous({ skip_groups = true, jump = true })
end, { desc = "Go to previous error" })

-- Open file ~/.config/nvim/lua/config/keymaps.lua in floating window using oil (show keymaps)
vim.keymap.set(
  "n",
  "km",
  "<Cmd>lua require('oil').open_float('~/.config/nvim/lua/config/keymaps.lua')<CR>",
  { noremap = true, silent = true, desc = "Open keymaps.lua in floating window" }
)
-- Show neovim config files with telescope
vim.keymap.set("n", "cf", function()
  require("telescope.builtin").find_files({
    prompt_title = "Lua Config Files",
    cwd = "~/.config/LazyVim//lua",
  })
end, { noremap = true, silent = true, desc = "Show config files" })

-- debugger dosent work yet

-- Add a breakpoint
--vim.keymap.set("n", "bp", function()
--  require("dap").toggle_breakpoint()
--end, { noremap = true, silent = true, desc = "Set breakpoint" })

-- Open Debugging
--vim.keymap.set("n", "db", function()
--  require("dap").continue()
--end, { noremap = true, silent = true, desc = "Open Debugging" })

-- Debugging next step
--vim.keymap.set("n", "dn", function()
--  require("dap").step_over()
--end, { noremap = true, silent = true, desc = "Debugging next step" })

-- Debugging step into
--vim.keymap.set("n", "di", function()
--  require("dap").step_into()
--end, { noremap = true, silent = true, desc = "Debugging step into" })

-- Debugging step back
--vim.keymap.set("n", "db", function()
--  require("dap").step_out()
--end, { noremap = true, silent = true, desc = "Debugging step back" })
