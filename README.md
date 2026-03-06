## vis-commentary

`vis-commentary` aims to port Tim Pope's [vim-commentary](https://github.com/tpope/vim-commentary) to [vis](https://github.com/martanne/vis).

### Installation
Clone the repo to your vis plugins directory (`~/.config/vis/plugins`) and add this to your `visrc.lua`:
```
require("plugins/vis-commentary")()
```

### Usage

| Keybind | Description |
|---------|-------------|
| `gcc`   | Toggle comment of the current line in NORMAL mode.|
| `gc`    | Toggle comment on the target of a motion (for example: `gj` to comment this and next line) |

### Configuration

If you do not wish the default keybinds, you may change the bindings via using the functions

MapBlocks(key)
MapLine(key)

### API

comments_repl: table -> {lexer: string} -- lexer -> "line" or "prefix|suffix"
function MapBlocks(key: string|nil) -- Maps "gc"|<key> to comment selected block
function MapLine(key: string|nil) -- Maps "gcc"|<key> to comment the current line
function SetDefaults() -- Sets default keybindings

### Bugs

* positioning changes upon use
* block comments are not supported
* rst is not wholly correct. multiline comments are not well supported.

### Notes

Should you find bugs or unsupported languages, please report them.
