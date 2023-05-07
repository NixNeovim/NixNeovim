from tree_sitter import Language, Parser
import re
import fileinput
from dataclasses import dataclass

#  data = ''
#  for line in fileinput.input():
#      data += line

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
  -- Deleted files will be removed with the `trash-put` command.
  delete_to_trash = false,
  -- Selecting a new/moved/renamed file or directory will prompt you to save changes first
  prompt_save_on_select_new_entry = true,
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

@dataclass
class Output:
    text = ""
    isList = False

    def add(self, text, end="\n"):
        self.text += text
        self.text += end

    def prepend(self, text, end="\n"):
        self.text = text + end + self.text

    def append(self, output):
        self.text += output.text
        

Language.build_library(
  # Store the library in the `build` directory
  'build/my-languages.so',

  # Include one or more languages
  [
    './bin/configparser/tree-sitter-lua',
  ]
)

indent = ""
lastComment = ""

def to_comment(node):
    global lastComment
    text = extract(node)

    text = re.sub(r'^-- ?', '', text)

    lastComment = text
    #  print(indent, "#", text)
    return f"{indent}# {text}"

def extract(node):
    linenumber = node.start_point[0]
    start = node.start_point[1]
    end = node.end_point[1]
    return lines[linenumber][start:end]

def to_camel_case(snake_str):
    camel_string = "".join(x.capitalize() for x in snake_str.lower().split("_"))
    return snake_str[0].lower() + camel_string[1:]

def parse_field(node) -> Output:
    global lastComment
    name = node.child_by_field_name("name") # name node
    value = node.child_by_field_name("value") # value node

    output = Output()

    if name is None:
        #  print("# TODO: Field has no nam cue. Assuming it's a list")
        #  print(indent, extract(value)) # TODO: print as list
        #  output.add("# TODO: Field has no nam cue. Assuming it's a list")
        output.add(f"{indent}{extract(value)}")
        output.isList = True
        return output

    if value is None:
        print(f"Field {name} has no value")
        exit()

    camelName = to_camel_case(extract(name))
    # conver to nix code based on type
    match value.type:
        case "tableconstructor":
            #  print(indent, extract(name), "=", end="")
            output.add(f"{indent}{camelName} = ", end="")
            tableOutput = parse_table(value.children)
            output.append(tableOutput)
            return output
        case "function":
            #  print(indent, "'lua function'")
            return output
        case "nil":
            #  print(indent, "'nil'")
            output.add(f"{indent}{camelName} = 'nil';")
            return output
        case "number":
            typeString = "intOption"
        case "boolean":
            typeString = "boolOption"
        case "string":
            typeString = "strOption"
        case type:
            #  print(f"UNKNOWN ({type})")
            output.add(f"UNKNOWN ({type})")
            return output

    #  print(indent, extract(name), "=", typeString, extract(value), f"\"{lastComment}\";")
    output.add(f"{indent}{camelName} = {typeString} {extract(value)} \"{lastComment}\";")
    return output

# input node: field list
def parse_table(children):
    global indent

    output = Output()

    isList = False

    for child in children:
        match child.type:
            case "{":
                #  print("", "{")
                #  output.add("{")
                indent += "  "
            case "}":
                indent = indent[:-2]
                #  print(indent, "};")
                #  output.add(f"{indent}}};")
            case "comment":
                #  print_comment(child)
                output.add(to_comment(child))
                pass
            case "fieldlist": # content of the table
                for node in child.children:
                    match node.type:
                        case ",":
                            continue
                        case "comment":
                            #  print_comment(node)
                            output.add(to_comment(node))
                            pass
                        case "field":
                            fieldOutput = parse_field(node)
                            output.append(fieldOutput)
                            isList = fieldOutput.isList
                            #  print(output.text)

    if isList:
        output.prepend("[")
        output.add(f"{indent}];")
    else:
        output.prepend("{")
        output.add(f"{indent}}};")
            

    return output


LUA_LANGUAGE = Language('build/my-languages.so', 'lua')
parser = Parser()
parser.set_language(LUA_LANGUAGE)

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
assert cursor.node.type == "tableconstructor" # requrie call
children = cursor.node.children
output = parse_table(children) # parse setup
print(output.text)
