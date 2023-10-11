from tree_sitter import Language, Parser
import re
from dataclasses import dataclass
from pprint import pprint

# global variables

lastComment = ""
indent = ""
lines = []
data = ""

@dataclass
class Option:
    options = {}

    def add(self, name, type, default, comment = ""):
        data = {
            "type": type,
            "default": default,
            "comment": comment
        }
        self.options.update({name: data})

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

def to_comment(node):
    global lastComment
    text = extract(node)

    text = re.sub(r'^-- ?', '', text)
    text = re.sub(r'"', '\"', text)

    lastComment = text
    #  print(indent, "#", text)
    return f"{indent}# {text}"

#  def extract(node):
    #  linenumber = node.start_point[0]
    #  start = node.start_point[1]
    #  end = node.end_point[1]

    #  return lines[linenumber][start:end]

def extract(node) -> str:
    return data[node.start_byte:node.end_byte]

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
                            output.add(to_comment(node))
                            pass
                        case "field":
                            fieldOutput = parse_field(node)
                            output.append(fieldOutput)
                            isList = fieldOutput.isList

    if isList:
        output.prepend("listOption [")
        output.add(f"{indent}] \"\";")
    else:
        output.prepend("{")
        output.add(f"{indent}}};")


    return output

def is_setup_function(node) -> bool:
    try:
        return extract(node.children[2]) == "setup"
    except:
        return False

def extract_field(field_node) -> dict|None: # idenfitier, type, value
    """
    Input: show_jumps = true
    """
    n = field_node.children

    if n[0].type != "identifier":
        return None

    identifier = extract(n[0])
    type_ = n[2].type

    if type_ == "tableconstructor":
        value = extract_table(n[2])
    else:
        value = extract(n[2])

    data = {
        "type": type_,
        "value": value
    }

    return { identifier: data }

def extract_field_list(fieldlist):
    ret = {}

    for field in fieldlist.children:
        if field.type == "field":
            data = extract_field(field)
            if data is not None:
                ret.update(data)

    return ret

def extract_table(table_node) -> dict:
    """
    Input: { ... }
    """
    table_entries = table_node.children

    ret = {}

    for n in table_entries:
        match n.type:
            case "{" | "}":
                continue
            case "comment":
                continue # TODO:
            case "fieldlist":
                ret = ret | extract_field_list(n)
                #  for field in n.children:
                    #  if field.type == "field":
                        #  data = extract_field(field)
                        #  ret.update(data)

    return ret

def extract_setup_table(node) -> dict|None:
    match node.type:
        case "fieldlist":
            return extract_field_list(node.next_sibling)
        case "comment":
            return None
        case "variable_declaration":
            if is_setup_function(node):
                return extract_table(node.children[3])

def parse(input, name):
    global lines
    global data

    Language.build_library(
      # Store the library in the `build` directory
      'build/my-languages.so',

      # Include one or more languages
      [
        './bin/configparser/tree-sitter-lua',
      ]
    )

    LUA_LANGUAGE = Language('build/my-languages.so', 'lua')
    parser = Parser()
    parser.set_language(LUA_LANGUAGE)

    data = input
    #  data = """
    #  {
        #  auto_teaser_filetypes = { "dashboard", "alpha", "starter", }, -- will enable running the teaser automatically for listed filetypes
        #  try = true,
    #  }
    #  """
    #  lines = input.split('\n') # for later user

    tree = parser.parse(bytes(data, "utf8"))
    #  cursor = tree.walk()
    print(tree.root_node.sexp())
    print()

    query = LUA_LANGUAGE.query("""
        [
            (table_argument
                (fieldlist
                    (field
                        name: (identifier)
                        [
                            value: (tableconstructor)
                            value: (string)
                            value: (number)
                            value: (boolean)
                        ]
                    )
                ) @table
            )
            (tableconstructor
                (fieldlist
                    (field
                        name: (identifier)
                        [
                            value: (tableconstructor)
                            value: (string)
                            value: (number)
                            value: (boolean)
                        ]
                    )
                ) @table
            )
        ]
        """)

    captures = query.captures(tree.root_node)
    pprint(captures)
    #  print()

    #  print(extract(captures[0][0]))
    #  for c, tag in captures:
        #  print(tag, extract(c))

    setup = extract_field_list(captures[0][0])

    if setup == {}:
        print("No setup function found")
    else:
        #  pprint(setup)
        file_path = f"./output/{name}.txt"
        with open(file_path, 'w') as file:
            # Write data to the file
            file.seek(0)
            file.write(f"{setup}")
