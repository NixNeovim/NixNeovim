from tree_sitter import Language, Parser

Language.build_library(
  # Store the library in the `build` directory
  'build/my-languages.so',

  # Include one or more languages
  [
    './tree-sitter-lua',
  ]
)

indent = ""

def print_comment(text):
    print(indent, "# ", text)
    

def extract(node):
    linenumber = node.start_point[0]
    start = node.start_point[1]
    end = node.end_point[1]
    return lines[linenumber][start:end]

def parse_field(node):
    name = node.child_by_field_name("name") # name node
    value = node.child_by_field_name("value") # value node

    if name is None:
        #  print("Field has no name. Assuming it's a list")
        print(indent, extract(value), ";") # TODO: print as list
        return

    if value is None:
        print(f"Field {name} has no value")
        exit()

    match value.type:
        case "boolean":
            typeString = "boolOption"
            print(indent, extract(name), "=", typeString, extract(value), "\"\";")
        case "string":
            typeString = "strOption"
            print(indent, extract(name), "=", typeString, extract(value), "\"\";")
        case "tableconstructor":
            print(indent, extract(name), "=", end="")
            parse_table(value.children)
        case "number":
            print(indent, extract(name), "=", "intOption", extract(value), "\"\";")
        case "function":
            print(indent, "'lua function'")
        case "nil":
            print(indent, "'nil'")

        case type:
            print(f"UNKNOWN ({type})")


def parse_table(children):
    global indent

    for child in children:
        match child.type:
            case "{":
                print("", "{")
                indent += "  "
            case "}":
                indent = indent[:-2]
                print(indent, "}")
            case "comment":
                text = extract(child)
                print_comment(text)
            case "fieldlist":
                for node in child.children:
                    match node.type:
                        case ",":
                            continue
                        case "comment":
                            text = extract(node)
                            print_comment(text)
                        case "field":
                            parse_field(node)

LUA_LANGUAGE = Language('build/my-languages.so', 'lua')

parser = Parser()

parser.set_language(LUA_LANGUAGE)

data = '''
require("oil").setup({
  -- Id is automatically added at the beginning, and name at the end
  -- See :help oil-columns
  columns = {
    "icon",
    -- "permissions",
    -- "size",
    -- "mtime",
  },
  -- Buffer-local options to use for oil buffers
  buf_options = {
    buflisted = false,
  },
  -- Window-local options to use for oil buffers
  win_options = {
    wrap = false,
    signcolumn = "no",
    cursorcolumn = false,
    foldcolumn = "0",
    spell = false,
    list = false,
    conceallevel = 3,
    concealcursor = "n",
  },
  -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`
  default_file_explorer = true,
  -- Restore window options to previous values when leaving an oil buffer
  restore_win_options = true,
  -- Skip the confirmation popup for simple operations
  skip_confirm_for_simple_edits = false,
  -- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap
  -- options with a `callback` (e.g. { callback = function() ... end, desc = "", nowait = true })
  -- Additionally, if it is a string that matches "actions.<name>",
  -- it will use the mapping at require("oil.actions").<name>
  -- Set to `false` to remove a keymap
  -- See :help oil-actions for a list of all available actions
  keymaps = {
    ["g?"] = "actions.show_help",
    ["<CR>"] = "actions.select",
    ["<C-s>"] = "actions.select_vsplit",
    ["<C-h>"] = "actions.select_split",
    ["<C-t>"] = "actions.select_tab",
    ["<C-p>"] = "actions.preview",
    ["<C-c>"] = "actions.close",
    ["<C-l>"] = "actions.refresh",
    ["-"] = "actions.parent",
    ["_"] = "actions.open_cwd",
    ["`"] = "actions.cd",
    ["~"] = "actions.tcd",
    ["g."] = "actions.toggle_hidden",
  },
  -- Set to false to disable all of the above keymaps
  use_default_keymaps = true,
  view_options = {
    -- Show files and directories that start with "."
    show_hidden = false,
    -- This function defines what is considered a "hidden" file
    is_hidden_file = function(name, bufnr)
      return vim.startswith(name, ".")
    end,
    -- This function defines what will never be shown, even when `show_hidden` is set
    is_always_hidden = function(name, bufnr)
      return false
    end,
  },
  -- Configuration for the floating window in oil.open_float
  float = {
    -- Padding around the floating window
    padding = 2,
    max_width = 0,
    max_height = 0,
    border = "rounded",
    win_options = {
      winblend = 10,
    },
  },
  -- Configuration for the actions floating preview window
  preview = {
    -- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    -- min_width and max_width can be a single value or a list of mixed integer/float types.
    -- max_width = {100, 0.8} means "the lesser of 100 columns or 80% of total"
    max_width = 0.9,
    -- min_width = {40, 0.4} means "the greater of 40 columns or 40% of total"
    min_width = { 40, 0.4 },
    -- optionally define an integer/float for the exact width of the preview window
    width = nil,
    -- Height dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    -- min_height and max_height can be a single value or a list of mixed integer/float types.
    -- max_height = {80, 0.9} means "the lesser of 80 columns or 90% of total"
    max_height = 0.9,
    -- min_height = {5, 0.1} means "the greater of 5 columns or 10% of total"
    min_height = { 5, 0.1 },
    -- optionally define an integer/float for the exact height of the preview window
    height = nil,
    border = "rounded",
    win_options = {
      winblend = 0,
    },
  },
  -- Configuration for the floating progress window
  progress = {
    max_width = 0.9,
    min_width = { 40, 0.4 },
    width = nil,
    max_height = { 10, 0.9 },
    min_height = { 5, 0.1 },
    height = nil,
    border = "rounded",
    minimized_border = "none",
    win_options = {
      winblend = 0,
    },
  },
})
'''

#  data = '''
#  require("hi").setup({
#      a = true,
#      b = "striiiing",
#      -- Id is automatically added at the beginning, and name at the end
#      -- See :help oil-columns
#      columns = {
#          -- "permissions",
#          "icon",
#          -- "size",
#          -- "mtime",
#      },
#  })
#  '''

lines = data.split('\n')
tree = parser.parse(bytes(data, "utf8"))

cursor = tree.walk()
assert cursor.node.type == "program"
assert cursor.goto_first_child()
assert cursor.node.type == "function_call" # requrie call
args = cursor.node.child_by_field_name("args")

if args is None:
    print("Could not detect args")
    exit()

cursor = args.walk()
assert cursor.goto_first_child() # setup call
children = cursor.node.children
parse_table(children) # parse setup

"""
(program
    (function_call
        prefix: (function_call
            prefix: (identifier)
            (function_call_paren)
            args: (function_arguments
                (string))
            (function_call_paren))
        prefix: (identifier)
        (function_call_paren)
        args: (function_arguments
            (tableconstructor
                (fieldlist
                    (field
                        name: (identifier)
                        value: (boolean))
                    (field
                        name: (identifier)
                        value: (string))
                    (comment)
                    (comment)
                    (field
                        name: (identifier)
                        value: (tableconstructor
                            (fieldlist
                                (field
                                    value: (string)))
                            (comment)
                            (comment)
                            (comment))))))
    (function_call_paren)))
"""
