-- keymaps.lua

local map = vim.keymap.set

--- Move current line up / down -----------------------------------------------
map("n", "<leader>k", ":m .-2<CR>==",      { desc = "Move line up" })
map("n", "<leader>j", ":m .+1<CR>==",      { desc = "Move line down" })

--- Duplicate line up / down --------------------------------------------------
map("n", "<leader>l", ":t.<CR>",           { desc = "Duplicate line down" })
map("n", "<leader>h", ":t-1<CR>",          { desc = "Duplicate line up" })

--- Duplicate selection up / down --------------------------------------------
map("v", "<leader>l", ":t'><CR>",          { desc = "Duplicate selection down" })
map("v", "<leader>h", ":t'<-1<CR>",        { desc = "Duplicate selection up" })

--- Go to end of file ---------------------------------------------------------
map("n", "ff", "G$",                       { desc = "Go to EOF" })

--- Search --------------------------------------------------------------------
map("n", "<leader>f", "/",                 { desc = "Search in file" })

--- Grep prompt (replaces GrepPrompt() function)
map("n", "<leader>F", function()
  local pattern = vim.fn.input("Search pattern: ")
  if pattern ~= "" then
    vim.cmd("vimgrep /" .. pattern .. "/gj **/*")
    vim.cmd("copen")
  end
end, { desc = "Grep in project" })

--- Quickfix list keybinds
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    map("n", "<Esc>", ":cclose<CR>", { buffer = true })
    map("n", "l",     "<CR><C-w>p",  { buffer = true })
  end,
})

--- Select all ----------------------------------------------------------------
map("n", "<leader>a", "ggVG",              { desc = "Select all" })

--- Copy to system clipboard --------------------------------------------------
map("v", "<leader>y", '"+y',               { desc = "Yank to clipboard" })

--- Indent / un-indent --------------------------------------------------------
map("n", "<Tab>",          ">>",           { desc = "Indent line" })
map("v", "<Tab>",          ">gv",          { desc = "Indent selection" })
map("i", "<leader><Tab>",  "<C-d>",        { desc = "Un-indent (insert)" })
map("n", "<leader><Tab>",  "<<",           { desc = "Un-indent line" })
map("v", "<leader><Tab>",  "<gv",          { desc = "Un-indent selection" })

--- Window focus --------------------------------------------------------------
map("n", "<leader>w", "<C-w>w",            { desc = "Next window" })
map("v", "<leader>w", "<C-w>w",            { desc = "Next window" })
map("t", "<leader>w", "<C-\\><C-n><C-w>w", { desc = "Next window (terminal)" })

--- Terminal ------------------------------------------------------------------
map("n", "<leader>t", ":term<CR>",         { desc = "Open terminal" })

--- Save ----------------------------------------------------------------------
map("n", "<C-s>", ":w<CR>",               { desc = "Save file" })
map("i", "<C-s>", "<Esc>:w<CR>a",         { desc = "Save file (insert)" })

--- Auto-surround (visual mode) -----------------------------------------------
-- nvim-autopairs handles the insert-mode pairs; these cover visual surround
map("x", "(", "c(<Esc>pa)<Esc>",          { desc = "Surround with ()" })
map("x", "[", "c[<Esc>pa]<Esc>",          { desc = "Surround with []" })
map("x", "{", "c{<Esc>pa}<Esc>",          { desc = "Surround with {}" })
map("x", '"', 'c"<Esc>pa"<Esc>',          { desc = 'Surround with ""' })
map("x", "'", "c'<Esc>pa'<Esc>",          { desc = "Surround with ''" })

--- Comment (Comment.nvim) ----------------------------------------------------
-- Bound in plugins/comment.lua after the plugin loads
