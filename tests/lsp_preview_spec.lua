---@module 'luassert'

local ui = require('render-markdown.core.ui')

describe('LSP preview', function()
    before_each(function()
        require('render-markdown').setup({ anti_conceal = { enabled = false } })
    end)

    local function render_table(max_height)
        local lines = {
            '# Table schema',
            '',
            '| C1 | C2 | C3 | C4 | C5 | C6 | C7 | C8 |',
            '| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |',
        }
        for row = 1, 14 do
            local values = {}
            for column = 1, 8 do
                values[column] = column == (row - 1) % 8 + 1
                        and ('long-field-name-%02d'):format(row)
                    or 'x'
            end
            lines[#lines + 1] = '| ' .. table.concat(values, ' | ') .. ' |'
        end

        local buf, win = vim.lsp.util.open_floating_preview(lines, 'markdown', {
            border = 'none',
            max_width = 70,
            max_height = max_height,
            focus = false,
        })
        local initial = vim.api.nvim_win_get_height(win)
        ui.update(buf, win, 'test', true)
        assert.is_true(vim.wait(1000, function()
            return ui.get(buf).n > 0
        end))
        local done = false
        vim.schedule(function()
            done = true
        end)
        assert.is_true(vim.wait(1000, function()
            return done
        end))
        local rendered = vim.api.nvim_win_text_height(win, {}).all
        local height = vim.api.nvim_win_get_height(win)
        vim.api.nvim_win_close(win, true)
        assert.is_true(rendered > initial)
        return initial, height
    end

    it('keeps room for wrapped table rows', function()
        local initial, height = render_table()
        assert.is_true(height >= initial)
    end)

    it('preserves a configured height limit', function()
        local initial, height = render_table(10)
        assert.same(10, initial)
        assert.same(initial, height)
    end)
end)
