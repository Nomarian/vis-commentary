--
-- vis-commentary
--

local vis = _G.vis
local M = {}

local comments_repl = {
    -- syntax = comment_line  OR   block_comment_start|block_comment_end
    actionscript='//',
    ada='--',
    ansi_c='/*|*/',
    antlr='//',
    apdl='!',
    apl='#',
    applescript='--',
    asp="'",
    autoit=';',
    awk='#',
    b_lang='//',
    bash='#',
    batch=':',
    bibtex='%',
    boo='#',
    chuck='//',
    cmake='#',
    coffeescript='#',
    context='%',
    c='/*|*/',
    cpp='//',
    crystal='#',
    csharp='//',
    css='/*|*/',
    cuda='//',
    dart='//',
    desktop='#',
    django='{#|#}',
    dmd='//',
    dockerfile='#',
    dot='//',
    eiffel='--',
    elixir='#',
    erlang='%',
    faust='//',
    fennel=';;',
    fish='#',
    forth=[[\]],
    fortran='!',
    fsharp='//',
    gap='#',
    gettext='#',
    gherkin='#',
    glsl='//',
    gnuplot='#',
    go='//',
    groovy='//',
    gtkrc='#',
    haskell='--',
    html='<!--|-->',
    icon='#',
    idl='//',
    inform='!',
    ini='#',
    Io='#',
    java='//',
    javascript='//',
    json='/*|*/',
    jsp='//',
    latex='%',
    ledger='#',
    less='//',
    lilypond='%',
    lisp=';',
    logtalk='%',
    lua='--',
    makefile='#',
    markdown='<!--|-->',
    matlab='#',
    moonscript='--',
    myrddin='//',
    nemerle='//',
    nsis='#',
    objective_c='//',
    pascal='//',
    perl='#',
    php='//',
    pico8='//',
    pike='//',
    pkgbuild='#',
    prolog='%',
    props='#',
    protobuf='//',
    ps='%',
    pure='//',
    python='#',
    rails='#',
    rc='#',
    rebol=';',
    -- nroff style format
    rest='.. ', -- technically, ..\n, but that would break everything
    rexx='--',
    rhtml='<!--|-->',
    rstats='#',
    troff=[[.\"]],
    ruby='#',
    rust='//',
    sass='//',
    scala='//',
    scheme=';',
    smalltalk='"|"',
    sml='(*)',
    snobol4='#',
    sql='#',
    tcl='#',
    tex='%',
    text='',
    toml='#',
    vala='//',
    vb="'",
    vbscript="'",
    verilog='//',
    vhdl='--',
    wsf='<!--|-->',
    xml='<!--|-->',
    yaml='#',
    zig='//',
    nim='#',
    julia='#',
    rpmspec='#',
    caml='(*|*)'
}
M.comments_repl = comments_repl

-- escape all magic characters with a '%'
local function esc(str)
    if not str then return "" end
    return (str:gsub('[[.+*?$^()%%%]-]', '%%%0'))
end

local Gsub = string.gsub

local function comment_line(lines, lnum, prefix, suffix)
    if suffix ~= "" then suffix = " " .. suffix end
    local indent, content = lines[lnum]:match("^(%s*)(.*)")
    lines[lnum] = indent .. prefix .. " " .. content .. suffix
end

local function uncomment_line(lines, lnum, prefix, suffix)
    if suffix~="" then suffix = esc(suffix) end
    local patt = "^(%s*)" .. esc(prefix) .. "%s?(.*)" .. suffix .. "$"
    lines[lnum] = Gsub(lines[lnum], patt, "%1%2")
end

local function is_comment(line, prefix)
    local s = line:find'%S'
    return s and (prefix == line:sub(s, s + #prefix - 1)) or false
end

local function toggle_line_comment(lines, lnum, prefix, suffix)
    local line = lines and lines[lnum]
    if not line then return end
    if line:find"^%s*$" then return end -- ignore empty lines
    if is_comment(line, prefix) then
        uncomment_line(lines, lnum, prefix, suffix)
    else
        comment_line(lines, lnum, prefix, suffix)
    end
end

-- if one line inside the block is not a comment, comment the block.
-- only uncomment, if every single line is comment.
local function block_comment(lines, line_start, line_end, prefix, suffix)
    local modify_line = uncomment_line
    for i=line_start,line_end do
        local line = lines[i]
        if line:find"%S" and not is_comment(line, prefix) then
            modify_line = comment_line
            break
        end
    end

    for i=line_start,line_end do
        if lines[i]:find"%S" then
            modify_line(lines, i, prefix, suffix)
        end
    end
    return modify_line == comment_line
end

local function BlocksOperator(file, range, pos)
    local comment = comments_repl[vis.win.syntax]
    if not comment then return pos end
    local prefix, suffix = comment:match('^([^|]+)|?([^|]*)$')
    if not prefix then return pos end

    -- match range position to its line[] position
    -- block_comment only comments lines, not ranges.
    local c = 0 -- cursor position
    local i = 1 -- index/line
    local start, fin = -1, -1 -- line start/end
    for line in file:lines_iterator() do
        local line_start = c
        local line_finish = c + #line + 1
        if line_start < range.finish and line_finish > range.start then
            if start == -1 then
                start = i
            end
            fin = i
        end
        c = line_finish
        if c > range.finish then break end
        i = i + 1
    end
    block_comment(file.lines, start, fin, prefix, suffix)

    return range.start
end

local function CommentCurrentLine()
    local win = vis.win
    local lines = win.file.lines
    local comment = comments_repl[win.syntax]
    if not comment then return end
    local prefix, suffix = comment:match('^([^|]+)|?([^|]*)$')
    if not prefix then return end

    for sel in win:selections_iterator() do
        local lnum = sel.line
        local col = sel.col

        toggle_line_comment(lines, lnum, prefix, suffix)
        sel:to(lnum, col)  -- restore cursor position
    end

    win:draw()
end

function M.MapBlocks(
    key -- string|nil --
)
    vis:operator_new(key or "gc", BlocksOperator
        , "Toggle comment on selected lines")
end

function M.MapLine(
    key -- string|nil --
)
    vis:map(
        vis.modes.NORMAL, key or "gcc"
        , CommentCurrentLine
        , "Toggle comment on a the current line")
end

-- Setup bindings to the default
function M.Setup() M.MapBlocks() M.MapLine() end

return setmetatable(M, {__call = M.Setup})