-- DAP settings
local ok, dap = pcall(require, 'dap')
if not ok then
    return
end

vim.keymap.set("n", "<Leader>bb", dap.toggle_breakpoint)
vim.keymap.set("n", "<Leader>bc", dap.continue)
vim.keymap.set("n", "<Leader>bn", dap.step_over)
vim.keymap.set("n", "<Leader>bi", dap.step_into)
vim.keymap.set("n", "<Leader>bo", dap.step_out)
vim.keymap.set("n", "<Leader>br", dap.repl.open)
vim.keymap.set("n", "<Leader>bl", dap.run_last)
vim.keymap.set("n", "<Leader>bq", dap.terminate)

local ok, dapui = pcall(require, 'dapui')
if ok then
    dapui.setup()

    dap.listeners.before.attach.dapui_config = function()
        dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
        dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
    end

    vim.keymap.set("n", "<Leader>bu", dapui.toggle)
    vim.keymap.set("n", "<Leader>be", dapui.eval)
    vim.keymap.set("n", "<Leader>bf", dapui.float_element)
end

-- Breakpoint sign
vim.fn.sign_define("DapBreakpoint", {
    text = "●",
    texthl = "DapBreakpointSign",
})
