local M = {}

local function parse_commit(line)
  local hash = line:match("^([^|]+)")
  return hash and hash:gsub("%s+", "") or nil
end

local function get_relative_path(file)
  local handle = io.popen("git ls-files --prefix='' --others --exclude-standard " .. vim.fn.shellescape(file) .. " 2>/dev/null; git rev-parse --show-toplevel 2>/dev/null")
  if not handle then
    return file
  end
  local result = handle:read("*a")
  handle:close()

  local lines = {}
  for line in result:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end

  if #lines >= 2 then
    local git_root = lines[#lines]
    local relative = file:gsub("^" .. vim.pesc(git_root) .. "/?", "")
    return relative
  end
  return file
end

local function git_diff_commits(opts)
  opts = opts or {}
  local fzf = require("fzf-lua")

  local format = "'%h | %an | %ad | %s'"
  local date_format = "--date=format:'%b %d, %Y'"

  local function build_cmd(file_only)
    local file_arg = ""
    if opts.file then
      file_arg = " --follow -- " .. opts.file
    end
    return "git log " .. date_format .. " --format=" .. format .. file_arg
  end

  local function pick_second_commit(commit1)
    fzf.fzf_exec(build_cmd(), {
      prompt = "Select second commit> ",
      actions = {
        ["enter"] = function(selected)
          local commit2 = parse_commit(selected[1])
          if commit1 and commit2 then
            require("diffview")
            if opts.file then
              local relative_file = get_relative_path(opts.file)
              vim.cmd("DiffviewOpen " .. commit1 .. ".." .. commit2 .. " -- " .. relative_file)
            else
              vim.cmd("DiffviewOpen " .. commit1 .. ".." .. commit2)
            end
          end
        end,
      },
    })
  end

  local function pick_first_commit()
    fzf.fzf_exec(build_cmd(), {
      prompt = "Select first commit> ",
      actions = {
        ["enter"] = function(selected)
          local commit1 = parse_commit(selected[1])
          if commit1 then
            pick_second_commit(commit1)
          end
        end,
      },
    })
  end

  pick_first_commit()
end

function M.git_diff_file_commits()
  local file = vim.fn.expand("%:p")
  if file == "" or file == "nil" then
    vim.notify("No file selected", vim.log.levels.WARN)
    return
  end
  git_diff_commits({ file = file })
end

function M.git_diff_all_commits()
  git_diff_commits({})
end

function M.git_diff_head()
  require("diffview")
  vim.cmd("DiffviewOpen HEAD")
end

return M
