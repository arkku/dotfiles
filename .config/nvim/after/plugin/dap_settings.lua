-- DAP settings
local ok, dap = pcall(require, 'dap')
if not ok then
    return
end

vim.keymap.set('n', '<Leader>C', dap.continue)
vim.keymap.set('n', '<Leader>bc', dap.continue)
vim.keymap.set('n', '<Leader>bb', dap.toggle_breakpoint)
vim.keymap.set('n', '<Leader>B', dap.toggle_breakpoint)
vim.keymap.set('n', '<Leader>bn', dap.step_over)
vim.keymap.set('n', '<Leader>bi', dap.step_into)
vim.keymap.set('n', '<Leader>bo', dap.step_out)
vim.keymap.set('n', '<Leader>br', dap.repl.open)
vim.keymap.set('n', '<Leader>bl', dap.run_last)
vim.keymap.set('n', '<Leader>bq', dap.terminate)
vim.keymap.set('n', '<Leader>bs', function() dap.set_breakpoint(vim.fn.input('Condition: ')) end)
vim.keymap.set('n', '<Leader>bS', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log message: ')) end)
vim.keymap.set('n', '<Leader>bh', function() dap.set_breakpoint(nil, vim.fn.input('Hit count: ')) end)
vim.keymap.set('n', '<Leader>bx', function() dap.set_exception_breakpoints({ 'all' }) end)

local ok, dapui = pcall(require, 'dapui')
if ok then
    dapui.setup()

    dap.listeners.before.attach.dapui_config = function()
        dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
        dapui.open()
    end

    -- These would close the UI on termination/exit, but in practice that is
    -- often not wanted since the console with any residual output disappears.

    -- dap.listeners.before.event_terminated.dapui_config = function()
    --     dapui.close()
    -- end
    -- dap.listeners.before.event_exited.dapui_config = function()
    --     dapui.close()
    -- end

    vim.keymap.set('n', '<Leader>bu', dapui.toggle)
    vim.keymap.set('n', '<Leader>bU', dapui.float_element)
    vim.keymap.set('n', '<Leader>be', dapui.eval)
end

-- Breakpoint sign
vim.fn.sign_define('DapBreakpoint', {
    text = '●',
    texthl = 'DapBreakpointSign',
})

-- Adapters

local function executable(cmd)
    return vim.fn.executable(cmd) == 1
end

local ok, pydap = pcall(require, "dap-python")
if ok then
    if executable('debugpy-adapter') then
        pydap.setup('debugpy-adapter')
    elseif executable('python3') then
        pydap.setup('python3')
    elseif executable('python') then
        pydap.setup('python')
    elseif executable('uv') then
        pydap.setup('uv')
    end
end
